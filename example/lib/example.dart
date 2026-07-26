// ignore_for_file: avoid_print

import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  final location = tz.getLocation('America/New_York');

  // PrayerTimes uses the calendar date from [date]; times returned are UTC
  // instants — convert with TZDateTime.from before showing local wall time.
  final date = tz.TZDateTime.from(DateTime.now(), location);
  final coordinates = Coordinates(35.78056, -78.6389);

  final params = CalculationMethod.muslimWorldLeague.copyWith(
    madhab: Madhab.hanafi,
  );
  final prayerTimes = PrayerTimes(
    date: date,
    coordinates: coordinates,
    calculationMethod: params,
    roundToMinutes: true,
  );

  // Convert UTC instants to the location's timezone for display.
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

  print('***** Current Time');
  print('local time:\t$date');

  print('\n***** Prayer Times (America/New_York)');
  print('fajrTime:\t$fajrTime');
  print('sunriseTime:\t$sunriseTime');
  print('dhuhrTime:\t$dhuhrTime');
  print('asrTime:\t$asrTime');
  print('maghribTime:\t$maghribTime');
  print('ishaTime:\t$ishaTime');

  print('ishaBeforeTime:\t$ishaBeforeTime');
  print('fajrAfterTime:\t$fajrAfterTime');

  print('\n***** Convenience Utilities');
  print('current:\t$current\t$currentPrayerTime');
  print('next:   \t$next\t$nextPrayerTime');

  if (prayerTimes.estimatedPrayers.isNotEmpty) {
    print(
      'estimated:\t${prayerTimes.estimatedPrayers.map((p) => p.name).join(', ')}',
    );
  }

  print('\n***** Sunnah Times');
  print('middleOfTheNight:  \t$middleOfTheNight');
  print('lastThirdOfTheNight:  \t$lastThirdOfTheNight');

  print('\n***** Qibla Direction');
  print('qibla:  \t$qiblaDirection');
}
