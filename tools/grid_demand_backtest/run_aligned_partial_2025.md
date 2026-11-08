# Run-aligned Save More forecast backtest

- Profile training year: 2024; held-out OASIS year: 2025.
- Scored forecast run dates: 2025-01-01 through 2025-03-29.
- Daily runs: 88, issued 06:00 UTC; assumed available six hours later.
- Forecast source: Open-Meteo Single Runs API, ECMWF IFS HRES 9 km, Halifax.
- Training 90th-percentile peak threshold: 1706.2 MW.
- OASIS skipped rows/timestamps: training=48, test=647.
- Forecast valid times are converted to Halifax local time before app scoring and OASIS matching.

This mirrors the app's bundled historical profile and temperature adjustment with complete individual weather runs. The live app currently uses Open-Meteo's default model selection, so IFS validates the scoring logic with IFS weather, not the exact live weather feed.

## Hourly score and peak-flag performance

Observed peak is load >= the profile-year 90th percentile; predicted peak is score >=70. Score MAE uses percentile points.

| Lead from assumed availability | Matched hours | Score MAE | Peak precision | Peak recall | Peak F1 |
|---|---:|---:|---:|---:|---:|
| 0-24h | 2,065 | 7.0 | 0.504 | 1.000 | 0.670 |
| 24-72h | 4,121 | 6.7 | 0.505 | 1.000 | 0.671 |
| 72-168h | 5,614 | 6.5 | 0.516 | 1.000 | 0.680 |

## Peak-period card check

The app selects the highest-average consecutive 3-hour block, regardless of demand level. If no such block exists, it selects the highest-scoring available hour.

| Runs | Mean card duration (hours) | Runs with card >24h | Card hours at/above top-decile load | Mean card-window load (MW) | Mean 7-day load (MW) |
|---:|---:|---:|---:|---:|---:|
| 88 | 3.0 | 0.0% | 66.7% | 1820.1 | 1677.1 |

## Next-24-hour appliance-window check

Each choice mirrors the app's lowest-score consecutive three hours, with selected-plan rate as a tie-break. Only windows with all 24 measured hours are counted. Reduction compares the selected window with the same rolling 24-hour mean; regret compares with the measured best three-hour window.

| Plan | Complete windows | Chosen window below 24h mean | Mean reduction vs 24h mean (MW) | Regret vs measured best 3h (MW) |
|---|---:|---:|---:|---:|
| Standard Residential (flat) | 85 | 92.9% | 119.5 | 41.2 |
| Time-of-Day | 85 | 92.9% | 119.5 | 41.2 |
| Time-of-Use | 85 | 92.9% | 119.5 | 41.2 |

## Limits

Results are province-wide MW comparisons, not household savings. Halifax is a single weather proxy. The live app does not explicitly select IFS. One 06 UTC run per day models one decision time, not every time a user opens the app. The six-hour availability delay is conservative. Incomplete and DST OASIS days are omitted.
