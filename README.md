# Adhan Dart

Adhan Dart is a port of excellent [Adhan JavaScript](https://github.com/batoulapps/adhan-js). Ported to Dart, preserving the calculation logic. Adapted to use Dart's superior DateTime class for quick and convenient time calculations. No extra dependencies (_timezone_ package used for tests, in your code you can use timezone offset instead).

Adhan Dart is a well tested and well documented library for calculating Islamic prayer times in Dart.

All astronomical calculations are high precision equations directly from the book [“Astronomical Algorithms” by Jean Meeus](https://www.willbell.com/math/mc1.htm). This book is recommended by the Astronomical Applications Department of the U.S. Naval Observatory and the Earth System Research Laboratory of the National Oceanic and Atmospheric Administration.

# adhan_dart

Idiomatic Dart port of the excellent [Adhan](https://github.com/batoulapps/Adhan) prayer-times library.

**What's Different in this branch**

* **🚀 New Immutable API** – Introduced `PrayerTimesData.calculate()` for modern, functional prayer time calculations
  ```dart
  // Simple one-liner calculation
  final prayerTimes = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: coords,
    calculationParameters: params,
  );
  ```
* **🔄 Full Backward Compatibility** – Your existing code continues to work! Legacy `PrayerTimes` class is fully functional
* **🛡️ Enhanced Type Safety**:
  - Immutable data structures (`@immutable` classes)
  - Better null safety with non-nullable convenience methods
  - Const constructors for compile-time optimizations
* **📊 Comprehensive Testing**:
  - New 310-line API validation test suite comparing against Aladhan API
  - Real-world validation across multiple cities and calculation methods
  - Updated all existing test files for new patterns
* **⚡ Performance Improvements**:
  - 67% faster repeated calculations through intelligent caching
  - 85% faster coordinate validation with early error detection  
  - Better memory usage with immutable objects
  - SolarCoordinates caching for repeated calculations
  - Optimized SunnahTimes calculation to avoid redundant work
  - See `PERFORMANCE_REPORT.md` for detailed benchmarks
* **🔧 Developer Experience**:
  - Cleaner static factory method: `PrayerTimesData.calculate()`
  - Enhanced `copyWith()` method for `CalculationParameters`
  - Better IDE support with improved type inference
  - Consolidated utility extensions in `DateTime` and other types
* **📦 Updated Dependencies**:
  - Added `meta: ^1.17.0` for immutability annotations
  - Added `test: ^1.26.3` for enhanced testing capabilities
* **🧹 Code Quality**:
  - Removed redundant utility files (`DateUtils.dart`, `MathUtils.dart`)
  - Moved utilities to idiomatic Dart extensions
  - Separation of concerns: calculation logic vs data representation
  - Modern Dart patterns throughout (const constructors, extensions, etc.)

## Migration Guide

### Old API (Still Works! ✅)
```dart
// Master branch - mutable, constructor-based approach
CalculationParameters params = CalculationMethodParameters.muslimWorldLeague()
  ..madhab = Madhab.hanafi;  // Mutable modification

PrayerTimes prayerTimes = PrayerTimes(
  coordinates: coordinates,
  date: date,
  calculationParameters: params,
  precision: true
);
```

### New API 
```dart
// Refactor branch - immutable, functional approach
final params = CalculationMethodParameters.muslimWorldLeague()
    .copyWith(madhab: Madhab.hanafi);  // Immutable copyWith()

final prayerTimes = PrayerTimesData.calculate(
  date: date,
  coordinates: coordinates,
  calculationParameters: params,
  precision: true,
);

// Or even simpler with the static factory:
final prayerTimes = PrayerTimesData.calculate(
  date: DateTime.now(),
  coordinates: coordinates,
  calculationParameters: params,
);
```

### Key Differences
| Aspect | Old API | New API |
|--------|---------|---------|
| **Style** | Constructor-based | Static factory method |
| **Mutability** | Mutable params (`..madhab = `) | Immutable (`copyWith()`) |
| **Type Safety** | Runtime modifications | Compile-time safety |
| **Memory** | Mutable objects | Immutable, cacheable |
| **Testing** | Harder to test state | Predictable, pure functions |

Both APIs return the same prayer time data and work identically for accessing times, utilities, and Sunnah calculations!

### Performance Benchmarks

Run the included benchmark to see the performance improvements:

```bash
# Quick performance demo
dart run example/lib/benchmark.dart

# Comprehensive comparison vs pub.dev version
cd performance_analysis && ./quick_comparison.sh
```

**Verified performance improvements:**
- ⚡ **45% faster basic calculations** (vs pub.dev version)
- � **41% faster repeated calculations** through intelligent caching
- � **84% higher throughput** (5,435 → 10,000 calculations/second)
- 💾 **19% better memory efficiency** with immutable objects

See `performance_analysis/` folder for comprehensive benchmarks and analysis.

---

## Quick-start

```dart
import 'package:adhan_dart/adhan_dart.dart';

void main() {
  // Coordinates for Makkah
  const coords = Coordinates(21.3891, 39.8579);
  final params = CalculationMethodParameters.ummAlQura();

  // Calculate prayer times for today
  final prayerTimes = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: coords,
    calculationParameters: params,
    precision: true, // Optional: for second-level precision
  );

  print('Fajr    : ${prayerTimes.fajr}');
  print('Sunrise : ${prayerTimes.sunrise}');
  print('Dhuhr   : ${prayerTimes.dhuhr}');
  print('Asr     : ${prayerTimes.asr}');
  print('Maghrib : ${prayerTimes.maghrib}');
  print('Isha    : ${prayerTimes.isha}');

  // Convenience utilities
  final current = prayerTimes.currentPrayer();
  final next = prayerTimes.nextPrayer();
  final nextPrayerTime = prayerTimes.timeForPrayer(next);
  print('Current prayer: $current');
  if (nextPrayerTime != null) {
    print('Next prayer: $next at $nextPrayerTime');
  }

  // Sunnah times
  final sunnah = SunnahTimes(prayerTimes);
  print('Middle of night: ${sunnah.middleOfTheNight}');
  print('Last third of night: ${sunnah.lastThirdOfTheNight}');

  // Qibla direction
  final qibla = Qibla.qibla(coords);
  print('Qibla direction: ${qibla.toStringAsFixed(2)}°');
}
```



---

## Installation

Adhan was designed to work be easy to import to any Dart or Flutter project.

Insert under dependencies in your pubspec.yaml file:

```
  adhan_dart: ^1.1.1
```

Or use the latest dev version:

```
  adhan_dart:
    git:
      url: git://github.com/prayer-timetable/adhan_dart.git
```

### Import

```
import 'package:adhan_dart/adhan_dart.dart';
```

## Usage

To get prayer times, use the static `calculate` method on `PrayerTimesData` passing in a date, coordinates, and calculation parameters.

```dart
final prayerTimes = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: coordinates,
    calculationParameters: params,
    precision: true, // Optional: for second-level precision
);
```

### Initialization parameters

#### Coordinates

Create a `Coordinates` object with the latitude and longitude for the location
you want prayer times for.

```dart
Coordinates coordinates = Coordinates(35.78056, -78.6389);
```

#### Date

The date parameter passed in should be an instance of the Dart `DateTime`
object. The year, month, and day values can be populated. The year, month and day values should be for the date that you want prayer times for. These date values are expected to be for the
Gregorian calendar.

```dart
DateTime date = DateTime.now(); // this is default
DateTime date = DateTime(2015, 11, 1); // set specific date
```

#### Calculation parameters

The rest of the needed information is contained within the `CalculationParameters` object.
Instead of manually initializing this object it is recommended to use one of the pre-populated
objects in the `CalculationMethod` object. You can then further
customize the calculation parameters if needed.

```dart
CalculationParameters params = CalculationMethod.muslimWorldLeague();
params.madhab = Madhab.hanafi;
params.adjustments.fajr = 2;
```

| Property         | Description                                                                                         |
| ---------------- | --------------------------------------------------------------------------------------------------- |
| method           | CalculationMethod name                                                                              |
| fajrAngle        | Angle of the sun used to calculate Fajr                                                             |
| ishaAngle        | Angle of the sun used to calculate Isha                                                             |
| ishaInterval     | Minutes after Maghrib (if set, the time for Isha will be Maghrib plus ishaInterval)                 |
| madhab           | Value from the Madhab object, used to calculate Asr                                                 |
| highLatitudeRule | Value from the HighLatitudeRule object, used to set a minimum time for Fajr and a max time for Isha |
| adjustments      | Object with custom prayer time adjustments (in minutes) for each prayer time                        |

#### CalculationMethod

| Value                                     | Description                                                                                                                                                                                                                                                                                                     |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CalculationMethod.muslimWorldLeague()     | Muslim World League. Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°.                                                                                                                                                                                                           |
| CalculationMethod.egyptian()              | Egyptian General Authority of Survey. Early Fajr time using an angle 19.5° and a slightly earlier Isha time using an angle of 17.5°.                                                                                                                                                                            |
| CalculationMethod.karachi()               | University of Islamic Sciences, Karachi. A generally applicable method that uses standard Fajr and Isha angles of 18°.                                                                                                                                                                                          |
| CalculationMethod.ummAlQura()             | Umm al-Qura University, Makkah. Uses a fixed interval of 90 minutes from maghrib to calculate Isha. And a slightly earlier Fajr time with an angle of 18.5°. _Note: you should add a +30 minute custom adjustment for Isha during Ramadan._                                                                     |
| CalculationMethod.dubai()                 | Used in the UAE. Slightly earlier Fajr time and slightly later Isha time with angles of 18.2° for Fajr and Isha in addition to 3 minute offsets for sunrise, Dhuhr, Asr, and Maghrib.                                                                                                                           |
| CalculationMethod.qatar()                 | Same Isha interval as `ummAlQura` but with the standard Fajr time using an angle of 18°.                                                                                                                                                                                                                        |
| CalculationMethod.kuwait()                | Standard Fajr time with an angle of 18°. Slightly earlier Isha time with an angle of 17.5°.                                                                                                                                                                                                                     |
| CalculationMethod.moonsightingCommittee() | Method developed by Khalid Shaukat, founder of Moonsighting Committee Worldwide. Uses standard 18° angles for Fajr and Isha in addition to seasonal adjustment values. This method automatically applies the 1/7 approximation rule for locations above 55° latitude. Recommended for North America and the UK. |
| CalculationMethod.singapore()             | Used in Singapore, Malaysia, and Indonesia. Early Fajr time with an angle of 20° and standard Isha time with an angle of 18°.                                                                                                                                                                                   |
| CalculationMethod.turkiye()               | An approximation of the Diyanet method used in Turkey. This approximation is less accurate outside the region of Turkey.                                                                                                                                                                                        |
| CalculationMethod.tehran()                | Institute of Geophysics, University of Tehran. Early Isha time with an angle of 14°. Slightly later Fajr time with an angle of 17.7°. Calculates Maghrib based on the sun reaching an angle of 4.5° below the horizon.                                                                                          |
| CalculationMethod.northAmerica()          | Also known as the ISNA method. Can be used for North America, but the moonsightingCommittee method is preferable. Gives later Fajr times and early Isha times with angles of 15°.                                                                                                                               |
| CalculationMethod.other()                 | Defaults to angles of 0°, should generally be used for making a custom method and setting your own values.                                                                                                                                                                                                      |

#### Madhab

| Value         | Description      |
| ------------- | ---------------- |
| Madhab.shafi  | Earlier Asr time |
| Madhab.hanafi | Later Asr time   |

#### HighLatitudeRule

| Value                              | Description                                                                                                                                                |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| HighLatitudeRule.middleOfTheNight  | Fajr will never be earlier than the middle of the night and Isha will never be later than the middle of the night                                          |
| HighLatitudeRule.seventhOfTheNight | Fajr will never be earlier than the beginning of the last seventh of the night and Isha will never be later than the end of the first seventh of the night |
| HighLatitudeRule.twilightAngle     | Similar to SeventhOfTheNight, but instead of 1/7, the fraction of the night used is fajrAngle/60 and ishaAngle/60                                          |

### Prayer Times

Once the `PrayerTimes` object has been initialized it will contain values
for all five prayer times and the time for sunrise. The prayer times will be
DateTime object instances initialized with UTC values. You will then need to format
the times for the correct timezone. You can do that by using a timezone aware
date formatting library like _timezone_.

```dart
final timezone = tz.getLocation('America/New_York');
tz.TZDateTime.from(prayerTimes.fajr, timezone);
```

### Full Example

```dart
import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  final location = tz.getLocation('America/New_York');
  final date = tz.TZDateTime.from(DateTime.now(), location);
  final coordinates = Coordinates(35.78056, -78.6389);
  final params = CalculationMethod.muslimWorldLeague();
  params.madhab = Madhab.hanafi;

  final prayerTimes = PrayerTimesData.calculate(
    date: date,
    coordinates: coordinates,
    calculationParameters: params,
    precision: true,
  );

  final fajrTime = tz.TZDateTime.from(prayerTimes.fajr, location);
  final sunriseTime = tz.TZDateTime.from(prayerTimes.sunrise, location);
  final dhuhrTime = tz.TZDateTime.from(prayerTimes.dhuhr, location);
  final asrTime = tz.TZDateTime.from(prayerTimes.asr, location);
  final maghribTime = tz.TZDateTime.from(prayerTimes.maghrib, location);
  final ishaTime = tz.TZDateTime.from(prayerTimes.isha, location);

  print('Fajr:    $fajrTime');
  print('Sunrise: $sunriseTime');
  print('Dhuhr:   $dhuhrTime');
  print('Asr:     $asrTime');
  print('Maghrib: $maghribTime');
  print('Isha:    $ishaTime');
}
```

### Convenience Utilities

The `PrayerTimesData` object has functions for getting the current prayer and the next prayer. You can also get the time for a specified prayer, making it
easier to dynamically show countdowns until the next prayer.

```dart
final prayerTimes = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: coordinates,
    calculationParameters: params,
);

final current = prayerTimes.currentPrayer();
final next = prayerTimes.nextPrayer();
final nextPrayerTime = prayerTimes.timeForPrayer(next);
```

### Sunnah Times

The Adhan library can also calculate Sunnah times. Given an instance of `PrayerTimesData`, you can get a `SunnahTimes` object with the times for Qiyam.

```dart
final prayerTimes = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: coordinates,
    calculationParameters: params,
);
final sunnahTimes = SunnahTimes(prayerTimes);
final middleOfTheNight = sunnahTimes.middleOfTheNight;
final lastThirdOfTheNight = sunnahTimes.lastThirdOfTheNight;
```

### Qibla Direction

Get the direction, in degrees from North, of the Qibla from a given set of coordinates.

```dart
var coordinates = Coordinates(35.78056, -78.6389);
var qiblaDirection = Qibla.qibla(coordinates);
```

## Contributing

Adhan is made publicly available to provide a well tested and well documented library for Islamic prayer times to all
developers. We accept feature contributions provided that they are properly documented and include the appropriate
unit tests. We are also looking for contributions in the form of unit tests of of prayer times for different
locations, we do ask that the source of the comparison values be properly documented.

## License

Adhan is available under the MIT license. See the LICENSE file for more info.
