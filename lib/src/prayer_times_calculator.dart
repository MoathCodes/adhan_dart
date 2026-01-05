import 'package:adhan_dart/adhan_dart.dart';
import 'package:adhan_dart/src/Astronomical.dart';
import 'package:adhan_dart/src/SolarTime.dart';
import 'package:adhan_dart/src/TimeComponents.dart';

class PrayerTimesCalculator {
  /// Returns list of calculation methods supported by this library
  static List<CalculationMethod> get supportedMethods => [
        CalculationMethod.muslimWorldLeague,
        CalculationMethod.egyptian,
        CalculationMethod.karachi,
        CalculationMethod.ummAlQura,
        CalculationMethod.dubai,
        CalculationMethod.moonsightingCommittee,
        CalculationMethod.northAmerica,
        CalculationMethod.kuwait,
        CalculationMethod.qatar,
        CalculationMethod.singapore,
        // Note: tehran, turkey, morocco require custom parameter implementation
      ];

  const PrayerTimesCalculator();

  PrayerTimesData calculate({
    required DateTime date,
    required Coordinates coordinates,
    required CalculationParameters params,
    bool roundToMinutes = true,
  }) {
    // Early validation
    _validateInputs(coordinates, params);
    // Precompute Solar positions for today, yesterday, and tomorrow
    final DateTime dateBefore = date.addDays(-1);
    final DateTime dateAfter = date.addDays(1);

    final solarToday = SolarTime(date, coordinates);
    final solarBefore = SolarTime(dateBefore, coordinates);
    final solarAfter = SolarTime(dateAfter, coordinates);

    // Pre-calculate shadow length to avoid redundant calls
    final shadowLengthValue = shadowLength(params.madhab);

    DateTime asrTime = TimeComponents(solarToday.afternoon(shadowLengthValue))
        .utcDate(date.year, date.month, date.day);

    // sunrise & sunset
    final DateTime sunriseTime = TimeComponents(solarToday.sunrise)
        .utcDate(date.year, date.month, date.day);
    final DateTime sunsetTime = TimeComponents(solarToday.sunset)
        .utcDate(date.year, date.month, date.day);

    // fajr & fajrAfter (tomorrow)
    DateTime fajrTime =
        TimeComponents(solarToday.hourAngle(-1 * params.fajrAngle, false))
            .utcDate(date.year, date.month, date.day);
    DateTime fajrAfterTime =
        TimeComponents(solarAfter.hourAngle(-1 * params.fajrAngle, false))
            .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);

    // dhuhr
    DateTime dhuhrTime = TimeComponents(solarToday.transit)
        .utcDate(date.year, date.month, date.day);

    // sunset before (yesterday) & sunrise after (tomorrow) for night length
    final DateTime sunriseAfterTime = TimeComponents(solarAfter.sunrise)
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    final DateTime sunsetBeforeTime = TimeComponents(solarBefore.sunset)
        .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

    // Also compute sunset for tomorrow and sunrise for the day after tomorrow
    final DateTime sunsetAfterTime = TimeComponents(solarAfter.sunset)
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    final DateTime dateAfterAfter = dateAfter.addDays(1);
    final solarAfterAfter = SolarTime(dateAfterAfter, coordinates);
    final DateTime sunriseAfterAfterTime =
        TimeComponents(solarAfterAfter.sunrise).utcDate(
            dateAfterAfter.year, dateAfterAfter.month, dateAfterAfter.day);

    // night length in seconds (sunset to next sunrise)
    final int nightSeconds = sunriseAfterTime.difference(sunsetTime).inSeconds;
    // previous night length (yesterday sunset to today sunrise)
    final int nightSecondsBefore =
        sunriseTime.difference(sunsetBeforeTime).inSeconds;
    // tomorrow night length (tomorrow sunset to day-after-tomorrow sunrise)
    final int nightSecondsAfter =
        sunriseAfterAfterTime.difference(sunsetAfterTime).inSeconds;

    // Maghrib
    DateTime maghribTime = sunsetTime;

    // Isha & IshabeforeTime
    DateTime ishaTime =
        TimeComponents(solarToday.hourAngle(-1 * params.ishaAngle, true))
            .utcDate(date.year, date.month, date.day);
    DateTime ishaBeforeTime =
        TimeComponents(solarBefore.hourAngle(-1 * params.ishaAngle, true))
            .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

    final Set<Prayer> estimated = <Prayer>{};

    DateTime seasonAdjustedMorning() =>
        Astronomical.seasonAdjustedMorningTwilight(
            coordinates.latitude, date.dayOfYear, date.year, sunriseTime);
    DateTime seasonAdjustedEvening() =>
        Astronomical.seasonAdjustedEveningTwilight(
            coordinates.latitude, date.dayOfYear, date.year, sunsetTime);

    DateTime computeSafeFajr() {
      if (params.method == CalculationMethod.moonsightingCommittee) {
        return seasonAdjustedMorning();
      } else {
        final portion = params.nightPortions()[Prayer.fajr]!;
        final seconds = (portion * nightSeconds).round();
        return sunriseTime.addSeconds(-seconds);
      }
    }

    DateTime computeSafeIsha() {
      if (params.method == CalculationMethod.moonsightingCommittee) {
        return seasonAdjustedEvening();
      } else {
        final portion = params.nightPortions()[Prayer.isha]!;
        final seconds = (portion * nightSeconds).round();
        return sunsetTime.addSeconds(seconds);
      }
    }

    DateTime computeSafeIshaBefore() {
      if (params.method == CalculationMethod.moonsightingCommittee) {
        // Use season adjustment anchored to yesterday's sunset
        return Astronomical.seasonAdjustedEveningTwilight(
            coordinates.latitude, date.dayOfYear, date.year, sunsetBeforeTime);
      } else {
        final portion = params.nightPortions()[Prayer.isha]!;
        final seconds = (portion * nightSecondsBefore).round();
        return sunsetBeforeTime.addSeconds(seconds);
      }
    }

    // Special high latitude case for Moonsighting Committee
    if (params.method == CalculationMethod.moonsightingCommittee &&
        coordinates.latitude >= 55) {
      final double fraction = nightSeconds / 7; // 1/7 of the night
      final fallbackFajr = sunriseTime.addSeconds(-fraction.round());
      final fallbackFajrAfter = sunriseAfterTime.addSeconds(-fraction.round());
      if (fajrTime.isAfter(sunriseTime) || // clearly invalid
          fajrTime.difference(sunriseTime).inMinutes > 300) {
        // >5h earlier rarely realistic
        fajrTime = fallbackFajr;
        fajrAfterTime = fallbackFajrAfter;
        estimated.add(Prayer.fajr);
      }
    }

    // Generic validity checks: Fajr must precede sunrise
    DateTime safeFajr = computeSafeFajr();
    if (!fajrTime.isBefore(sunriseTime)) {
      fajrTime = safeFajr;
      estimated.add(Prayer.fajr);
    } else if (safeFajr.isAfter(fajrTime)) {
      // angle solution earlier than safety window -> use safety
      fajrTime = safeFajr;
      estimated.add(Prayer.fajr);
    }

    // Re-evaluate fajrAfter similarly relative to next sunrise
    if (!fajrAfterTime.isBefore(sunriseAfterTime)) {
      // Use tomorrow's safe fajr calculation based on TOMORROW'S night (sunsetAfter -> sunriseAfterAfter)
      final portion = params.nightPortions()[Prayer.fajr]!;
      final seconds = (portion * nightSecondsAfter).round();
      fajrAfterTime = sunriseAfterTime.addSeconds(-seconds);
      estimated.add(Prayer.fajr);
    }

    // Isha fallbacks
    DateTime safeIsha = computeSafeIsha();
    // If isha before maghrib (invalid) OR outside expected safety window (too late earlier than safety?)
    if (!ishaTime.isAfter(maghribTime)) {
      ishaTime = safeIsha;
      estimated.add(Prayer.isha);
    } else if (safeIsha.isBefore(ishaTime)) {
      // if safe is earlier than angle (angle too deep / unreachable) we cap at safe
      ishaTime = safeIsha;
      estimated.add(Prayer.isha);
    }

    // Validate ishaBefore using yesterday's night safety
    final DateTime safeIshaPrev = computeSafeIshaBefore();
    if (!ishaBeforeTime.isAfter(sunsetBeforeTime)) {
      ishaBeforeTime = safeIshaPrev;
      estimated.add(Prayer.isha);
    } else if (safeIshaPrev.isBefore(ishaBeforeTime)) {
      ishaBeforeTime = safeIshaPrev;
      estimated.add(Prayer.isha);
    }

    // Fixed interval Isha overrides angle (e.g. Umm Al-Qura)
    if (params.ishaInterval != null && params.ishaInterval! > 0) {
      ishaTime = sunsetTime.addMinutes(params.ishaInterval!);
      ishaBeforeTime = sunsetBeforeTime.addMinutes(params.ishaInterval!);
      estimated.add(Prayer.isha);
    }

    // Angle-based Maghrib override when configured
    if (params.maghribAngle != null) {
      final DateTime angleBasedMaghrib = TimeComponents(
        solarToday.hourAngle(-1 * params.maghribAngle!, true),
      ).utcDate(date.year, date.month, date.day);
      if (maghribTime.isBefore(angleBasedMaghrib) &&
          ishaTime.isAfter(angleBasedMaghrib)) {
        maghribTime = angleBasedMaghrib;
      }
    }

    // Apply per-prayer adjustments (methodAdjustments + user adjustments)
    final int fajrAdjustment = (params.adjustments[Prayer.fajr] ?? 0) +
        (params.methodAdjustments[Prayer.fajr] ?? 0);
    final int sunriseAdjustment = (params.adjustments[Prayer.sunrise] ?? 0) +
        (params.methodAdjustments[Prayer.sunrise] ?? 0);
    final int dhuhrAdjustment = (params.adjustments[Prayer.dhuhr] ?? 0) +
        (params.methodAdjustments[Prayer.dhuhr] ?? 0);
    final int asrAdjustment = (params.adjustments[Prayer.asr] ?? 0) +
        (params.methodAdjustments[Prayer.asr] ?? 0);
    final int maghribAdjustment = (params.adjustments[Prayer.maghrib] ?? 0) +
        (params.methodAdjustments[Prayer.maghrib] ?? 0);
    final int ishaAdjustment = (params.adjustments[Prayer.isha] ?? 0) +
        (params.methodAdjustments[Prayer.isha] ?? 0);

    // Apply adjustments
    fajrTime = fajrTime.addMinutes(fajrAdjustment);
    final adjustedSunriseTime = sunriseTime.addMinutes(sunriseAdjustment);
    dhuhrTime = dhuhrTime.addMinutes(dhuhrAdjustment);
    asrTime = asrTime.addMinutes(asrAdjustment);
    maghribTime = maghribTime.addMinutes(maghribAdjustment);
    ishaTime = ishaTime.addMinutes(ishaAdjustment);
    // Secondary fields
    fajrAfterTime = fajrAfterTime.addMinutes(fajrAdjustment);
    ishaBeforeTime = ishaBeforeTime.addMinutes(ishaAdjustment);

    return PrayerTimesData(
      date: date,
      coordinates: coordinates,
      params: params,
      fajr:
          roundToMinutes ? fajrTime.roundedMinute(precision: false) : fajrTime,
      sunrise: roundToMinutes
          ? adjustedSunriseTime.roundedMinute(precision: false)
          : adjustedSunriseTime,
      dhuhr: roundToMinutes
          ? dhuhrTime.roundedMinute(precision: false)
          : dhuhrTime,
      asr: roundToMinutes ? asrTime.roundedMinute(precision: false) : asrTime,
      maghrib: roundToMinutes
          ? maghribTime.roundedMinute(precision: false)
          : maghribTime,
      isha:
          roundToMinutes ? ishaTime.roundedMinute(precision: false) : ishaTime,
      ishaBefore: roundToMinutes
          ? ishaBeforeTime.roundedMinute(precision: false)
          : ishaBeforeTime,
      fajrAfter: roundToMinutes
          ? fajrAfterTime.roundedMinute(precision: false)
          : fajrAfterTime,
      estimatedPrayers: estimated,
    );
  }

  /// Validates input parameters to prevent common errors
  void _validateInputs(Coordinates coordinates, CalculationParameters params) {
    if (coordinates.latitude.abs() > 90) {
      throw ArgumentError(
          'Latitude must be between -90 and 90 degrees, got ${coordinates.latitude}');
    }
    if (coordinates.longitude.abs() > 180) {
      throw ArgumentError(
          'Longitude must be between -180 and 180 degrees, got ${coordinates.longitude}');
    }
    if (params.fajrAngle <= 0 || params.fajrAngle > 30) {
      throw ArgumentError(
          'Fajr angle must be between 0 and 30 degrees, got ${params.fajrAngle}');
    }

    // Only validate isha angle if not using interval
    if (params.ishaInterval == null || params.ishaInterval! <= 0) {
      if (params.ishaAngle <= 0 || params.ishaAngle > 30) {
        throw ArgumentError(
            'Isha angle must be between 0 and 30 degrees when not using interval, got ${params.ishaAngle}');
      }
    }

    if (params.ishaInterval != null && params.ishaInterval! < 0) {
      throw ArgumentError(
          'Isha interval must be positive, got ${params.ishaInterval}');
    }
  }

  /// Convenience method for quick prayer time calculation
  static PrayerTimesData forLocation({
    required DateTime date,
    required double latitude,
    required double longitude,
    required CalculationMethod method,
    bool roundToMinutes = true,
  }) {
    final params = method.parameters;
    return const PrayerTimesCalculator().calculate(
      date: date,
      coordinates: Coordinates(latitude, longitude),
      params: params,
      roundToMinutes: roundToMinutes,
    );
  }
}
