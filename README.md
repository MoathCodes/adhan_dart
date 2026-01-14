# Adhan Dart

Adhan Dart is a well-tested and well-documented library for calculating Islamic prayer times in Dart. It is an idiomatic Dart port of the excellent [Adhan](https://github.com/batoulapps/Adhan) library (originally in JavaScript).

This library provides:
*   **High Precision**: Uses astronomical equations from [Astronomical Algorithms](http://www.willbell.com/math/mc1.htm) by Jean Meeus.
*   **Type Safety**: Full Dart null-safety with robust, non-nullable result guarantees.
*   **Modern API**: Uses sealed classes, immutable data structures, and idiomatic patterns.
*   **Performance**: Optimized calculations with caching for high-throughput scenarios.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  adhan_dart: ^1.1.2
```

## Usage

### Initialization Parameters
 
**1. Coordinates**
Create a `Coordinates` object with the latitude and longitude for the location you want prayer times for.
 
```dart
final coordinates = Coordinates(35.78056, -78.6389);
```
 
**2. Date**
The date parameter passed in should be an instance of the Dart `DateTime` object.
> **Note**: Unlike JavaScript's `Date` object (which uses 0-indexed months), Dart's `DateTime` uses 1-indexed months (1 = January).
 
```dart
final date = DateTime.now();
final date = DateTime(2015, 11, 1); // November 1st, 2015
```
 
**3. Calculation Parameters**
The rest of the needed information is contained within the `CalculationMethod` class.
 
### 1. Simple Calculation

To get prayer times, instantiate `PrayerTimes` with your coordinates, date, and calculation method.

```dart
import 'package:adhan_dart/adhan_dart.dart';

// 1. Define location
final coordinates = Coordinates(21.4225, 39.8262); // Mecca

// 2. Choose a calculation method
final params = CalculationMethod.ummAlQura;

// 3. Calculate times
final prayerTimes = PrayerTimes(
  coordinates: coordinates,
  date: DateTime.now(),
  calculationMethod: params,
);

// 4. Access results (DateTime objects)
print('Fajr: ${prayerTimes.fajr}');
print('Dhuhr: ${prayerTimes.dhuhr}');
print('Asr: ${prayerTimes.asr}');
print('Maghrib: ${prayerTimes.maghrib}');
print('Isha: ${prayerTimes.isha}');
```

### 2. Customizing Parameters

The `CalculationMethod` classes are immutable. Use `copyWith` to customize parameters like `madhab` (for Asr calculation) or `adjustments`.

```dart
// Start with a preset
final params = CalculationMethod.karachi;

// Customize it
params = params.copyWith(
  madhab: Madhab.hanafi, // Use Hanafi school for Asr
  adjustments: {
    Prayer.fajr: 2, // Add 2 minutes to Fajr
  }
);

final prayerTimes = PrayerTimes(
  coordinates: coordinates,
  date: DateTime.now(),
  calculationMethod: params,
);
```

### 3. Convenience Utilities

The library includes several utility methods for common needs.

**Current and Next Prayer:**
```dart
final current = prayerTimes.currentPrayer();
final next = prayerTimes.nextPrayer();
print('Current Prayer: ${current.name}');
print('Next Prayer: ${next.name}');
```

**Sunnah Times (Qiyam):**
```dart
final sunnahTimes = prayerTimes.sunnah;
print('Middle of the Night: ${sunnahTimes.middleOfTheNight}');
print('Last Third of the Night: ${sunnahTimes.lastThirdOfTheNight}');
```

**Qibla Direction:**
```dart
final qiblaDirection = Qibla.qibla(coordinates);
print('Qibla Direction: $qiblaDirection degrees');
```

## Calculation Methods

The library supports standard calculation methods used around the world. You can access them via the `CalculationMethod` class.

| Method | Description |
|---|---|
| `CalculationMethod.muslimWorldLeague` | Muslim World League (Standard) |
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
| `CalculationMethod.turkiye` | Dianet (Turkey) |
| `CalculationMethod.other` | Custom / Other |

**Dot Shorthand Support:**
You can also use static constants for cleaner code:
```dart
final params = CalculationMethod.karachi;
// vs
final params = const Karachi();
```

## Advanced Features

**Time Precision:**
By default, times are rounded to the nearest minute. To get precise times (seconds), set `roundToMinutes: false`.

```dart
final preciseTimes = PrayerTimes(
  coordinates: coordinates,
  date: DateTime.now(),
  calculationMethod: params,
  roundToMinutes: false,
);
```

**High Latitude Rules:**
For locations at high latitudes (where twilight may persist or the sun may not set), the library automatically handles fallbacks. You can customize the rule used via `highLatitudeRule` in `CalculationMethod`.

*   `HighLatitudeRule.middleOfTheNight` (Default)
*   `HighLatitudeRule.seventhOfTheNight`
*   `HighLatitudeRule.twilightAngle`

**Polar Circle Resolution:**
The library automatically resolves invalid times in polar regions using `PolarCircleResolution.aqrabBalad` (Nearest Latitude) by default. This ensures you always get a valid `DateTime` result, preventing crashes or null values in your app.

## License

Adhan Dart is available under the MIT license. See the LICENSE file for more info.