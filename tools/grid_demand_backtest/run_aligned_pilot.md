# Run-aligned Save More forecast backtest

- Profile training year: 2024; held-out OASIS year: 2025.
- Daily runs: 14, issued 06:00 UTC; assumed available six hours later.
- Forecast source: Open-Meteo Single Runs API, ECMWF IFS HRES 9 km, Halifax.
- Training 90th-percentile peak threshold: 1706.2 MW.
- OASIS skipped rows/timestamps: training=48, test=647.
- Forecast valid times are converted to Halifax local time before app scoring and OASIS matching.

This mirrors the app's bundled historical profile and temperature adjustment with complete individual weather runs. The live app currently uses Open-Meteo's default model selection, so IFS validates the scoring logic with IFS weather, not the exact live weather feed.

## Hourly score and peak-flag performance

Observed peak is load >= the profile-year 90th percentile; predicted peak is score >=70. Score MAE uses percentile points.

| Lead from assumed availability | Matched hours | Score MAE | Peak precision | Peak recall | Peak F1 |
|---|---:|---:|---:|---:|---:|
| 0-24h | 336 | 8.3 | 0.470 | 1.000 | 0.640 |
| 24-72h | 672 | 6.3 | 0.554 | 1.000 | 0.713 |
| 72-168h | 938 | 5.4 | 0.634 | 1.000 | 0.776 |

## Peak-period card check

The app selects the highest-average consecutive 3-hour block, regardless of demand level. If no such block exists, it selects the highest-scoring available hour.

| Runs | Mean card duration (hours) | Runs with card >24h | Card hours at/above top-decile load | Mean card-window load (MW) | Mean 7-day load (MW) |
|---:|---:|---:|---:|---:|---:|
| 14 | 3.0 | 0.0% | 73.8% | 1780.8 | 1718.8 |

## Next-24-hour appliance-window check

Each choice mirrors the app's lowest-score consecutive three hours, with selected-plan rate as a tie-break. Only windows with all 24 measured hours are counted. Reduction compares the selected window with the same rolling 24-hour mean; regret compares with the measured best three-hour window.

| Plan | Complete windows | Chosen window below 24h mean | Mean reduction vs 24h mean (MW) | Regret vs measured best 3h (MW) |
|---|---:|---:|---:|---:|
| Standard Residential (flat) | 14 | 92.9% | 152.3 | 21.0 |
| Time-of-Day | 14 | 92.9% | 152.3 | 21.0 |
| Time-of-Use | 14 | 92.9% | 152.3 | 21.0 |

## Limits

Results are province-wide MW comparisons, not household savings. Halifax is a single weather proxy. The live app does not explicitly select IFS. One 06 UTC run per day models one decision time, not every time a user opens the app. The six-hour availability delay is conservative. Incomplete and DST OASIS days are omitted.
