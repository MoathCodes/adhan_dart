import 'package:adhan_dart/adhan_dart.dart';

/// A class that contains the value of some sunnah times which are:
/// - Middle of the Night
/// - Last Third of the Night
///
/// Example:
/// ```dart
/// final sunnahTimes = SunnahTimes(prayerTimes);
/// // for precise times, set roundToMinutes to false
/// final sunnahTimes = SunnahTimes(prayerTimes, roundToMinutes: false);
/// print(sunnahTimes.middleOfTheNight);
/// print(sunnahTimes.lastThirdOfTheNight);
/// ```
class SunnahTimes {
  final DateTime middleOfTheNight;
  final DateTime lastThirdOfTheNight;

  /// Computes middle and last-third from [prayerTimes], calculating the next
  /// day's [PrayerTimes] once and reusing it for both night fractions.
  SunnahTimes(PrayerTimes prayerTimes, {bool roundToMinutes = true})
    : this._fromNightDuration(
        prayerTimes,
        _getNextDayPrayerTimes(prayerTimes, roundToMinutes),
        roundToMinutes,
      );

  SunnahTimes._fromNightDuration(
    PrayerTimes prayerTimes,
    PrayerTimes nextDayPrayerTimes,
    bool roundToMinutes,
  ) : middleOfTheNight = _fractionOfNight(
        prayerTimes,
        nextDayPrayerTimes,
        roundToMinutes,
        1 / 2,
      ),
      lastThirdOfTheNight = _fractionOfNight(
        prayerTimes,
        nextDayPrayerTimes,
        roundToMinutes,
        2 / 3,
      );

  static DateTime _fractionOfNight(
    PrayerTimes prayerTimes,
    PrayerTimes nextDayPrayerTimes,
    bool roundToMinutes,
    double fraction,
  ) {
    final Duration nightDuration = nextDayPrayerTimes.fajr.difference(
      prayerTimes.maghrib,
    );
    return prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds * fraction).floor())
        .roundedMinute(
          rounding: roundToMinutes ? Rounding.nearest : Rounding.none,
        );
  }

  static PrayerTimes _getNextDayPrayerTimes(
    PrayerTimes prayerTimes,
    bool roundToMinutes,
  ) {
    return PrayerTimes(
      date: prayerTimes.date.addDays(1),
      coordinates: prayerTimes.coordinates,
      calculationMethod: prayerTimes.calculationMethod,
      roundToMinutes: roundToMinutes,
    );
  }
}
