# Dart Example

Run with `dart run example/lib/example.dart` (requires `timezone` in dev dependencies).

Prayer times from `PrayerTimes` are **UTC instants**. Convert with `TZDateTime.from` before display.

```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:adhan_dart/adhan_dart.dart';

void main() {
  tz.initializeTimeZones();
  final location = tz.getLocation('America/New_York');

  final date = tz.TZDateTime.from(DateTime.now(), location);
  final coordinates = Coordinates(35.78056, -78.6389);

  final params = CalculationMethod.muslimWorldLeague.copyWith(
    madhab: Madhab.hanafi,
  );
  final prayerTimes = PrayerTimes(
    coordinates: coordinates,
    date: date,
    calculationMethod: params,
    roundToMinutes: true,
  );

  DateTime toLocal(DateTime utc) => tz.TZDateTime.from(utc, location);

  final fajrTime = toLocal(prayerTimes.fajr);
  final sunriseTime = toLocal(prayerTimes.sunrise);
  final dhuhrTime = toLocal(prayerTimes.dhuhr);
  final asrTime = toLocal(prayerTimes.asr);
  final maghribTime = toLocal(prayerTimes.maghrib);
  final ishaTime = toLocal(prayerTimes.isha);
  final ishaBeforeTime = toLocal(prayerTimes.ishaBefore);
  final fajrAfterTime = toLocal(prayerTimes.fajrAfter);

  final current = prayerTimes.currentPrayer(time: DateTime.now());
  final currentPrayerTime = toLocal(prayerTimes.timeForPrayer(current));
  final next = prayerTimes.nextPrayer();
  final nextPrayerTime = toLocal(prayerTimes.nextPrayerTime());

  final sunnahTimes = SunnahTimes(prayerTimes);
  final middleOfTheNight = toLocal(sunnahTimes.middleOfTheNight);
  final lastThirdOfTheNight = toLocal(sunnahTimes.lastThirdOfTheNight);

  final qiblaDirection = Qibla.qibla(coordinates);

  print('local time:\t$date');
  print('fajrTime:\t$fajrTime');
  print('next:   \t$next\t$nextPrayerTime');
  print('qibla:  \t$qiblaDirection');
}
```
