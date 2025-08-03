import 'package:adhan_dart/adhan_dart.dart';

import 'package:adhan_dart/src/Astronomical.dart';
import 'package:adhan_dart/src/SolarTime.dart';
import 'package:adhan_dart/src/TimeComponents.dart';

import 'extensions.dart';
import 'prayer_times_data.dart';

/// Temporary bridge calculator that produces an immutable [PrayerTimesData]
/// object while still delegating the heavy lifting to the legacy
/// [legacy.PrayerTimes] implementation.  This lets us switch call-sites to the
/// new API before porting the actual maths.
///
/// Once all consumers use [PrayerTimesData] we can incrementally move the
/// calculation logic here and eventually delete the legacy class.
class PrayerTimesCalculator {
  const PrayerTimesCalculator();

  /// Returns prayer times for the supplied inputs by instantiating the legacy
  /// mutable class and converting it into an immutable data object.
  PrayerTimesData calculate({
    required DateTime date,
    required Coordinates coordinates,
    required CalculationParameters params,
    bool precision = false,
  }) {
    // Precompute Solar positions for today, yesterday, and tomorrow
    final DateTime dateBefore = date.addDays(-1);
    final DateTime dateAfter = date.addDays(1);

    final solarToday = SolarTime(date, coordinates);
    final solarBefore = SolarTime(dateBefore, coordinates);
    final solarAfter = SolarTime(dateAfter, coordinates);

    DateTime asrTime = TimeComponents(
            solarToday.afternoon(shadowLength(params.madhab)))
        .utcDate(date.year, date.month, date.day);

    // sunrise & sunset
    final DateTime sunriseTime = TimeComponents(solarToday.sunrise)
        .utcDate(date.year, date.month, date.day);
    final DateTime sunsetTime = TimeComponents(solarToday.sunset)
        .utcDate(date.year, date.month, date.day);

    // fajr & fajrAfter (tomorrow)
    DateTime fajrTime = TimeComponents(
            solarToday.hourAngle(-1 * params.fajrAngle, false))
        .utcDate(date.year, date.month, date.day);
    DateTime fajrAfterTime = TimeComponents(
            solarAfter.hourAngle(-1 * params.fajrAngle, false))
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);

    // dhuhr
    final DateTime dhuhrTime = TimeComponents(solarToday.transit)
        .utcDate(date.year, date.month, date.day);

    // sunset before (yesterday) & sunrise after (tomorrow) for night length
    final DateTime sunriseAfterTime = TimeComponents(solarAfter.sunrise)
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    final DateTime sunsetBeforeTime = TimeComponents(solarBefore.sunset)
        .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

    // night length in seconds (sunset to next sunrise)
    final int nightSeconds = sunriseAfterTime.difference(sunsetTime).inSeconds;

    // Maghrib
    final DateTime maghribTime = sunsetTime;

    // Isha & IshabeforeTime
    DateTime ishaTime = TimeComponents(
            solarToday.hourAngle(-1 * params.ishaAngle, true))
        .utcDate(date.year, date.month, date.day);
    DateTime ishaBeforeTime = TimeComponents(
            solarBefore.hourAngle(-1 * params.ishaAngle, true))
        .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

    // High latitude adjustments (safeFajr/Isha logic)
    DateTime safeFajr() {
      if (params.method == CalculationMethod.moonsightingCommittee) {
        return Astronomical.seasonAdjustedMorningTwilight(
            coordinates.latitude, date.dayOfYear, date.year, sunriseTime);
      } else {
        final portion = params.nightPortions()[Prayer.fajr]!;
        final seconds = (portion * nightSeconds).round();
        return sunriseTime.addSeconds(-seconds);
      }
    }

    DateTime safeIsha() {
      if (params.method == CalculationMethod.moonsightingCommittee) {
        return Astronomical.seasonAdjustedEveningTwilight(
            coordinates.latitude, date.dayOfYear, date.year, sunsetTime);
      } else {
        final portion = params.nightPortions()[Prayer.isha]!;
        final seconds = (portion * nightSeconds).round();
        return sunsetTime.addSeconds(seconds);
      }
    }

    // Fallbacks if the computed angle times are invalid or unsafe
    if (params.method == CalculationMethod.moonsightingCommittee &&
        coordinates.latitude >= 55) {
      final double fraction = nightSeconds / 7;
      fajrTime = sunriseTime.addSeconds(-fraction.round());
      fajrAfterTime = sunriseAfterTime.addSeconds(-fraction.round());
    }

    if (safeFajr().isAfter(fajrTime)) {
      fajrTime = safeFajr();
    }
    if (safeIsha().isBefore(ishaTime)) {
      ishaTime = safeIsha();
    }

    // Override with fixed isha interval if provided (e.g., 90 min after sunset)
    if (params.ishaInterval != null && params.ishaInterval! > 0) {
      ishaTime = sunsetTime.addMinutes(params.ishaInterval!);
      ishaBeforeTime = sunsetBeforeTime.addMinutes(params.ishaInterval!);
    }

    return PrayerTimesData(
      date: date,
      coordinates: coordinates,
      params: params,
      fajr: precision ? fajrTime : fajrTime.roundedMinute(precision: false),
      sunrise: precision ? sunriseTime : sunriseTime.roundedMinute(precision: false),
      dhuhr: precision ? dhuhrTime : dhuhrTime.roundedMinute(precision: false),
      asr: precision ? asrTime : asrTime.roundedMinute(precision: false),
      maghrib: precision ? maghribTime : maghribTime.roundedMinute(precision: false),
      isha: precision ? ishaTime : ishaTime.roundedMinute(precision: false),
      ishaBefore: ishaBeforeTime,
      fajrAfter: fajrAfterTime,
    );
  }
}
