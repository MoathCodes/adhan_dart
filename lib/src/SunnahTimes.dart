import 'package:adhan_dart/adhan_dart.dart';


class SunnahTimes {
  late DateTime middleOfTheNight;
  late DateTime lastThirdOfTheNight;

  SunnahTimes(PrayerTimes prayerTimes, {bool precision = true}) {
    final DateTime nextDay = prayerTimes.date.addDays(1);

    // Use legacy constructor for now; will switch to immutable calculator later.
    final PrayerTimes nextDayPrayerTimes = PrayerTimes(
      coordinates: prayerTimes.coordinates,
      date: nextDay,
      calculationParameters: prayerTimes.calculationParameters,
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
