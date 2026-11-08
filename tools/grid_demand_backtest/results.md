# Save More grid-demand backtest

- Training years: 2022, 2023
- Held-out test years: 2024, 2025
- Demand source: Nova Scotia Power OASIS hourly load, MW.
- Weather source: Open-Meteo Previous Runs, gfs_seamless, Halifax coordinates.
- Training 90th-percentile peak threshold: 1671.3 MW.
- Incomplete days (including daylight-saving transition days) and malformed OASIS rows are omitted to avoid ambiguous clock-time joins.
- Weather inputs are archived forecasts at fixed lead times, not observed future weather.

The weather model adds a single heating-degree slope fitted only on the training years to the month/hour/weekday baseline. It is a transparent benchmark, not a production model.

| Test year | Lead | Matched hours | Baseline MAE MW | Weather MAE MW | Baseline WAPE | Weather WAPE | Baseline peak F1 | Weather peak F1 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2024 | 1 | 8,295 | 86.7 | 81.8 | 6.78% | 6.39% | 0.536 | 0.644 |
| 2024 | 3 | 8,247 | 86.5 | 81.9 | 6.78% | 6.42% | 0.531 | 0.620 |
| 2024 | 7 | 8,151 | 86.2 | 84.5 | 6.78% | 6.65% | 0.519 | 0.570 |
| 2025 | 1 | 8,112 | 110.2 | 96.2 | 8.40% | 7.33% | 0.534 | 0.729 |
| 2025 | 3 | 8,112 | 110.2 | 97.2 | 8.40% | 7.41% | 0.534 | 0.709 |
| 2025 | 7 | 8,112 | 110.2 | 101.4 | 8.40% | 7.73% | 0.534 | 0.665 |

## Held-out seasonal performance

Seasons use meteorological months: winter (Dec–Feb), spring (Mar–May), summer (Jun–Aug), and fall (Sep–Nov). Weather coefficients and the peak threshold remain fitted only on the training years. A season with zero matched hours is shown as `nan`; incomplete and unavailable source data reduce seasonal sample counts.

| Test year | Season | Lead | Matched hours | Observed peak hours | Baseline MAE MW | Weather MAE MW | Baseline WAPE | Weather WAPE | Baseline peak F1 | Weather peak F1 |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2024 | Winter | 1 | 1,743 | 795 | 131.2 | 113.2 | 8.00% | 6.90% | 0.563 | 0.666 |
| 2024 | Winter | 3 | 1,695 | 767 | 131.9 | 115.6 | 8.04% | 7.05% | 0.559 | 0.648 |
| 2024 | Winter | 7 | 1,599 | 706 | 132.9 | 125.0 | 8.13% | 7.64% | 0.549 | 0.597 |
| 2024 | Spring | 1 | 2,184 | 66 | 102.7 | 101.5 | 8.06% | 7.96% | 0.000 | 0.308 |
| 2024 | Spring | 3 | 2,184 | 66 | 102.7 | 100.9 | 8.06% | 7.91% | 0.000 | 0.202 |
| 2024 | Spring | 7 | 2,184 | 66 | 102.7 | 102.8 | 8.06% | 8.06% | 0.000 | 0.145 |
| 2024 | Summer | 1 | 2,208 | 0 | 53.1 | 53.0 | 4.80% | 4.80% | 0.000 | 0.000 |
| 2024 | Summer | 3 | 2,208 | 0 | 53.1 | 53.0 | 4.80% | 4.80% | 0.000 | 0.000 |
| 2024 | Summer | 7 | 2,208 | 0 | 53.1 | 53.0 | 4.80% | 4.80% | 0.000 | 0.000 |
| 2024 | Fall | 1 | 2,160 | 1 | 68.8 | 65.8 | 5.90% | 5.64% | 0.000 | 0.000 |
| 2024 | Fall | 3 | 2,160 | 1 | 68.8 | 65.9 | 5.90% | 5.65% | 0.000 | 0.000 |
| 2024 | Fall | 7 | 2,160 | 1 | 68.8 | 68.2 | 5.90% | 5.84% | 0.000 | 0.000 |
| 2025 | Winter | 1 | 2,160 | 1,443 | 202.9 | 151.0 | 11.56% | 8.60% | 0.549 | 0.738 |
| 2025 | Winter | 3 | 2,160 | 1,443 | 202.9 | 155.3 | 11.56% | 8.84% | 0.549 | 0.719 |
| 2025 | Winter | 7 | 2,160 | 1,443 | 202.9 | 170.6 | 11.56% | 9.71% | 0.549 | 0.675 |
| 2025 | Spring | 1 | 1,560 | 59 | 94.9 | 98.3 | 7.49% | 7.77% | 0.000 | 0.525 |
| 2025 | Spring | 3 | 1,560 | 59 | 94.9 | 97.7 | 7.49% | 7.72% | 0.000 | 0.463 |
| 2025 | Spring | 7 | 1,560 | 59 | 94.9 | 96.7 | 7.49% | 7.63% | 0.000 | 0.373 |
| 2025 | Summer | 1 | 2,208 | 0 | 66.7 | 66.7 | 6.25% | 6.24% | 0.000 | 0.000 |
| 2025 | Summer | 3 | 2,208 | 0 | 66.7 | 66.7 | 6.25% | 6.25% | 0.000 | 0.000 |
| 2025 | Summer | 7 | 2,208 | 0 | 66.7 | 66.6 | 6.25% | 6.24% | 0.000 | 0.000 |
| 2025 | Fall | 1 | 2,184 | 3 | 73.3 | 70.3 | 6.37% | 6.11% | 0.000 | 0.000 |
| 2025 | Fall | 3 | 2,184 | 3 | 73.3 | 70.4 | 6.37% | 6.11% | 0.000 | 0.000 |
| 2025 | Fall | 7 | 2,184 | 3 | 73.3 | 71.7 | 6.37% | 6.23% | 0.000 | 0.000 |

## Held-out seasonal app-score performance

This table evaluates the app-mirror 0–100 score against measured load percentiles and checks its high-demand flag against the training-period top-decile MW threshold. Precision and recall are included because a single F1 or 'accuracy' percentage can hide false alarms or missed peak hours. Seasons with zero observed peak hours cannot meaningfully demonstrate peak recall; their zero F1 should not be read as the same kind of failure as a season with observed peaks.

| Test year | Season | Lead | Matched hours | Observed peak hours | Score MAE (points) | Peak precision | Peak recall | Peak F1 |
|---:|---|---:|---:|---:|---:|---:|---:|---:|
| 2024 | Winter | 1 | 1,743 | 795 | 7.8 | 0.474 | 1.000 | 0.643 |
| 2024 | Winter | 3 | 1,695 | 767 | 7.8 | 0.469 | 0.999 | 0.638 |
| 2024 | Winter | 7 | 1,599 | 706 | 8.6 | 0.465 | 0.994 | 0.634 |
| 2024 | Spring | 1 | 2,184 | 66 | 11.9 | 0.081 | 0.909 | 0.149 |
| 2024 | Spring | 3 | 2,184 | 66 | 11.7 | 0.082 | 0.909 | 0.150 |
| 2024 | Spring | 7 | 2,184 | 66 | 12.1 | 0.083 | 0.909 | 0.152 |
| 2024 | Summer | 1 | 2,208 | 0 | 7.4 | 0.000 | 0.000 | 0.000 |
| 2024 | Summer | 3 | 2,208 | 0 | 7.4 | 0.000 | 0.000 | 0.000 |
| 2024 | Summer | 7 | 2,208 | 0 | 7.4 | 0.000 | 0.000 | 0.000 |
| 2024 | Fall | 1 | 2,160 | 1 | 8.7 | 0.004 | 1.000 | 0.009 |
| 2024 | Fall | 3 | 2,160 | 1 | 8.6 | 0.004 | 1.000 | 0.009 |
| 2024 | Fall | 7 | 2,160 | 1 | 8.9 | 0.004 | 1.000 | 0.008 |
| 2025 | Winter | 1 | 2,160 | 1,443 | 6.2 | 0.688 | 0.999 | 0.814 |
| 2025 | Winter | 3 | 2,160 | 1,443 | 6.4 | 0.689 | 0.997 | 0.815 |
| 2025 | Winter | 7 | 2,160 | 1,443 | 6.8 | 0.683 | 0.989 | 0.808 |
| 2025 | Spring | 1 | 1,560 | 59 | 11.3 | 0.087 | 1.000 | 0.160 |
| 2025 | Spring | 3 | 1,560 | 59 | 11.2 | 0.087 | 1.000 | 0.160 |
| 2025 | Spring | 7 | 1,560 | 59 | 11.2 | 0.088 | 1.000 | 0.161 |
| 2025 | Summer | 1 | 2,208 | 0 | 9.1 | 0.000 | 0.000 | 0.000 |
| 2025 | Summer | 3 | 2,208 | 0 | 9.1 | 0.000 | 0.000 | 0.000 |
| 2025 | Summer | 7 | 2,208 | 0 | 9.1 | 0.000 | 0.000 | 0.000 |
| 2025 | Fall | 1 | 2,184 | 3 | 9.0 | 0.012 | 1.000 | 0.023 |
| 2025 | Fall | 3 | 2,184 | 3 | 9.0 | 0.012 | 1.000 | 0.024 |
| 2025 | Fall | 7 | 2,184 | 3 | 9.1 | 0.012 | 1.000 | 0.024 |

## Flutter app scoring logic

The app-mirror score averages training load for the same month, hour, and weekday/weekend type, ranks that expected load against the training load distribution, then applies the app's temperature adjustments (+4 below 5°C, +8 below 0°C, +12 below -10°C). Its output is capped at 100. No test-year load is used to build the profile.

App-score MAE compares the app's 0–100 score with the percentile rank of the measured test-hour load in the training distribution. For peak detection, app scores of 70 or higher are compared with measured loads at or above the training 90th-percentile MW threshold.

| Test year | Lead | App score MAE (points) | Peak precision | Peak recall | Peak F1 |
|---:|---:|---:|---:|---:|---:|
| 2024 | 1 | 9.0 | 0.323 | 0.993 | 0.488 |
| 2024 | 3 | 9.0 | 0.318 | 0.992 | 0.482 |
| 2024 | 7 | 9.3 | 0.308 | 0.987 | 0.470 |
| 2025 | 1 | 8.7 | 0.496 | 0.999 | 0.663 |
| 2025 | 3 | 8.7 | 0.498 | 0.997 | 0.664 |
| 2025 | 7 | 8.9 | 0.495 | 0.989 | 0.660 |

## Appliance-window offline check

For every complete test calendar day, this mirrors the app's selection rule over that day's 24 hourly forecast scores: choose the consecutive three-hour window with the lowest average forecast score, breaking ties with the selected plan's average hourly rate. It then compares that chosen window with the OASIS load measured for those same hours.

This is a per-calendar-day offline proxy, not an exact replay of the app's rolling next-24-hour recommendation. Open-Meteo Previous Runs supplies fixed-lead values for each valid hour, rather than one complete forecast run issued at a common time. The test also considers only windows contained within each calendar day, so it cannot select a window that crosses midnight.

| Test year | Lead | Plan | Complete days | Windows below daily mean | Mean load reduction vs daily mean (MW) | Mean regret vs measured best 3h (MW) |
|---:|---:|---|---:|---:|---:|---:|
| 2024 | 1 | Standard Residential (flat) | 345 | 98.0% | 148.0 | 14.4 |
| 2024 | 1 | Time-of-Day | 345 | 98.0% | 148.0 | 14.4 |
| 2024 | 1 | Time-of-Use | 345 | 98.0% | 148.0 | 14.4 |
| 2024 | 3 | Standard Residential (flat) | 343 | 98.3% | 149.6 | 12.7 |
| 2024 | 3 | Time-of-Day | 343 | 98.3% | 149.6 | 12.7 |
| 2024 | 3 | Time-of-Use | 343 | 98.3% | 149.6 | 12.7 |
| 2024 | 7 | Standard Residential (flat) | 339 | 97.9% | 147.0 | 15.6 |
| 2024 | 7 | Time-of-Day | 339 | 97.9% | 147.0 | 15.6 |
| 2024 | 7 | Time-of-Use | 339 | 97.9% | 147.0 | 15.6 |
| 2025 | 1 | Standard Residential (flat) | 338 | 97.0% | 151.6 | 16.1 |
| 2025 | 1 | Time-of-Day | 338 | 97.0% | 151.6 | 16.1 |
| 2025 | 1 | Time-of-Use | 338 | 97.0% | 151.6 | 16.1 |
| 2025 | 3 | Standard Residential (flat) | 338 | 97.3% | 151.1 | 16.6 |
| 2025 | 3 | Time-of-Day | 338 | 97.3% | 151.1 | 16.6 |
| 2025 | 3 | Time-of-Use | 338 | 97.3% | 151.1 | 16.6 |
| 2025 | 7 | Standard Residential (flat) | 338 | 97.0% | 149.9 | 17.7 |
| 2025 | 7 | Time-of-Day | 338 | 97.0% | 149.9 | 17.7 |
| 2025 | 7 | Time-of-Use | 338 | 97.0% | 149.9 | 17.7 |

Interpretation: lower MAE/WAPE is better; higher peak F1 is better. The weather adjustment should be considered useful only if it beats the baseline across held-out years and lead times, not just one row.
The app score MAE is measured in percentile points, not MW. Its peak precision, recall, and F1 evaluate the app's >=70 high-demand threshold against measured top-decile hours; these are not overall accuracy percentages.

Interpretation: positive mean load reduction means the recommended three hours had lower measured average grid demand than that day's mean. Lower regret means the chosen window was closer to the lowest-load three-hour window found retrospectively from actual measurements. These are province-wide MW comparisons, not household usage or bill-savings estimates.

Limitations: Halifax weather is a single-location proxy for province-wide load; 2025 has a documented OASIS data gap; this day-level selection proxy is not a common-issue-time rolling forecast replay; the score and selection logic mirror the current Flutter logic but do not exercise Flutter UI/provider behavior; results are not household usage or bill-savings estimates. Rate schedules omit holidays, matching the current app service.
