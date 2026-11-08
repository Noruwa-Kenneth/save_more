# Save More grid-demand backtest

- Training years: 2024
- Held-out test years: 2025
- Demand source: Nova Scotia Power OASIS hourly load, MW.
- Weather source: Open-Meteo Previous Runs, gfs_seamless, Halifax coordinates.
- Training 90th-percentile peak threshold: 1706.2 MW.
- Incomplete days (including daylight-saving transition days) and malformed OASIS rows are omitted to avoid ambiguous clock-time joins.
- Weather inputs are archived forecasts at fixed lead times, not observed future weather.

The weather model adds a single heating-degree slope fitted only on the training years to the month/hour/weekday baseline. It is a transparent benchmark, not a production model.

| Test year | Lead | Matched hours | Baseline MAE MW | Weather MAE MW | Baseline WAPE | Weather WAPE | Baseline peak F1 | Weather peak F1 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2025 | 1 | 8,112 | 98.9 | 89.4 | 7.54% | 6.82% | 0.532 | 0.695 |
| 2025 | 3 | 8,112 | 98.9 | 89.8 | 7.54% | 6.85% | 0.532 | 0.692 |
| 2025 | 7 | 8,112 | 98.9 | 93.2 | 7.54% | 7.11% | 0.532 | 0.644 |

## Flutter app scoring logic

The app-mirror score averages training load for the same month, hour, and weekday/weekend type, ranks that expected load against the training load distribution, then applies the app's temperature adjustments (+4 below 5°C, +8 below 0°C, +12 below -10°C). Its output is capped at 100. No test-year load is used to build the profile.

App-score MAE compares the app's 0–100 score with the percentile rank of the measured test-hour load in the training distribution. For peak detection, app scores of 70 or higher are compared with measured loads at or above the training 90th-percentile MW threshold.

| Test year | Lead | App score MAE (points) | Peak precision | Peak recall | Peak F1 |
|---:|---:|---:|---:|---:|---:|
| 2025 | 1 | 8.1 | 0.467 | 0.999 | 0.636 |
| 2025 | 3 | 8.1 | 0.466 | 0.999 | 0.636 |
| 2025 | 7 | 8.2 | 0.466 | 1.000 | 0.635 |

## Appliance-window offline check

For every complete test calendar day, this mirrors the app's selection rule over that day's 24 hourly forecast scores: choose the consecutive three-hour window with the lowest average forecast score, breaking ties with the selected plan's average hourly rate. It then compares that chosen window with the OASIS load measured for those same hours.

This is a per-calendar-day offline proxy, not an exact replay of the app's rolling next-24-hour recommendation. Open-Meteo Previous Runs supplies fixed-lead values for each valid hour, rather than one complete forecast run issued at a common time. The test also considers only windows contained within each calendar day, so it cannot select a window that crosses midnight.

| Test year | Lead | Plan | Complete days | Windows below daily mean | Mean load reduction vs daily mean (MW) | Mean regret vs measured best 3h (MW) |
|---:|---:|---|---:|---:|---:|---:|
| 2025 | 1 | Standard Residential (flat) | 338 | 97.6% | 152.2 | 15.5 |
| 2025 | 1 | Time-of-Day | 338 | 97.6% | 152.2 | 15.5 |
| 2025 | 1 | Time-of-Use | 338 | 97.6% | 152.2 | 15.5 |
| 2025 | 3 | Standard Residential (flat) | 338 | 97.9% | 151.5 | 16.1 |
| 2025 | 3 | Time-of-Day | 338 | 97.9% | 151.5 | 16.1 |
| 2025 | 3 | Time-of-Use | 338 | 97.9% | 151.5 | 16.1 |
| 2025 | 7 | Standard Residential (flat) | 338 | 98.2% | 152.6 | 15.0 |
| 2025 | 7 | Time-of-Day | 338 | 98.2% | 152.6 | 15.0 |
| 2025 | 7 | Time-of-Use | 338 | 98.2% | 152.6 | 15.0 |

Interpretation: lower MAE/WAPE is better; higher peak F1 is better. The weather adjustment should be considered useful only if it beats the baseline across held-out years and lead times, not just one row.
The app score MAE is measured in percentile points, not MW. Its peak precision, recall, and F1 evaluate the app's >=70 high-demand threshold against measured top-decile hours; these are not overall accuracy percentages.

Interpretation: positive mean load reduction means the recommended three hours had lower measured average grid demand than that day's mean. Lower regret means the chosen window was closer to the lowest-load three-hour window found retrospectively from actual measurements. These are province-wide MW comparisons, not household usage or bill-savings estimates.

Limitations: Halifax weather is a single-location proxy for province-wide load; 2025 has a documented OASIS data gap; this day-level selection proxy is not a common-issue-time rolling forecast replay; the score and selection logic mirror the current Flutter logic but do not exercise Flutter UI/provider behavior; results are not household usage or bill-savings estimates. Rate schedules omit holidays, matching the current app service.
