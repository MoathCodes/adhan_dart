# Adhan Dart

Adhan Dart is a well-tested library for calculating Islamic prayer times in Dart. It is an idiomatic Dart port of [Adhan](https://github.com/batoulapps/Adhan) (JavaScript, v4.x parity target).

This library provides:

* **High precision** — astronomical equations from [Astronomical Algorithms](http://www.willbell.com/math/mc1.htm) by Jean Meeus.
* **Type safety** — full null-safety with non-nullable prayer time results.
* **adhan-js parity** — UTC instant contract, polar defaults, and navigation semantics aligned with upstream.
* **Modern API** — immutable data, sealed-style presets, and `copyWith` customization.

## Installation

```yaml
dependencies:
  adhan_dart: ^1.2.0
```

For timezone conversion in apps, add [`timezone`](https://pub.dev/packages/timezone) separately (not a runtime dependency of this package).

## Quick start

```dart
import 'package:adhan_dart/adhan_dart.dart';

final coordinates = Coordinates(21.4225, 39.8262); // Mecca
final params = CalculationMethod.ummAlQura;

final prayerTimes = PrayerTimes(
  coordinates: coordinates,
  date: DateTime.now(),
  calculationMethod: params,
);

print('Fajr (UTC): ${prayerTimes.fajr}');
print('Next: ${prayerTimes.nextPrayer()} at ${prayerTimes.nextPrayerTime()}');
```

See [`example/lib/example.dart`](example/lib/example.dart) for full timezone conversion.

## UTC output contract

**All prayer times are UTC `DateTime` instants.** This matches adhan-js: the library computes solar events for the location's longitude and returns universal time. Fields like `.hour` and `.minute` are **UTC clock values**, not the location's local wall time.

Convert before displaying to users:

```dart
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

tz.initializeTimeZones();
final location = tz.getLocation('Asia/Riyadh');

final localFajr = tz.TZDateTime.from(prayerTimes.fajr, location);
```

Or use `formatForDisplay` with a conversion callback:

```dart
print(prayerTimes.formatForDisplay(
  convert: (utc) => tz.TZDateTime.from(utc, location),
));
```

Without conversion, `formatForDisplay` labels output as UTC. Avoid `.toLocal()` unless the device timezone equals the prayer location.

## Initialization

**Coordinates** — latitude and longitude in decimal degrees. Validated in the constructor (`-90…90`, `-180…180`):

```dart
final coordinates = Coordinates(35.78056, -78.6389);
```

**Date** — any `DateTime`; only the calendar date is used for the calculation. Dart months are 1-indexed (1 = January).

**Calculation method** — preset constants on `CalculationMethod` (see table below).

## Customizing parameters

Presets are immutable. Use `copyWith` to override madhab, adjustments, high-latitude rules, polar resolution, etc.:

```dart
final params = CalculationMethod.karachi.copyWith(
  madhab: Madhab.hanafi,
  adjustments: {Prayer.fajr: 2},
);
```

`copyWith` **preserves the preset subclass** — `CalculationMethod.moonsightingCommittee.copyWith(...)` remains a `MoonsightingCommittee`, so `is MoonsightingCommittee` checks keep working after customization.

## Prayer navigation

| Method | Description |
|--------|-------------|
| `currentPrayer({DateTime? time})` | Active prayer at `time` (default: now) |
| `nextPrayer({DateTime? time})` | Next prayer after `time` |
| `nextPrayerTime({DateTime? time})` | UTC instant of the next prayer |
| `timeForPrayer(Prayer prayer)` | UTC instant for any `Prayer` value |

The chain includes **sunrise** between Fajr and Dhuhr. For cross-day boundaries:

* Before today's Fajr → `currentPrayer()` returns `Prayer.ishaBefore` (previous day's Isha).
* After today's Isha → `nextPrayer()` returns `Prayer.fajrAfter` (next day's Fajr), **not** `Prayer.fajr`.

```dart
if (prayerTimes.nextPrayer() == Prayer.fajrAfter) {
  final tomorrowFajr = prayerTimes.fajrAfter;
}
// or simply:
final nextInstant = prayerTimes.nextPrayerTime();
```

In adhan-js this edge case uses `Prayer.None`; see [MIGRATION.md](MIGRATION.md).

## Estimated times

When fallbacks produce a prayer time (polar 45° emergency path, etc.), those prayers appear in `estimatedPrayers`:

```dart
if (prayerTimes.estimatedPrayers.contains(Prayer.fajr)) {
  // show indicator — time used a safety estimate
}
```

The set is unmodifiable.

## Calculation methods

| Method | Description |
|--------|-------------|
| `CalculationMethod.muslimWorldLeague` | Muslim World League |
| `CalculationMethod.egyptian` | Egyptian General Authority of Survey |
| `CalculationMethod.karachi` | University of Islamic Sciences, Karachi |
| `CalculationMethod.ummAlQura` | Umm al-Qura University, Makkah |
| `CalculationMethod.dubai` | UAE / Dubai |
| `CalculationMethod.moonsightingCommittee` | Moonsighting Committee Worldwide |
| `CalculationMethod.northAmerica` | ISNA (North America) |
| `CalculationMethod.kuwait` | Kuwait |
| `CalculationMethod.qatar` | Qatar |
| `CalculationMethod.singapore` | Singapore |
| `CalculationMethod.tehran` | Institute of Geophysics, University of Tehran |
| `CalculationMethod.turkiye` | Diyanet (Turkey) |
| `CalculationMethod.morocco` | Morocco (Ministry of Awqaf) |
| `CalculationMethod.other` | Custom angles — set `fajrAngle` / `ishaAngle` via `copyWith` |

Dot shorthand: `const Karachi()`, `const MoonsightingCommittee()`, etc.

## Advanced features

**Precision** — times round to the nearest minute by default. Pass `roundToMinutes: false` for second precision.

**High latitude** — when twilight persists, Fajr/Isha use `highLatitudeRule` (default: `middleOfTheNight`). Options: `seventhOfTheNight`, `twilightAngle`.

**Polar circle resolution** — default is `PolarCircleResolution.unresolved` (same as adhan-js). Resolution runs **only when solar sunrise/sunset are invalid** (polar edge cases). Mid-latitude locations are not modified.

To opt into nearest-latitude resolution (previous adhan_dart default):

```dart
final params = CalculationMethod.muslimWorldLeague.copyWith(
  polarCircleResolution: PolarCircleResolution.aqrabBalad,
);
```

Also available: `PolarCircleResolution.aqrabYaum` (nearest valid day).

If times are still invalid after resolution, a 45° latitude emergency fallback may run; affected prayers are listed in `estimatedPrayers`.

**Sunset** — `prayerTimes.sunset` exposes solar sunset (pre-maghrib-angle), matching adhan-js.

**Sunnah times** — `prayerTimes.sunnah` for middle/last third of the night.

**Qibla** — `Qibla.qibla(coordinates)` returns bearing in degrees.

## Migration

Upgrading from adhan-js or adhan_dart 1.1.x? See [MIGRATION.md](MIGRATION.md).

## License

MIT — see [LICENSE](LICENSE).
