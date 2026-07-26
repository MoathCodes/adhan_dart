# Migration Guide

This guide covers upgrading from **adhan-js** (JavaScript) or older **adhan_dart** releases to **1.2.0+**.

## adhan-js → adhan_dart

### Constructor and parameter names

adhan-js:

```javascript
const prayerTimes = new PrayerTimes(coordinates, date, params);
```

adhan_dart:

```dart
final prayerTimes = PrayerTimes(
  coordinates: coordinates,
  date: date,
  calculationMethod: params,
);
```

Use named parameters. `CalculationParameters` is `CalculationMethod` in Dart.

### UTC output contract

Both libraries return prayer times as **UTC `DateTime` instants**. The clock fields (`hour`, `minute`) are UTC, not the location's local wall time.

Convert for display with the [`timezone`](https://pub.dev/packages/timezone) package (or your platform's zone database):

```dart
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

tz.initializeTimeZones();
final location = tz.getLocation('America/New_York');

final localFajr = tz.TZDateTime.from(prayerTimes.fajr, location);
```

Do **not** call `.toLocal()` unless the device timezone matches the prayer location.

### `Prayer.None` → `ishaBefore` / `fajrAfter`

adhan-js uses `Prayer.None` when the current or next prayer falls on an adjacent day. adhan_dart uses explicit enum values:

| Situation | adhan-js | adhan_dart |
|-----------|---------|------------|
| Before today's Fajr | `None` (previous Isha) | `Prayer.ishaBefore` |
| After today's Isha | `None` (next Fajr) | `Prayer.fajrAfter` |

```dart
// Before Fajr
prayerTimes.currentPrayer(); // Prayer.ishaBefore
prayerTimes.timeForPrayer(Prayer.ishaBefore); // yesterday's Isha

// After Isha
prayerTimes.nextPrayer(); // Prayer.fajrAfter (not Prayer.fajr)
prayerTimes.nextPrayerTime(); // tomorrow's Fajr
prayerTimes.timeForPrayer(Prayer.fajrAfter);
```

`timeForPrayer` always returns a `DateTime` for every `Prayer` value, including `ishaBefore` and `fajrAfter`.

### Turkey → Turkiye

```dart
// Before (removed)
CalculationMethod.turkey

// After
CalculationMethod.turkiye
// or
const Turkiye()
```

### Polar circle resolution default

adhan-js defaults to `PolarCircleResolution.unresolved`. adhan_dart **1.2.0** matches this.

Older adhan_dart releases defaulted to `aqrabBalad`, which shifted mid-latitude times. To restore the old behavior:

```dart
final params = CalculationMethod.muslimWorldLeague.copyWith(
  polarCircleResolution: PolarCircleResolution.aqrabBalad,
);
```

Resolution runs only when solar times are invalid (polar/high-latitude edge cases). Mid-latitude locations are unaffected by the default change.

### Morocco method

adhan_dart adds `CalculationMethod.morocco` / `Morocco()` (not in upstream adhan-js):

```dart
final params = CalculationMethod.morocco;
```

### `copyWith` preserves method identity

`copyWith` returns the same preset subclass, so type checks keep working:

```dart
final adjusted = CalculationMethod.moonsightingCommittee.copyWith(
  madhab: Madhab.hanafi,
);
assert(adjusted is MoonsightingCommittee); // true
```

Pass `null` for `ishaInterval` or `maghribAngle` to clear those values (e.g. switch from interval-based to angle-based Isha):

```dart
CalculationMethod.ummAlQura.copyWith(ishaInterval: null);
```

`fromJson` merges partial `adjustments` / `methodAdjustments` maps onto preset defaults instead of replacing them wholesale.

---

## adhan_dart 1.1.x → 1.2.0

### Breaking: polar default

Default `polarCircleResolution` changed from `aqrabBalad` to `unresolved`. Opt in to nearest-latitude resolution explicitly (see above).

### Breaking: `nextPrayer` after Isha

After Isha, `nextPrayer()` now returns `Prayer.fajrAfter` instead of `Prayer.fajr`. Use `nextPrayerTime()` or `timeForPrayer(Prayer.fajrAfter)` for the correct instant.

Code that compared `next == Prayer.fajr` late at night should check for `Prayer.fajrAfter` instead.

### New API surface

| Feature | Description |
|---------|-------------|
| `PrayerTimes.sunset` | Solar sunset (pre-maghrib-angle), matching adhan-js |
| `PrayerTimes.nextPrayerTime()` | Convenience for `timeForPrayer(nextPrayer())` |
| `PrayerTimes.estimatedPrayers` | `Set<Prayer>` of times computed via safety fallbacks |
| `CalculationMethod.morocco` | Morocco preset with method adjustments |
| `formatForDisplay(convert: …)` | Optional UTC→local conversion callback |

### `Coordinates` is no longer `const`

Validation runs in the factory constructor. Use `Coordinates(lat, lng)` instead of `Coordinates(lat, lng)`:

```dart
// Before
const coords = Coordinates(35.78, -78.64);

// After
final coords = Coordinates(35.78, -78.64);
```

`Coordinates.validated` is an alias for `Coordinates`.

### Moonsighting Committee at latitude ≥ 55°

Fajr/Isha season adjustments now align with adhan-js (seventh-of-night baseline before safe bounds). Expect different Fajr/Isha at high northern latitudes when using `MoonsightingCommittee`.
