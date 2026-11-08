#!/usr/bin/env python3
"""Backtest Save More's hourly demand score against OASIS measurements.

The tool compares a month/hour/weekend baseline, a fitted heating-degree
benchmark, and a mirror of the Flutter app's percentile score with its cold-
weather adjustment. Archived GFS forecasts are evaluated at fixed 1-, 3-, and
7-day lead times.

Only Python's standard library is required. Downloaded inputs are cached in the
user's home directory and are not added to the Flutter app or Git repository.
"""

from __future__ import annotations

import argparse
from bisect import bisect_right
import csv
import datetime as dt
import html.parser
import io
import json
import math
import re
import tempfile
import time
from collections import defaultdict
from pathlib import Path
from typing import Iterable
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen


OASIS_URL = (
    "https://www.nspower.ca/oasis/monthly-reports/"
    "hourly-total-net-nova-scotia-load"
)
WEATHER_URL = "https://previous-runs-api.open-meteo.com/v1/forecast"
LATITUDE = 44.65
LONGITUDE = -63.57
TIMEZONE = "America/Halifax"
WEATHER_MODEL = "gfs_seamless"
HEATING_BASE_C = 10.0
LEADS = (1, 3, 7)
APPLIANCE_PLANS = ("flat", "time_of_day", "time_of_use")
SEASONS = ("Winter", "Spring", "Summer", "Fall")


class OasisLinkParser(html.parser.HTMLParser):
    """Collect CSV links from the official OASIS year table."""

    def __init__(self) -> None:
        super().__init__()
        self.csv_by_year: dict[int, str] = {}
        self._in_row = False
        self._in_anchor = False
        self._anchor_href = ""
        self._row_text: list[str] = []
        self._row_links: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attributes = dict(attrs)
        if tag == "tr":
            self._in_row = True
            self._row_text = []
            self._row_links = []
        elif tag == "a" and self._in_row:
            self._in_anchor = True
            self._anchor_href = attributes.get("href") or ""

    def handle_data(self, data: str) -> None:
        if self._in_row:
            self._row_text.append(data.strip())

    def handle_endtag(self, tag: str) -> None:
        if tag == "a":
            if self._in_row and ".csv" in self._anchor_href.lower():
                self._row_links.append(self._anchor_href)
            self._in_anchor = False
            self._anchor_href = ""
        elif tag == "tr" and self._in_row:
            row_text = " ".join(part for part in self._row_text if part)
            year_match = re.match(r"^(20\d{2})\b", row_text)
            if year_match and self._row_links:
                self.csv_by_year[int(year_match.group(1))] = self._row_links[-1]
            self._in_row = False


def fetch_bytes(url: str) -> bytes:
    request = Request(url, headers={"User-Agent": "SaveMore-grid-demand-backtest/1.0"})
    with urlopen(request, timeout=90) as response:
        return response.read()


def cached_bytes(path: Path, url: str, refresh: bool) -> bytes:
    if path.exists() and not refresh:
        return path.read_bytes()
    path.parent.mkdir(parents=True, exist_ok=True)
    data = fetch_bytes(url)
    path.write_bytes(data)
    return data


def fetch_oasis_csv_links(cache_dir: Path, refresh: bool) -> dict[int, str]:
    page_path = cache_dir / "oasis-reports.html"
    page = cached_bytes(page_path, OASIS_URL, refresh).decode("utf-8", "replace")
    parser = OasisLinkParser()
    parser.feed(page)
    if not parser.csv_by_year:
        raise RuntimeError("Could not find year CSV links on the OASIS report page.")
    return parser.csv_by_year


def parse_oasis_rows(raw: bytes) -> tuple[dict[str, float], int]:
    text = raw.decode("utf-8-sig", "replace")
    rows = list(csv.reader(io.StringIO(text, newline="")))
    header_index = next(
        (
            i
            for i, row in enumerate(rows)
            if any(cell.strip().lower() in ("date/time", "datetime") for cell in row)
            and any("load" in cell.lower() and "mw" in cell.lower() for cell in row)
        ),
        None,
    )
    if header_index is None:
        raise ValueError("OASIS CSV did not contain Date/time and Load [MW] columns.")

    header = rows[header_index]
    time_column = next(
        i for i, cell in enumerate(header)
        if cell.strip().lower() in ("date/time", "datetime")
    )
    load_column = next(
        i for i, cell in enumerate(header)
        if "load" in cell.lower() and "mw" in cell.lower()
    )
    by_day: dict[str, list[tuple[str, float]]] = defaultdict(list)
    invalid_rows = 0

    for row in rows[header_index + 1 :]:
        if len(row) <= max(time_column, load_column):
            if any(cell.strip() for cell in row):
                invalid_rows += 1
            continue
        time_text = row[time_column].strip()
        load_text = row[load_column].strip()
        if not time_text and not load_text:
            continue
        try:
            timestamp = parse_report_time(time_text)
            load_mw = float(load_text.replace(",", ""))
            if not math.isfinite(load_mw) or load_mw < 0:
                raise ValueError("invalid load")
        except (ValueError, TypeError):
            invalid_rows += 1
            continue
        day = timestamp.strftime("%Y-%m-%d")
        key = timestamp.strftime("%Y-%m-%dT%H:%M")
        by_day[day].append((key, load_mw))

    # OASIS timestamps have no UTC offsets, and its DST transition hours do
    # not consistently match the archived weather wall-clock sequence. Keep
    # only complete 24-hour days with one row for every local clock hour.
    demand: dict[str, float] = {}
    skipped_samples = 0
    for day_rows in by_day.values():
        hours = [timestamp[11:13] for timestamp, _ in day_rows]
        if len(day_rows) != 24 or set(hours) != {f"{hour:02}" for hour in range(24)}:
            skipped_samples += len(day_rows)
            continue
        demand.update(day_rows)
    return demand, invalid_rows + skipped_samples


def parse_report_time(value: str) -> dt.datetime:
    for date_format in ("%Y-%m-%d %H:%M", "%m/%d/%Y %H:%M", "%m/%d/%y %H:%M"):
        try:
            return dt.datetime.strptime(value, date_format)
        except ValueError:
            pass
    raise ValueError(f"Unsupported OASIS timestamp: {value!r}")


def load_demand_year(
    year: int,
    link: str,
    cache_dir: Path,
    refresh: bool,
) -> tuple[dict[str, float], int]:
    csv_path = cache_dir / f"oasis_load_{year}.csv"
    raw = cached_bytes(csv_path, urljoin(OASIS_URL, link), refresh)
    return parse_oasis_rows(raw)


def load_weather_year(
    year: int,
    cache_dir: Path,
    refresh: bool,
) -> dict[str, dict[int, float]]:
    cache_path = cache_dir / f"gfs_weather_{year}.json"
    if cache_path.exists() and not refresh:
        payload = json.loads(cache_path.read_text(encoding="utf-8"))
    else:
        hourly_fields = [f"temperature_2m_previous_day{lead}" for lead in LEADS]
        query = urlencode(
            {
                "latitude": LATITUDE,
                "longitude": LONGITUDE,
                "hourly": ",".join(hourly_fields),
                "start_date": f"{year}-01-01",
                "end_date": f"{year}-12-31",
                "timezone": TIMEZONE,
                "models": WEATHER_MODEL,
            }
        )
        payload = json.loads(fetch_bytes(f"{WEATHER_URL}?{query}"))
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(json.dumps(payload), encoding="utf-8")
        time.sleep(0.5)

    if "error" in payload:
        raise RuntimeError(f"Open-Meteo error for {year}: {payload.get('reason')}")
    hourly = payload.get("hourly", {})
    timestamps = hourly.get("time", [])
    result: dict[str, dict[int, float]] = {}
    for index, timestamp in enumerate(timestamps):
        values: dict[int, float] = {}
        for lead in LEADS:
            series = hourly.get(f"temperature_2m_previous_day{lead}", [])
            if index < len(series) and series[index] is not None:
                values[lead] = float(series[index])
        if values:
            # OASIS reports local clock labels without offsets. Match the
            # archive's America/Halifax wall-clock labels and skip ambiguous
            # OASIS duplicate hours during the join.
            result[timestamp[:16]] = values
    return result


def baseline_key(timestamp: str) -> tuple[int, int, bool]:
    value = dt.datetime.strptime(timestamp, "%Y-%m-%dT%H:%M")
    return value.month, value.hour, value.weekday() >= 5


def season_for(timestamp: str) -> str:
    """Return the meteorological season for a local Nova Scotia timestamp."""
    month = int(timestamp[5:7])
    if month in (12, 1, 2):
        return "Winter"
    if month in (3, 4, 5):
        return "Spring"
    if month in (6, 7, 8):
        return "Summer"
    return "Fall"


def percentile(values: Iterable[float], fraction: float) -> float:
    ordered = sorted(values)
    if not ordered:
        raise ValueError("Cannot compute a percentile from no training data.")
    index = min(len(ordered) - 1, max(0, math.ceil(fraction * len(ordered)) - 1))
    return ordered[index]


def fit_baseline(training_loads: dict[str, float]) -> tuple[dict[tuple[int, int, bool], float], float]:
    groups: dict[tuple[int, int, bool], list[float]] = defaultdict(list)
    for timestamp, load in training_loads.items():
        groups[baseline_key(timestamp)].append(load)
    baseline = {key: sum(values) / len(values) for key, values in groups.items()}
    peak_threshold = percentile(training_loads.values(), 0.90)
    return baseline, peak_threshold


def fit_app_profile(
    training_loads: dict[str, float],
) -> tuple[
    dict[tuple[int, int, bool], float],
    dict[tuple[int, int], float],
    dict[int, float],
    list[float],
]:
    """Mirror GridDemandProfileService's historical averaging buckets."""
    by_month_hour_weekend: dict[tuple[int, int, bool], list[float]] = defaultdict(list)
    by_month_hour: dict[tuple[int, int], list[float]] = defaultdict(list)
    by_hour: dict[int, list[float]] = defaultdict(list)
    for timestamp, load in training_loads.items():
        month, hour, weekend = baseline_key(timestamp)
        by_month_hour_weekend[(month, hour, weekend)].append(load)
        by_month_hour[(month, hour)].append(load)
        by_hour[hour].append(load)

    average = lambda groups: {
        key: sum(values) / len(values) for key, values in groups.items()
    }
    return (
        average(by_month_hour_weekend),
        average(by_month_hour),
        average(by_hour),
        sorted(training_loads.values()),
    )


def dart_round(value: float) -> int:
    """Match Dart's positive double.round() behavior for percentile scores."""
    return math.floor(value + 0.5)


def empirical_score(value: float, sorted_loads: list[float]) -> int:
    if not sorted_loads:
        return 0
    percentile_score = dart_round(100 * bisect_right(sorted_loads, value) / len(sorted_loads))
    return min(100, max(0, percentile_score))


def app_forecast_score(
    timestamp: str,
    temperature_c: float,
    profile: tuple[
        dict[tuple[int, int, bool], float],
        dict[tuple[int, int], float],
        dict[int, float],
        list[float],
    ],
) -> int:
    """Mirror GridDemandProfile.scoreFor + PeakPredictionService cold uplift."""
    by_month_hour_weekend, by_month_hour, by_hour, sorted_loads = profile
    month, hour, weekend = baseline_key(timestamp)
    expected_load = by_month_hour_weekend.get((month, hour, weekend))
    if expected_load is None:
        expected_load = by_month_hour.get((month, hour))
    if expected_load is None:
        expected_load = by_hour.get(hour)
    if expected_load is None:
        return 0

    score = empirical_score(expected_load, sorted_loads)
    if temperature_c < -10:
        score += 12
    elif temperature_c < 0:
        score += 8
    elif temperature_c < 5:
        score += 4
    return min(100, score)


def score_app_predictions(
    actuals: list[float],
    actual_scores: list[int],
    predicted_scores: list[int],
    peak_threshold: float,
) -> dict[str, float | int]:
    if not actuals:
        return {
            "n": 0,
            "observed_peak_hours": 0,
            "score_mae": math.nan,
            "peak_precision": math.nan,
            "peak_recall": math.nan,
            "peak_f1": math.nan,
        }

    actual_peaks = [load >= peak_threshold for load in actuals]
    predicted_peaks = [score >= 70 for score in predicted_scores]
    tp = sum(a and p for a, p in zip(actual_peaks, predicted_peaks))
    fp = sum(not a and p for a, p in zip(actual_peaks, predicted_peaks))
    fn = sum(a and not p for a, p in zip(actual_peaks, predicted_peaks))
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    score_mae = sum(
        abs(actual - predicted)
        for actual, predicted in zip(actual_scores, predicted_scores)
    ) / len(actuals)
    return {
        "n": len(actuals),
        "observed_peak_hours": sum(actual >= peak_threshold for actual in actuals),
        "score_mae": score_mae,
        "peak_precision": precision,
        "peak_recall": recall,
        "peak_f1": f1,
    }


def plan_rate_cents(plan: str, timestamp: str) -> float:
    """Mirror RateScheduleService rates at the start of each forecast hour."""
    if plan == "flat":
        return 0.0
    value = dt.datetime.strptime(timestamp, "%Y-%m-%dT%H:%M")
    weekend = value.weekday() >= 5
    hour = value.hour
    if plan == "time_of_day":
        if weekend:
            return 12.436
        if value.month in (12, 1, 2):
            if 7 <= hour < 12 or 16 <= hour < 23:
                return 25.188
            if 12 <= hour < 16:
                return 20.263
            return 12.436
        return 20.263 if 7 <= hour < 23 else 12.436
    if plan == "time_of_use":
        if value.month not in (11, 12, 1, 2, 3):
            return 13.213
        if weekend:
            return 19.128
        if 7 <= hour < 11 or 17 <= hour < 21:
            return 37.321
        return 19.128
    raise ValueError(f"Unknown appliance plan: {plan}")


def score_appliance_windows(
    demand: dict[str, float],
    weather: dict[str, dict[int, float]],
    lead: int,
    profile: tuple[
        dict[tuple[int, int, bool], float],
        dict[tuple[int, int], float],
        dict[int, float],
        list[float],
    ],
    plan: str,
) -> dict[str, float | int]:
    """Choose one forecast 3-hour window per complete day; score measured load."""
    days: dict[str, list[str]] = defaultdict(list)
    for timestamp in demand:
        days[timestamp[:10]].append(timestamp)

    selected_loads: list[float] = []
    day_means: list[float] = []
    regret_mw: list[float] = []
    for timestamps in days.values():
        timestamps.sort()
        if len(timestamps) != 24 or any(
            timestamp not in weather or lead not in weather[timestamp]
            for timestamp in timestamps
        ):
            continue
        scores = [
            app_forecast_score(timestamp, weather[timestamp][lead], profile)
            for timestamp in timestamps
        ]
        candidate_windows: list[tuple[float, float, int, float]] = []
        for start in range(24 - 3 + 1):
            average_score = sum(scores[start : start + 3]) / 3
            average_rate = sum(
                plan_rate_cents(plan, timestamps[index])
                for index in range(start, start + 3)
            ) / 3
            actual_window_load = sum(
                demand[timestamps[index]] for index in range(start, start + 3)
            ) / 3
            candidate_windows.append(
                (average_score, average_rate, start, actual_window_load)
            )

        # Match _findApplianceWindow: lowest score first, then lower plan rate;
        # stable ordering keeps the earliest window when both values tie.
        chosen = min(candidate_windows, key=lambda window: (window[0], window[1]))
        selected_loads.append(chosen[3])
        day_means.append(sum(demand[timestamp] for timestamp in timestamps) / 24)
        regret_mw.append(min(window[3] for window in candidate_windows))

    count = len(selected_loads)
    if not count:
        return {
            "days": 0,
            "below_day_average_pct": math.nan,
            "mean_reduction_mw": math.nan,
            "mean_regret_mw": math.nan,
        }
    return {
        "days": count,
        "below_day_average_pct": 100 * sum(
            selected < average for selected, average in zip(selected_loads, day_means)
        ) / count,
        "mean_reduction_mw": sum(
            average - selected for average, selected in zip(day_means, selected_loads)
        ) / count,
        "mean_regret_mw": sum(
            selected - best for selected, best in zip(selected_loads, regret_mw)
        ) / count,
    }


def fit_heating_slope(
    training_loads: dict[str, float],
    training_weather: dict[str, dict[int, float]],
    lead: int,
    baseline: dict[tuple[int, int, bool], float],
) -> tuple[float, int]:
    numerator = 0.0
    denominator = 0.0
    count = 0
    for timestamp, load in training_loads.items():
        temperature = training_weather.get(timestamp, {}).get(lead)
        expected = baseline.get(baseline_key(timestamp))
        if temperature is None or expected is None:
            continue
        heating_degree = max(0.0, HEATING_BASE_C - temperature)
        numerator += heating_degree * (load - expected)
        denominator += heating_degree * heating_degree
        count += 1
    return (numerator / denominator if denominator else 0.0, count)


def score_predictions(
    actuals: list[float],
    predictions: list[float],
    peak_threshold: float,
) -> dict[str, float | int]:
    if not actuals:
        return {"n": 0, "mae_mw": math.nan, "rmse_mw": math.nan,
                "observed_peak_hours": 0,
                "wape_pct": math.nan, "bias_mw": math.nan,
                "peak_precision": math.nan, "peak_recall": math.nan,
                "peak_f1": math.nan}
    errors = [prediction - actual for actual, prediction in zip(actuals, predictions)]
    absolute_error = sum(abs(error) for error in errors)
    true_peaks = [actual >= peak_threshold for actual in actuals]
    predicted_peaks = [prediction >= peak_threshold for prediction in predictions]
    tp = sum(actual and predicted for actual, predicted in zip(true_peaks, predicted_peaks))
    fp = sum(not actual and predicted for actual, predicted in zip(true_peaks, predicted_peaks))
    fn = sum(actual and not predicted for actual, predicted in zip(true_peaks, predicted_peaks))
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return {
        "n": len(actuals),
        "observed_peak_hours": sum(actual >= peak_threshold for actual in actuals),
        "mae_mw": absolute_error / len(actuals),
        "rmse_mw": math.sqrt(sum(error * error for error in errors) / len(errors)),
        "wape_pct": 100 * absolute_error / sum(actuals),
        "bias_mw": sum(errors) / len(errors),
        "peak_precision": precision,
        "peak_recall": recall,
        "peak_f1": f1,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--train-years", nargs="+", type=int, default=[2022, 2023])
    parser.add_argument("--test-years", nargs="+", type=int, default=[2024, 2025])
    parser.add_argument("--lead-days", nargs="+", type=int, choices=LEADS, default=list(LEADS))
    parser.add_argument("--cache-dir", type=Path,
                        default=Path(tempfile.gettempdir()) / "save_more_grid_backtest")
    parser.add_argument("--refresh", action="store_true",
                        help="Redownload OASIS and weather files, ignoring the local cache.")
    parser.add_argument("--output", type=Path,
                        help="Optionally write the results as a Markdown report.")
    args = parser.parse_args()

    overlap = set(args.train_years) & set(args.test_years)
    if overlap:
        parser.error(f"Training and test years must be separate; overlapping: {sorted(overlap)}")

    all_years = sorted(set(args.train_years + args.test_years))
    links = fetch_oasis_csv_links(args.cache_dir, args.refresh)
    demands: dict[int, dict[str, float]] = {}
    weather: dict[int, dict[str, dict[int, float]]] = {}
    skipped_rows: dict[int, int] = {}

    for year in all_years:
        if year not in links:
            raise RuntimeError(f"OASIS does not list a CSV for {year}.")
        demands[year], skipped_rows[year] = load_demand_year(
            year, links[year], args.cache_dir, args.refresh
        )
        weather[year] = load_weather_year(year, args.cache_dir, args.refresh)
        print(
            f"Loaded {year}: {len(demands[year]):,} unique demand hours, "
            f"{len(weather[year]):,} archived weather hours, "
            f"{skipped_rows[year]:,} skipped OASIS rows/timestamps."
        )

    training_loads = {
        timestamp: load
        for year in args.train_years
        for timestamp, load in demands[year].items()
    }
    baseline, peak_threshold = fit_baseline(training_loads)
    app_profile = fit_app_profile(training_loads)
    app_validation: dict[tuple[int, int], dict[str, float | int]] = {}
    seasonal_validation: dict[
        tuple[int, str, int],
        tuple[dict[str, float | int], dict[str, float | int]],
    ] = {}
    seasonal_app_validation: dict[tuple[int, str, int], dict[str, float | int]] = {}
    appliance_validation: dict[tuple[int, int, str], dict[str, float | int]] = {}
    report = [
        "# Save More grid-demand backtest",
        "",
        f"- Training years: {', '.join(map(str, args.train_years))}",
        f"- Held-out test years: {', '.join(map(str, args.test_years))}",
        f"- Demand source: Nova Scotia Power OASIS hourly load, MW.",
        f"- Weather source: Open-Meteo Previous Runs, {WEATHER_MODEL}, Halifax coordinates.",
        f"- Training 90th-percentile peak threshold: {peak_threshold:.1f} MW.",
        "- Incomplete days (including daylight-saving transition days) and malformed OASIS rows are omitted to avoid ambiguous clock-time joins.",
        "- Weather inputs are archived forecasts at fixed lead times, not observed future weather.",
        "",
        "The weather model adds a single heating-degree slope fitted only on the training years to the month/hour/weekday baseline. It is a transparent benchmark, not a production model.",
        "",
        "| Test year | Lead | Matched hours | Baseline MAE MW | Weather MAE MW | Baseline WAPE | Weather WAPE | Baseline peak F1 | Weather peak F1 |",
        "|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]

    for year in args.test_years:
        for lead in args.lead_days:
            # Join forecast temperatures from all training years, restricted
            # to the selected lead-time offset.
            training_weather = {
                timestamp: values
                for train_year in args.train_years
                for timestamp, values in weather[train_year].items()
            }
            slope, paired_training_count = fit_heating_slope(
                training_loads, training_weather, lead, baseline
            )
            joined = [
                (timestamp, load, weather[year].get(timestamp, {}).get(lead))
                for timestamp, load in demands[year].items()
            ]
            joined = [row for row in joined if row[2] is not None]
            actuals = [load for _, load, _ in joined]
            base_predictions = [baseline.get(baseline_key(t), peak_threshold) for t, _, _ in joined]
            weather_predictions = [
                max(0.0, base + slope * max(0.0, HEATING_BASE_C - float(temp)))
                for base, (_, _, temp) in zip(base_predictions, joined)
            ]
            app_scores = [
                app_forecast_score(timestamp, float(temp), app_profile)
                for timestamp, _, temp in joined
            ]
            actual_scores = [
                empirical_score(load, app_profile[3]) for _, load, _ in joined
            ]
            baseline_score = score_predictions(actuals, base_predictions, peak_threshold)
            weather_score = score_predictions(actuals, weather_predictions, peak_threshold)
            app_score = score_app_predictions(
                actuals, actual_scores, app_scores, peak_threshold
            )
            app_validation[(year, lead)] = app_score
            for season in SEASONS:
                seasonal_rows = [
                    index
                    for index, (timestamp, _, _) in enumerate(joined)
                    if season_for(timestamp) == season
                ]
                seasonal_validation[(year, season, lead)] = (
                    score_predictions(
                        [actuals[index] for index in seasonal_rows],
                        [base_predictions[index] for index in seasonal_rows],
                        peak_threshold,
                    ),
                    score_predictions(
                        [actuals[index] for index in seasonal_rows],
                        [weather_predictions[index] for index in seasonal_rows],
                        peak_threshold,
                    ),
                )
                seasonal_app_validation[(year, season, lead)] = (
                    score_app_predictions(
                        [actuals[index] for index in seasonal_rows],
                        [actual_scores[index] for index in seasonal_rows],
                        [app_scores[index] for index in seasonal_rows],
                        peak_threshold,
                    )
                )
            for plan in APPLIANCE_PLANS:
                appliance_validation[(year, lead, plan)] = score_appliance_windows(
                    demands[year], weather[year], lead, app_profile, plan
                )
            print(
                f"Scored {year}, {lead}-day lead: {len(joined):,} matched hours; "
                f"trained weather slope from {paired_training_count:,} paired hours; "
                f"app-score MAE {app_score['score_mae']:.1f} points, "
                f"app peak F1 {app_score['peak_f1']:.3f}."
            )
            report.append(
                f"| {year} | {lead} | {len(joined):,} | "
                f"{baseline_score['mae_mw']:.1f} | {weather_score['mae_mw']:.1f} | "
                f"{baseline_score['wape_pct']:.2f}% | {weather_score['wape_pct']:.2f}% | "
                f"{baseline_score['peak_f1']:.3f} | {weather_score['peak_f1']:.3f} |"
            )

    report.extend(
        [
            "",
            "## Held-out seasonal performance",
            "",
            "Seasons use meteorological months: winter (Dec–Feb), spring (Mar–May), summer (Jun–Aug), and fall (Sep–Nov). Weather coefficients and the peak threshold remain fitted only on the training years. A season with zero matched hours is shown as `nan`; incomplete and unavailable source data reduce seasonal sample counts.",
            "",
            "| Test year | Season | Lead | Matched hours | Observed peak hours | Baseline MAE MW | Weather MAE MW | Baseline WAPE | Weather WAPE | Baseline peak F1 | Weather peak F1 |",
            "|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
        ]
    )
    for year in args.test_years:
        for season in SEASONS:
            for lead in args.lead_days:
                baseline_metrics, weather_metrics = seasonal_validation[
                    (year, season, lead)
                ]
                report.append(
                    f"| {year} | {season} | {lead} | {baseline_metrics['n']:,} | "
                    f"{baseline_metrics['observed_peak_hours']:,} | "
                    f"{baseline_metrics['mae_mw']:.1f} | {weather_metrics['mae_mw']:.1f} | "
                    f"{baseline_metrics['wape_pct']:.2f}% | {weather_metrics['wape_pct']:.2f}% | "
                    f"{baseline_metrics['peak_f1']:.3f} | {weather_metrics['peak_f1']:.3f} |"
                )

    report.extend(
        [
            "",
            "## Held-out seasonal app-score performance",
            "",
            "This table evaluates the app-mirror 0–100 score against measured load percentiles and checks its high-demand flag against the training-period top-decile MW threshold. Precision and recall are included because a single F1 or 'accuracy' percentage can hide false alarms or missed peak hours. Seasons with zero observed peak hours cannot meaningfully demonstrate peak recall; their zero F1 should not be read as the same kind of failure as a season with observed peaks.",
            "",
            "| Test year | Season | Lead | Matched hours | Observed peak hours | Score MAE (points) | Peak precision | Peak recall | Peak F1 |",
            "|---:|---|---:|---:|---:|---:|---:|---:|---:|",
        ]
    )
    for year in args.test_years:
        for season in SEASONS:
            for lead in args.lead_days:
                metrics = seasonal_app_validation[(year, season, lead)]
                report.append(
                    f"| {year} | {season} | {lead} | {metrics['n']:,} | "
                    f"{metrics['observed_peak_hours']:,} | "
                    f"{metrics['score_mae']:.1f} | {metrics['peak_precision']:.3f} | "
                    f"{metrics['peak_recall']:.3f} | {metrics['peak_f1']:.3f} |"
                )

    report.extend(
        [
            "",
            "## Flutter app scoring logic",
            "",
            "The app-mirror score averages training load for the same month, hour, and weekday/weekend type, ranks that expected load against the training load distribution, then applies the app's temperature adjustments (+4 below 5°C, +8 below 0°C, +12 below -10°C). Its output is capped at 100. No test-year load is used to build the profile.",
            "",
            "App-score MAE compares the app's 0–100 score with the percentile rank of the measured test-hour load in the training distribution. For peak detection, app scores of 70 or higher are compared with measured loads at or above the training 90th-percentile MW threshold.",
            "",
            "| Test year | Lead | App score MAE (points) | Peak precision | Peak recall | Peak F1 |",
            "|---:|---:|---:|---:|---:|---:|",
        ]
    )
    for year in args.test_years:
        for lead in args.lead_days:
            metrics = app_validation[(year, lead)]
            report.append(
                f"| {year} | {lead} | {metrics['score_mae']:.1f} | "
                f"{metrics['peak_precision']:.3f} | {metrics['peak_recall']:.3f} | "
                f"{metrics['peak_f1']:.3f} |"
            )

    report.extend(
        [
            "",
            "## Appliance-window offline check",
            "",
            "For every complete test calendar day, this mirrors the app's selection rule over that day's 24 hourly forecast scores: choose the consecutive three-hour window with the lowest average forecast score, breaking ties with the selected plan's average hourly rate. It then compares that chosen window with the OASIS load measured for those same hours.",
            "",
            "This is a per-calendar-day offline proxy, not an exact replay of the app's rolling next-24-hour recommendation. Open-Meteo Previous Runs supplies fixed-lead values for each valid hour, rather than one complete forecast run issued at a common time. The test also considers only windows contained within each calendar day, so it cannot select a window that crosses midnight.",
            "",
            "| Test year | Lead | Plan | Complete days | Windows below daily mean | Mean load reduction vs daily mean (MW) | Mean regret vs measured best 3h (MW) |",
            "|---:|---:|---|---:|---:|---:|---:|",
        ]
    )
    plan_names = {
        "flat": "Standard Residential (flat)",
        "time_of_day": "Time-of-Day",
        "time_of_use": "Time-of-Use",
    }
    for year in args.test_years:
        for lead in args.lead_days:
            for plan in APPLIANCE_PLANS:
                metrics = appliance_validation[(year, lead, plan)]
                report.append(
                    f"| {year} | {lead} | {plan_names[plan]} | {metrics['days']:,} | "
                    f"{metrics['below_day_average_pct']:.1f}% | "
                    f"{metrics['mean_reduction_mw']:.1f} | {metrics['mean_regret_mw']:.1f} |"
                )

    report.extend(
        [
            "",
            "Interpretation: lower MAE/WAPE is better; higher peak F1 is better. The weather adjustment should be considered useful only if it beats the baseline across held-out years and lead times, not just one row.",
            "The app score MAE is measured in percentile points, not MW. Its peak precision, recall, and F1 evaluate the app's >=70 high-demand threshold against measured top-decile hours; these are not overall accuracy percentages.",
            "",
            "Interpretation: positive mean load reduction means the recommended three hours had lower measured average grid demand than that day's mean. Lower regret means the chosen window was closer to the lowest-load three-hour window found retrospectively from actual measurements. These are province-wide MW comparisons, not household usage or bill-savings estimates.",
            "",
            "Limitations: Halifax weather is a single-location proxy for province-wide load; 2025 has a documented OASIS data gap; this day-level selection proxy is not a common-issue-time rolling forecast replay; the score and selection logic mirror the current Flutter logic but do not exercise Flutter UI/provider behavior; results are not household usage or bill-savings estimates. Rate schedules omit holidays, matching the current app service.",
        ]
    )
    output_text = "\n".join(report)
    print("\n" + output_text)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output_text + "\n", encoding="utf-8")
        print(f"\nWrote report to {args.output}")


if __name__ == "__main__":
    main()
