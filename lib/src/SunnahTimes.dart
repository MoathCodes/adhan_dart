import 'package:adhan_dart/adhan_dart.dart';

class SunnahTimes {
  late DateTime middleOfTheNight;
  late DateTime lastThirdOfTheNight;

  SunnahTimes(PrayerTimesData prayerTimes, {bool precision = true}) {
    final DateTime nextDay = prayerTimes.date.addDays(1);

    // Retrieve next-day prayer times via calculator
    final nextDayPrayerTimes = const PrayerTimesCalculator().calculate(
      date: nextDay,
      coordinates: prayerTimes.coordinates,
      params: prayerTimes.params,
      precision: precision,
    );

    final Duration nightDuration =
        nextDayPrayerTimes.fajr.difference(prayerTimes.maghrib);

    middleOfTheNight = prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds / 2).floor())
        .roundedMinute(precision: precision);

    lastThirdOfTheNight = prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds * (2 / 3)).floor())
        .roundedMinute(precision: precision);
  }
}
