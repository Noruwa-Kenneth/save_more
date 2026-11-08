#!/usr/bin/env python3
"""Replay complete daily IFS runs against held-out Nova Scotia grid load."""
import argparse
from collections import defaultdict
import datetime as dt
import json
import math
from pathlib import Path
import tempfile
import time
from urllib.parse import urlencode
from urllib.error import URLError
from urllib.request import Request, urlopen
from zoneinfo import ZoneInfo

from backtest import (
    app_forecast_score,
    empirical_score,
    fetch_oasis_csv_links,
    fit_app_profile,
    load_demand_year,
    plan_rate_cents,
    percentile,
)

API = "https://single-runs-api.open-meteo.com/v1/forecast"
ZONE = ZoneInfo("America/Halifax")
LEADS = ((0, 24, "0-24h"), (24, 72, "24-72h"), (72, 168, "72-168h"))
PLANS = ("flat", "time_of_day", "time_of_use")


def local_key(utc_time):
    return utc_time.astimezone(ZONE).strftime("%Y-%m-%dT%H:%M")


def get_run(run_time, cache_dir):
    path = cache_dir / f"ifs_hres_{run_time:%Y%m%dT%H}.json"
    if path.exists():
        payload = json.loads(path.read_text(encoding="utf-8"))
    else:
        query = urlencode({
            "latitude": 44.65,
            "longitude": -63.57,
            "hourly": "temperature_2m",
            "models": "ecmwf_ifs",
            "run": run_time.strftime("%Y-%m-%dT%H:%M"),
            "timezone": "UTC",
            "forecast_days": 10,
        })
        request = Request(f"{API}?{query}", headers={"User-Agent": "SaveMore-run-aligned-backtest/1.0"})
        for attempt in range(5):
            try:
                with urlopen(request, timeout=90) as response:
                    payload = json.loads(response.read())
                break
            except URLError:
                if attempt == 4:
                    raise
                delay = 5 * (2**attempt)
                print(f"Archive request failed; retrying in {delay} seconds.", flush=True)
                time.sleep(delay)
        if payload.get("error"):
            raise RuntimeError(f"IFS run unavailable {run_time}: {payload.get('reason')}")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(payload), encoding="utf-8")
        time.sleep(1.0)
    hourly = payload.get("hourly", {})
    return [
        (dt.datetime.fromisoformat(stamp).replace(tzinfo=dt.timezone.utc), float(temp))
        for stamp, temp in zip(hourly.get("time", []), hourly.get("temperature_2m", []))
        if temp is not None
    ]


def peak_window(points):
    # Mirror PeakPredictionService: choose the highest-average consecutive
    # three-hour period, regardless of whether its scores cross 70.
    best, best_average = [], -1.0
    for start in range(max(0, len(points) - 2)):
        window = points[start:start + 3]
        if len(window) != 3 or any(
            window[i][0] - window[i - 1][0] != dt.timedelta(hours=1)
            for i in (1, 2)
        ):
            continue
        average = sum(row[1] for row in window) / 3
        if average > best_average:
            best, best_average = window, average
    return best or ([max(points, key=lambda row: row[1])] if points else [])


def score_metrics(rows, threshold):
    if not rows:
        return (0, math.nan, math.nan, math.nan, math.nan)
    tp = sum(load >= threshold and score >= 70 for load, _, score in rows)
    fp = sum(load < threshold and score >= 70 for load, _, score in rows)
    fn = sum(load >= threshold and score < 70 for load, _, score in rows)
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    mae = sum(abs(observed - predicted) for _, observed, predicted in rows) / len(rows)
    return (len(rows), mae, precision, recall, f1)


def choose_window(forecast, actuals, plan):
    candidates = []
    for start in range(len(forecast) - 2):
        window = forecast[start:start + 3]
        if any(window[i][0] - window[i - 1][0] != dt.timedelta(hours=1) for i in (1, 2)):
            continue
        score = sum(row[1] for row in window) / 3
        rate = sum(plan_rate_cents(plan, local_key(row[0])) for row in window) / 3
        candidates.append((score, rate, start, window))
    if not candidates:
        return None
    chosen = min(candidates, key=lambda item: (item[0], item[1], item[2]))[3]
    measured = [actuals.get(local_key(row[0])) for row in chosen]
    if any(value is None for value in measured):
        return None
    return chosen, [float(value) for value in measured]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile-year", type=int, default=2024)
    parser.add_argument("--test-year", type=int, default=2025)
    parser.add_argument("--start-date")
    parser.add_argument("--end-date")
    parser.add_argument("--cache-dir", type=Path, default=Path(tempfile.gettempdir()) / "save_more_grid_backtest")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    first = dt.date.fromisoformat(args.start_date) if args.start_date else dt.date(args.test_year, 1, 1)
    last = dt.date.fromisoformat(args.end_date) if args.end_date else dt.date(args.test_year, 12, 31)
    if first.year != args.test_year or last.year != args.test_year or last < first:
        parser.error("Date range must be ordered and within test year.")

    cache = args.cache_dir
    links = fetch_oasis_csv_links(cache, refresh=False)
    training, skipped_training = load_demand_year(args.profile_year, links[args.profile_year], cache, False)
    actuals, skipped_test = load_demand_year(args.test_year, links[args.test_year], cache, False)
    profile = fit_app_profile(training)
    threshold = percentile(training.values(), 0.90)
    hourly = defaultdict(list)
    appliance = defaultdict(list)
    peak_duration, peak_flags, peak_mw, horizon_mw = [], [], [], []
    total_runs = (last - first).days + 1
    day = first
    while day <= last:
        run_time = dt.datetime.combine(day, dt.time(6), dt.timezone.utc)
        run = get_run(run_time, cache / "ifs_single_runs")
        available = run_time + dt.timedelta(hours=6)
        horizon_end = available + dt.timedelta(hours=168)
        scored = []
        for valid, temp in run:
            if valid < available or valid >= horizon_end:
                continue
            score = app_forecast_score(local_key(valid), temp, profile)
            scored.append((valid, score, temp))
            load = actuals.get(local_key(valid))
            if load is not None:
                lead = (valid - available).total_seconds() / 3600
                actual_score = empirical_score(load, profile[3])
                for low, high, name in LEADS:
                    if low <= lead < high:
                        hourly[name].append((load, actual_score, score))
                        break

        period = peak_window([(valid, score) for valid, score, _ in scored])
        peak_duration.append(len(period))
        observed_period = [actuals[local_key(t)] for t, _ in period if local_key(t) in actuals]
        observed_horizon = [actuals[local_key(t)] for t, _, _ in scored if local_key(t) in actuals]
        if observed_period and observed_horizon:
            peak_flags.extend(value >= threshold for value in observed_period)
            peak_mw.append(sum(observed_period) / len(observed_period))
            horizon_mw.append(sum(observed_horizon) / len(observed_horizon))

        next24 = [row for row in scored if available <= row[0] < available + dt.timedelta(hours=24)]
        for plan in PLANS:
            selection = choose_window(next24, actuals, plan)
            measured24 = [actuals.get(local_key(row[0])) for row in next24]
            if selection is None or len(next24) != 24 or any(value is None for value in measured24):
                continue
            chosen, selected_actual = selection
            actual_candidates = [
                sum(float(actuals[local_key(row[0])]) for row in next24[i:i + 3]) / 3
                for i in range(22)
                if all(next24[i + offset][0] - next24[i + offset - 1][0] == dt.timedelta(hours=1) for offset in (1, 2))
            ]
            if actual_candidates:
                selected = sum(selected_actual) / 3
                day_average = sum(float(value) for value in measured24) / 24
                appliance[plan].append((selected, day_average, min(actual_candidates)))

        day += dt.timedelta(days=1)
        completed = (day - first).days
        if completed % 25 == 0 or completed == total_runs:
            print(f"Processed {completed}/{total_runs} daily IFS runs.", flush=True)

    lines = [
        "# Run-aligned Save More forecast backtest", "",
        f"- Profile training year: {args.profile_year}; held-out OASIS year: {args.test_year}.",
        f"- Scored forecast run dates: {first.isoformat()} through {last.isoformat()}.",
        f"- Daily runs: {total_runs}, issued 06:00 UTC; assumed available six hours later.",
        "- Forecast source: Open-Meteo Single Runs API, ECMWF IFS HRES 9 km, Halifax.",
        f"- Training 90th-percentile peak threshold: {threshold:.1f} MW.",
        f"- OASIS skipped rows/timestamps: training={skipped_training:,}, test={skipped_test:,}.",
        "- Forecast valid times are converted to Halifax local time before app scoring and OASIS matching.", "",
        "This mirrors the app's bundled historical profile and temperature adjustment with complete individual weather runs. The live app currently uses Open-Meteo's default model selection, so IFS validates the scoring logic with IFS weather, not the exact live weather feed.", "",
        "## Hourly score and peak-flag performance", "",
        "Observed peak is load >= the profile-year 90th percentile; predicted peak is score >=70. Score MAE uses percentile points.", "",
        "| Lead from assumed availability | Matched hours | Score MAE | Peak precision | Peak recall | Peak F1 |",
        "|---|---:|---:|---:|---:|---:|",
    ]
    for low, high, name in LEADS:
        n, mae, precision, recall, f1 = score_metrics(hourly[name], threshold)
        lines.append(f"| {name} | {n:,} | {mae:.1f} | {precision:.3f} | {recall:.3f} | {f1:.3f} |")

    duration = sum(peak_duration) / len(peak_duration) if peak_duration else math.nan
    long_periods = 100 * sum(value > 24 for value in peak_duration) / len(peak_duration) if peak_duration else math.nan
    period_precision = 100 * sum(peak_flags) / len(peak_flags) if peak_flags else math.nan
    avg_peak = sum(peak_mw) / len(peak_mw) if peak_mw else math.nan
    avg_horizon = sum(horizon_mw) / len(horizon_mw) if horizon_mw else math.nan
    lines.extend([
        "", "## Peak-period card check", "",
        "The app selects the highest-average consecutive 3-hour block, regardless of demand level. If no such block exists, it selects the highest-scoring available hour.", "",
        "| Runs | Mean card duration (hours) | Runs with card >24h | Card hours at/above top-decile load | Mean card-window load (MW) | Mean 7-day load (MW) |",
        "|---:|---:|---:|---:|---:|---:|",
        f"| {len(peak_duration):,} | {duration:.1f} | {long_periods:.1f}% | {period_precision:.1f}% | {avg_peak:.1f} | {avg_horizon:.1f} |",
        "", "## Next-24-hour appliance-window check", "",
        "Each choice mirrors the app's lowest-score consecutive three hours, with selected-plan rate as a tie-break. Only windows with all 24 measured hours are counted. Reduction compares the selected window with the same rolling 24-hour mean; regret compares with the measured best three-hour window.", "",
        "| Plan | Complete windows | Chosen window below 24h mean | Mean reduction vs 24h mean (MW) | Regret vs measured best 3h (MW) |",
        "|---|---:|---:|---:|---:|",
    ])
    labels = {"flat": "Standard Residential (flat)", "time_of_day": "Time-of-Day", "time_of_use": "Time-of-Use"}
    for plan in PLANS:
        rows = appliance[plan]
        below = 100 * sum(a < b for a, b, _ in rows) / len(rows) if rows else math.nan
        reduction = sum(b - a for a, b, _ in rows) / len(rows) if rows else math.nan
        regret = sum(a - c for a, _, c in rows) / len(rows) if rows else math.nan
        lines.append(f"| {labels[plan]} | {len(rows):,} | {below:.1f}% | {reduction:.1f} | {regret:.1f} |")
    lines.extend(["", "## Limits", "", "Results are province-wide MW comparisons, not household savings. Halifax is a single weather proxy. The live app does not explicitly select IFS. One 06 UTC run per day models one decision time, not every time a user opens the app. The six-hour availability delay is conservative. Incomplete and DST OASIS days are omitted."])
    report = "\n".join(lines) + "\n"
    print("\n" + report)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(report, encoding="utf-8")
        print(f"Wrote report to {args.output}")


if __name__ == "__main__":
    main()
