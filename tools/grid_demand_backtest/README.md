# Grid-demand backtest

This standalone Python tool evaluates Save More's hourly demand score against
measured hourly province-wide Nova Scotia load, and compares it with two
baselines:

1. A seasonal baseline: average load for the same month, hour, and weekday/weekend type.
2. A weather-adjusted MW benchmark: the baseline plus a heating-degree coefficient learned from archived GFS forecasts and measured load in the training years.
3. The app-mirror score: the historical profile percentile used by `GridDemandProfileService`, followed by the same temperature-based score adjustment used by `PeakPredictionService`.

It tests on later years and reports load error for the MW models, plus app-score error and detection of measured top-decile peak hours (precision, recall, and F1) for all models. It also mirrors the app's three-hour appliance-window choice and checks the chosen hours against measured load. The weather archive supplies forecasts at fixed 1-, 3-, and 7-day lead times, so the test does not use observed future weather.

The generated report includes both annual and meteorological-season metrics for each held-out year and lead time. Seasonal tables include the number of observed hours above the training-period peak threshold, so zero peak F1 in a season with no observed peak hours is not misread as evidence of missed events.

## Refresh the app's bundled grid history

Run this from the repository root when you want to update the app's historical profile:

```powershell
python tools/grid_demand_backtest/update_grid_history.py
```

The updater downloads the newest three consecutive annual CSVs listed on the official OASIS page, retries transient download failures, filters incomplete/DST-ambiguous days using the backtest parser, checks per-year coverage and source freshness, and writes `assets/data/ns_load_history.csv` plus a metadata sidecar. It only replaces the assets after all years pass validation. If the newest available OASIS reading is older than 75 days, it stops without replacing the current files; `--allow-stale` explicitly overrides that guard and records the warning. The metadata records the source URL, generation time, covered years, date range, valid sample counts, skipped rows, and warnings.

OASIS publishes hourly load files after the reporting month, so the newest measurement will normally lag current time. The updater reports that age rather than treating historical load as real-time demand. The app refreshes weather data from Open-Meteo when the forecast is fetched; the grid profile is bundled at build time and requires rerunning this updater and rebuilding the app to change.

## Run

From the repository root, with Python 3.10 or newer and internet access:

```powershell
python tools/grid_demand_backtest/backtest.py
```

The default split trains on 2022–2023 and tests on 2024–2025. Input files are cached under the system temporary directory in `save_more_grid_backtest`; they are not copied into the app or committed. The app-mirror uses the same scoring formula but builds its historical profile only from the selected training years, avoiding test-year leakage. To check the current bundled 2024 profile against the held-out 2025 measurements, run:

```powershell
python tools/grid_demand_backtest/backtest.py --train-years 2024 --test-years 2025
```

The default-split results are in [`results.md`](results.md). The current bundled-profile check is in [`current_profile_results.md`](current_profile_results.md).

For an issue-time replay using complete individual forecast runs, run:

```powershell
python tools/grid_demand_backtest/run_aligned_backtest.py --output tools/grid_demand_backtest/run_aligned_2025.md
```

This uses the bundled 2024 demand profile, held-out 2025 OASIS measurements, and one ECMWF IFS HRES run per day at 06:00 UTC. It conservatively treats the run as available six hours after initialization. Archived weather responses are cached separately in the system temp directory. To validate a short date range first:

```powershell
python tools/grid_demand_backtest/run_aligned_backtest.py --start-date 2025-01-01 --end-date 2025-01-14 --output tools/grid_demand_backtest/run_aligned_pilot.md
```

The current run-aligned partial-year report is in [`run_aligned_partial_2025.md`](run_aligned_partial_2025.md), covering January 1 through March 29, 2025. A full-year report has not been produced yet because the archived forecast download stopped accepting requests after those 88 daily runs were cached. The current app uses Open-Meteo's default model selection, so IFS is a controlled candidate-model validation until the app's live model is explicitly matched.

The appliance-window section reports the share of chosen windows below that day's actual mean grid demand, average reduction versus the daily mean in MW, and the gap from the retrospectively lowest-load three-hour window. These are province-wide load comparisons, not household savings.

The forecast's Peak period card uses the highest-average consecutive three-hour block in the requested forecast range, even when scores stay below the high-demand threshold. It falls back to the highest-scoring hour only when the forecast has no complete consecutive three-hour block. For seven-day forecasts, the card includes dates so a short interval is clear.

To refresh cached files or save a report:

```powershell
python tools/grid_demand_backtest/backtest.py --refresh --output tools/grid_demand_backtest/results.md
```

You can choose a different chronological split with `--train-years` and `--test-years`.

## Data and limits

- Demand is hourly total Nova Scotia grid load in MW from the [Nova Scotia Power OASIS report](https://www.nspower.ca/oasis/monthly-reports/hourly-total-net-nova-scotia-load). The report notes that 2025-04-01 through 2025-04-25 was lost in a cybersecurity incident.
- Weather is archived NCEP GFS forecast temperature from Open-Meteo's [Previous Runs API](https://open-meteo.com/en/docs/previous-runs-api). The forecast is requested for Halifax as a single-location proxy for province-wide load.
- OASIS timestamps do not include UTC offsets. Ambiguous repeated wall-clock timestamps and unmatched hours are omitted from scoring.
- The weather model is intentionally simple and is for comparison only. Better scores on this backtest do not establish future performance in all conditions, nor do MW results estimate a household's bill savings.
- Open-Meteo Previous Runs provides a fixed-lead forecast value per valid hour, not a complete forecast issued at one common time. The appliance-window result is therefore a per-calendar-day offline proxy, not an exact replay of the app's rolling next-24-hour selection; it also omits windows crossing midnight.
- The Single Runs API can replay an individual ECMWF IFS HRES forecast run from March 2024, but most other individual model runs are archived only from April 2026. Run-aligned backtesting is therefore limited to IFS over the 2024–2025 holdout period and does not represent the app's unspecified live Best Match model selection.
- The app-mirror does not exercise Flutter UI/provider behavior. A high-demand detection F1 is not overall accuracy; precision and recall should be considered separately.
