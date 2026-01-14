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
  /// Cached next day prayer times to avoid duplicate calculations
  static PrayerTimes? _cachedNextDay;
  static DateTime? _cachedDate;

  static Coordinates? _cachedCoordinates;

  static CalculationMethod? _cachedMethod;
  final DateTime middleOfTheNight;
  final DateTime lastThirdOfTheNight;
  
  SunnahTimes(PrayerTimes prayerTimes, {bool roundToMinutes = true})
      : middleOfTheNight = _calculateMiddleOfNight(prayerTimes, roundToMinutes),
        lastThirdOfTheNight =
            _calculateLastThirdOfNight(prayerTimes, roundToMinutes);

  static DateTime _calculateLastThirdOfNight(
      PrayerTimes prayerTimes, bool roundToMinutes) {
    final nextDayPrayerTimes =
        _getNextDayPrayerTimes(prayerTimes, roundToMinutes);
    final Duration nightDuration =
        nextDayPrayerTimes.fajr.difference(prayerTimes.maghrib);
    return prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds * (2 / 3)).floor())
        .roundedMinute(rounding: roundToMinutes ? Rounding.nearest : Rounding.none);
  }

  static DateTime _calculateMiddleOfNight(
      PrayerTimes prayerTimes, bool roundToMinutes) {
    final nextDayPrayerTimes =
        _getNextDayPrayerTimes(prayerTimes, roundToMinutes);
    final Duration nightDuration =
        nextDayPrayerTimes.fajr.difference(prayerTimes.maghrib);
    return prayerTimes.maghrib
        .addSeconds((nightDuration.inSeconds / 2).floor())
        .roundedMinute(rounding: roundToMinutes ? Rounding.nearest : Rounding.none);
  }

  static PrayerTimes _getNextDayPrayerTimes(
      PrayerTimes prayerTimes, bool roundToMinutes) {
    final nextDay = prayerTimes.date.addDays(1);

    // Simple cache check to avoid redundant calculations
    if (_cachedNextDay != null &&
        _cachedDate == nextDay &&
        _cachedCoordinates == prayerTimes.coordinates &&
        _cachedMethod == prayerTimes.calculationMethod) {
      return _cachedNextDay!;
    }

    final nextDayPrayerTimes = PrayerTimes(
      date: nextDay,
      coordinates: prayerTimes.coordinates,
      calculationMethod: prayerTimes.calculationMethod,
      roundToMinutes: roundToMinutes,
    );

    // Cache the result
    _cachedNextDay = nextDayPrayerTimes;
    _cachedDate = nextDay;
    _cachedCoordinates = prayerTimes.coordinates;
    _cachedMethod = prayerTimes.calculationMethod;

    return nextDayPrayerTimes;
  }
}