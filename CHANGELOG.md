1.0.0: Initial package.

1.0.1: Timezone package to dev dependencies.

1.0.2: Minor import fix.

1.0.3: Null safety.

1.0.4: Day of year native DateTime implementation in DateUtils.

1.0.5: Example added.

1.0.6: Fix for day of year.

1.0.7: Next and previous prayer do not return null even in the case of before fajr/after isha.

1.0.8: Bug fix for UmmAlQura and Qatar calculation methods.

1.1.0: Exposed highLatitudeRule, madhab, adjustments, methodAdjustment to CalculationParameters. Updated timezone package. New lint rules, fixed some static methods naming convention. Turkey is now Turkiye.

1.1.1: Fixed documentation, calculation parameters bug fix.

1.1.2: Explicit method, fajrAngle, ishaAngle for CalculationParameters; coordinates, date, params for PrayerTimes.

## 1.2.0

### Breaking changes

- **Polar circle default:** `CalculationMethod.polarCircleResolution` now defaults to `PolarCircleResolution.unresolved` (matching adhan-js). Previously `aqrabBalad` was applied automatically and could shift mid-latitude results. Opt in with `copyWith(polarCircleResolution: PolarCircleResolution.aqrabBalad)`.
- **`nextPrayer` after Isha:** Returns `Prayer.fajrAfter` instead of `Prayer.fajr`. Use `nextPrayerTime()` or `timeForPrayer(Prayer.fajrAfter)` for tomorrow's Fajr instant.
- **`Coordinates`:** Factory constructor validates lat/lng; `Coordinates(...)` is no longer supported. Use `Coordinates(lat, lng)`.

### Added

- `PrayerTimes.nextPrayerTime({DateTime? time})` — returns the UTC instant of the next prayer.
- `PrayerTimes.sunset` — solar sunset (same instant as pre-angle maghrib).
- `PrayerTimes.estimatedPrayers` — unmodifiable set of prayers whose times used a safety fallback.
- `CalculationMethod.morocco` / `Morocco()` preset.
- `MIGRATION.md` for adhan-js and 1.1.x upgrades.
- IDL correction in astronomical transit calculation (parity with adhan-js).

### Changed

- `copyWith` on calculation method presets preserves runtime type (e.g. `MoonsightingCommittee.copyWith` stays `MoonsightingCommittee`).
- `fromJson` applies field overrides onto preset subclasses instead of discarding custom adjustments.
- Moonsighting Committee Fajr/Isha handling at latitude ≥ 55° aligned with adhan-js.
- Polar resolution triggers only when solar times are invalid and a non-`unresolved` resolver is set.
- `formatForDisplay` documents UTC output and accepts an optional `convert` callback for local display.
- Removed static cache from `SunnahTimes`.

### Fixed

- `fajrAfter` cross-day instant: `sunriseAfterAfter` (date+2) was stamped with date+1 calendar components, breaking night-length math and `fajrAfter` vs next-day `fajr` parity.
- Utility extensions (`getCurrentPrayer`, `getNextPrayer`, `timeUntilNextPrayer`) delegate to `PrayerTimes` and include sunrise / `fajrAfter` in the chain.
- `estimatedPrayers`, `ishaBefore`, and `fajrAfter` included in `PrayerTimes` equality.
- Coordinate validation throws consistently (constructor, `fromJson`, `Qibla.qibla`).
