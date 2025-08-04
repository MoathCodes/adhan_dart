import 'package:adhan_dart/adhan_dart.dart';

/// A class that contains the value of some sunnah times which are:
/// - Middle of the Night
/// - Last Third of the Night
///
/// Example:
/// ```dart
/// final sunnahTimes = SunnahTimes(prayerTimes);
/// // for precise times, set precision to true
/// final sunnahTimes = SunnahTimes(prayerTimes, precision: true);
/// print(sunnahTimes.middleOfTheNight);
/// print(sunnahTimes.lastThirdOfTheNight);
/// ```
class SunnahTimes {
  /// Cached next day prayer times to avoid duplicate calculations
  static PrayerTimesData? _cachedNextDay;
  static DateTime? _cachedDate;

  static Coordinates? _cachedCoordinates;

  static CalculationParameters? _cachedParams;
  final DateTime middleOfTheNight;
  final DateTime lastThirdOfTheNight;
  SunnahTimes(PrayerTimesData prayerTimes, {bool precision = true})
      : middleOfTheNight = _calculateMiddleOfNight(prayerTimes, precision),
        lastThirdOfTheNight =
            _calculateLastThirdOfNight(prayerTimes, precision);

  static DateTime _calculateLastThirdOfNight(
      PrayerTimesData prayerTimes, bool precision) {
    final nextDayPrayerTimes = _getNextDayPrayerTimes(prayerTimes, precision);
    final Duration nightDuration =
        nextDayPrayerTimes.fajr.difference(prayerTimes.maghrib);
    return prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds * (2 / 3)).floor())
        .roundedMinute(precision: precision);
  }

  static DateTime _calculateMiddleOfNight(
      PrayerTimesData prayerTimes, bool precision) {
    final nextDayPrayerTimes = _getNextDayPrayerTimes(prayerTimes, precision);
    final Duration nightDuration =
        nextDayPrayerTimes.fajr.difference(prayerTimes.maghrib);
    return prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds / 2).floor())
        .roundedMinute(precision: precision);
  }

  static PrayerTimesData _getNextDayPrayerTimes(
      PrayerTimesData prayerTimes, bool precision) {
    final nextDay = prayerTimes.date.addDays(1);

    // Simple cache check to avoid redundant calculations
    if (_cachedNextDay != null &&
        _cachedDate == nextDay &&
        _cachedCoordinates == prayerTimes.coordinates &&
        _cachedParams == prayerTimes.params) {
      return _cachedNextDay!;
    }

    final nextDayPrayerTimes = const PrayerTimesCalculator().calculate(
      date: nextDay,
      coordinates: prayerTimes.coordinates,
      params: prayerTimes.params,
      precision: precision,
    );

    // Cache the result
    _cachedNextDay = nextDayPrayerTimes;
    _cachedDate = nextDay;
    _cachedCoordinates = prayerTimes.coordinates;
    _cachedParams = prayerTimes.params;

    return nextDayPrayerTimes;
  }
}
