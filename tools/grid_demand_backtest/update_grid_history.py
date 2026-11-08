#!/usr/bin/env python3
"""Refresh the app's bundled Nova Scotia grid-demand history from OASIS.

Downloads the most recent consecutive years listed by Nova Scotia Power,
validates their coverage, then atomically replaces the app CSV and metadata.
The existing app assets are left untouched if a download or validation fails.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import io
import json
import os
from pathlib import Path
import tempfile
import time
from urllib.parse import urljoin
from urllib.request import Request, urlopen
from zoneinfo import ZoneInfo

from backtest import OASIS_URL, OasisLinkParser, parse_oasis_rows

USER_AGENT = "SaveMore-grid-history-updater/1.0"
TIMEZONE = ZoneInfo("America/Halifax")
DEFAULT_LOOKBACK_YEARS = 3
MINIMUM_COVERAGE_RATIO = 0.70
DEFAULT_MAX_STALE_DAYS = 75


def download(url: str, attempts: int = 4) -> bytes:
    """Fetch a non-empty response, retrying transient network errors."""
    request = Request(url, headers={"User-Agent": USER_AGENT})
    last_error: Exception | None = None
    for attempt in range(attempts):
        try:
            with urlopen(request, timeout=30) as response:
                payload = response.read()
            if not payload:
                raise RuntimeError(f"The download from {url} was empty.")
            return payload
        except (OSError, TimeoutError, RuntimeError) as error:
            last_error = error
            if attempt + 1 < attempts:
                delay = 2**attempt
                print(f"Download failed; retrying in {delay} seconds: {error}", flush=True)
                time.sleep(delay)
    raise RuntimeError(f"Could not download {url}: {last_error}")


def fetch_year_links() -> dict[int, str]:
    parser = OasisLinkParser()
    parser.feed(download(OASIS_URL).decode("utf-8", "replace"))
    if not parser.csv_by_year:
        raise RuntimeError("No yearly CSV links were found on the OASIS page.")
    return parser.csv_by_year


def expected_hours(year: int, now_local: dt.datetime) -> int:
    last_day = dt.date(year, 12, 31)
    if year == now_local.year:
        last_day = now_local.date() - dt.timedelta(days=1)
    if last_day.year < year:
        return 0
    start = dt.date(year, 1, 1)
    # Include both endpoints: a full non-leap year has 365 * 24 hours, and a
    # leap year has 366 * 24. For the current year, last_day is yesterday.
    return ((last_day - start).days + 1) * 24


def write_atomically(path: Path, contents: str) -> None:
    """Write a same-directory temporary file, then replace the destination."""
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", newline="", dir=path.parent,
            prefix=f".{path.name}.", suffix=".tmp", delete=False,
        ) as temporary:
            temporary.write(contents)
            temporary_path = Path(temporary.name)
        os.replace(temporary_path, path)
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--lookback-years", type=int, default=DEFAULT_LOOKBACK_YEARS,
        help="Number of newest consecutive OASIS years to bundle (default: 3).",
    )
    parser.add_argument(
        "--max-stale-days", type=int, default=DEFAULT_MAX_STALE_DAYS,
        help="Refuse to replace app assets when the newest reading is older than this.",
    )
    parser.add_argument(
        "--allow-stale", action="store_true",
        help="Allow an old source file to be bundled, while recording a warning.",
    )
    parser.add_argument(
        "--output-dir", type=Path,
        default=Path(__file__).resolve().parents[2] / "assets" / "data",
        help="Destination directory for app assets.",
    )
    args = parser.parse_args()
    if args.lookback_years < 1:
        parser.error("--lookback-years must be at least 1.")

    now_utc = dt.datetime.now(dt.timezone.utc)
    now_local = now_utc.astimezone(TIMEZONE).replace(tzinfo=None)
    links = fetch_year_links()
    latest_listed_year = max(links)
    years = list(range(latest_listed_year - args.lookback_years + 1,
                       latest_listed_year + 1))
    missing = [year for year in years if year not in links]
    if missing:
        raise RuntimeError(f"OASIS is missing consecutive year files: {missing}")

    combined: dict[str, float] = {}
    per_year: list[dict[str, int]] = []
    for year in years:
        url = urljoin(OASIS_URL, links[year])
        demand, skipped = parse_oasis_rows(download(url))
        expected = expected_hours(year, now_local)
        ratio = len(demand) / expected if expected else 0.0
        if not demand or ratio < MINIMUM_COVERAGE_RATIO:
            raise RuntimeError(
                f"OASIS {year} coverage is too low: {len(demand):,} valid hours "
                f"of about {expected:,} expected ({ratio:.1%}). Existing assets were kept."
            )
        duplicates = combined.keys() & demand.keys()
        if duplicates:
            raise RuntimeError(
                f"Found {len(duplicates)} duplicate timestamps while combining years."
            )
        combined.update(demand)
        per_year.append({
            "year": year,
            "valid_hours": len(demand),
            "expected_hours": expected,
            "skipped_rows_or_hours": skipped,
        })
        print(
            f"Validated {year}: {len(demand):,}/{expected:,} expected hours; "
            f"{skipped:,} rows/hours skipped.",
            flush=True,
        )

    latest_observation = max(combined)
    latest_time = dt.datetime.strptime(latest_observation, "%Y-%m-%dT%H:%M")
    lag_days = (now_local.date() - latest_time.date()).days
    quality_warnings = []
    if lag_days > args.max_stale_days:
        message = (
            f"Newest OASIS reading is {lag_days} days old, beyond the "
            f"{args.max_stale_days}-day update limit."
        )
        if not args.allow_stale:
            raise RuntimeError(f"{message} Existing assets were kept. Use --allow-stale to override.")
        quality_warnings.append(message)
    if any(year["skipped_rows_or_hours"] for year in per_year):
        quality_warnings.append(
            "Some OASIS rows or incomplete clock-change hours were skipped; see per-year counts."
        )

    ordered = sorted(combined.items())
    csv_buffer = io.StringIO(newline="")
    writer = csv.writer(csv_buffer, lineterminator="\n")
    writer.writerow(["Date/time", "Load [MW]"])
    for timestamp, demand_mw in ordered:
        writer.writerow([timestamp.replace("T", " "), f"{demand_mw:.3f}"])

    metadata = {
        "source": OASIS_URL,
        "generated_at_utc": now_utc.isoformat(timespec="seconds"),
        "timezone": "America/Halifax (source timestamps have no UTC offset)",
        "included_years": years,
        "first_observation": ordered[0][0],
        "latest_observation": latest_observation,
        "latest_observation_age_days": lag_days,
        "sample_count": len(ordered),
        "per_year": per_year,
        "quality_warnings": quality_warnings,
    }
    output_csv = args.output_dir / "ns_load_history.csv"
    output_metadata = args.output_dir / "ns_load_history_metadata.json"
    write_atomically(output_csv, csv_buffer.getvalue())
    write_atomically(
        output_metadata,
        json.dumps(metadata, indent=2, ensure_ascii=False) + "\n",
    )
    print(f"Updated {output_csv} with {len(ordered):,} readings through {latest_observation}.")
    print(f"Update metadata: {output_metadata}")
    for warning in quality_warnings:
        print(f"Warning: {warning}")


if __name__ == "__main__":
    main()
