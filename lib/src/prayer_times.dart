import 'package:adhan_dart/src/astronomical.dart';
import 'package:adhan_dart/src/calculation_method.dart';
import 'package:adhan_dart/src/coordinates.dart';
import 'package:adhan_dart/src/extensions.dart';
import 'package:adhan_dart/src/madhab.dart';
import 'package:adhan_dart/src/polar_circle_resolution.dart';
import 'package:adhan_dart/src/prayer.dart';
import 'package:adhan_dart/src/rounding.dart';
import 'package:adhan_dart/src/solar_time.dart';
import 'package:adhan_dart/src/sunnah_times.dart';
import 'package:adhan_dart/src/time_components.dart';
import 'package:meta/meta.dart';

/// Unifies the calculation logic and the result data into a single class.
@immutable
class PrayerTimes {
  final DateTime date;
  final Coordinates coordinates;
  final CalculationMethod calculationMethod;

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime sunset;
  final DateTime maghrib;
  final DateTime isha;

  final DateTime ishaBefore;
  final DateTime fajrAfter;

  /// Prayers whose times were produced using a safety fallback.
  ///
  /// Only core [Prayer] values are tracked; cross-day helpers ([ishaBefore],
  /// [fajrAfter]) are omitted even when safe-bound clamps adjust them.
  final Set<Prayer> estimatedPrayers;

  PrayerTimes copyWith({
    DateTime? date,
    Coordinates? coordinates,
    CalculationMethod? calculationMethod,
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? sunset,
    DateTime? maghrib,
    DateTime? isha,
    DateTime? ishaBefore,
    DateTime? fajrAfter,
    Set<Prayer>? estimatedPrayers,
  }) {
    return PrayerTimes._(
      date: date ?? this.date,
      coordinates: coordinates ?? this.coordinates,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      sunset: sunset ?? this.sunset,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      ishaBefore: ishaBefore ?? this.ishaBefore,
      fajrAfter: fajrAfter ?? this.fajrAfter,
      estimatedPrayers: estimatedPrayers == null
          ? this.estimatedPrayers
          : Set<Prayer>.unmodifiable(estimatedPrayers),
    );
  }

  const PrayerTimes._({
    required this.date,
    required this.coordinates,
    required this.calculationMethod,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.ishaBefore,
    required this.fajrAfter,
    this.estimatedPrayers = const {},
  });

  /// Factory constructor that performs the prayer times calculation.
  factory PrayerTimes({
    required Coordinates coordinates,
    required DateTime date,
    required CalculationMethod calculationMethod,
    bool roundToMinutes = true,
  }) {
    // Early validation
    _validateInputs(coordinates, calculationMethod);

    // 1. Initial Solar Calculation
    final DateTime dateBefore = date.addDays(-1);
    final DateTime dateAfter = date.addDays(1);

    SolarTime solarToday = SolarTime(date, coordinates);
    SolarTime solarBefore = SolarTime(dateBefore, coordinates);
    SolarTime solarAfter = SolarTime(dateAfter, coordinates);
    SolarTime solarAfterAfter = SolarTime(dateAfter.addDays(1), coordinates);

    // 2. Resolve Invalid Times (Polar Circle / High Latitude)
    bool needsResolution =
        solarToday.sunrise.isNaN ||
        solarToday.sunset.isNaN ||
        solarAfter.sunrise.isNaN;

    var resolver = calculationMethod.polarCircleResolution;

    if (needsResolution && resolver != PolarCircleResolution.unresolved) {
      final resolvedToday = PolarCircleResolver.resolve(
        resolver,
        date,
        coordinates,
      );
      final resolvedBefore = PolarCircleResolver.resolve(
        resolver,
        dateBefore,
        coordinates,
      );
      final resolvedAfter = PolarCircleResolver.resolve(
        resolver,
        dateAfter,
        coordinates,
      );
      final resolvedAfterAfter = PolarCircleResolver.resolve(
        resolver,
        dateAfter.addDays(1),
        coordinates,
      );

      solarToday = resolvedToday.solarTime;
      solarBefore = resolvedBefore.solarTime;
      solarAfter = resolvedAfter.solarTime;
      solarAfterAfter = resolvedAfterAfter.solarTime;
    }

    // 3. Fallback for Extreme Failures
    var usedEmergencyFallback = false;
    if (solarToday.sunrise.isNaN || solarToday.sunset.isNaN) {
      usedEmergencyFallback = true;
      final safeCoords = Coordinates(
        45.0 * coordinates.latitude.sign,
        coordinates.longitude,
      );
      solarToday = SolarTime(date, safeCoords);
      solarBefore = SolarTime(dateBefore, safeCoords);
      solarAfter = SolarTime(dateAfter, safeCoords);
      solarAfterAfter = SolarTime(dateAfter.addDays(1), safeCoords);
    }

    // 4. Calculate Core Times
    final shadowLengthValue = shadowLength(calculationMethod.madhab).toDouble();

    DateTime dhuhrTime = TimeComponents(
      solarToday.transit,
    ).utcDate(date.year, date.month, date.day);

    DateTime sunriseTime = TimeComponents(
      solarToday.sunrise,
    ).utcDate(date.year, date.month, date.day);
    DateTime sunsetTime = TimeComponents(
      solarToday.sunset,
    ).utcDate(date.year, date.month, date.day);

    double asrAngleTime = solarToday.afternoon(shadowLengthValue);
    var usedAsrEmergencyFallback = false;
    if (asrAngleTime.isNaN) {
      usedAsrEmergencyFallback = true;
      final safeSolar = SolarTime(
        date,
        Coordinates(45.0 * coordinates.latitude.sign, coordinates.longitude),
      );
      asrAngleTime = safeSolar.afternoon(shadowLengthValue);
    }
    DateTime asrTime = TimeComponents(
      asrAngleTime,
    ).utcDate(date.year, date.month, date.day);

    DateTime sunriseAfterTime = TimeComponents(
      solarAfter.sunrise,
    ).utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    DateTime sunsetBeforeTime = TimeComponents(
      solarBefore.sunset,
    ).utcDate(dateBefore.year, dateBefore.month, dateBefore.day);
    DateTime sunsetAfterTime = TimeComponents(
      solarAfter.sunset,
    ).utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    final DateTime dateAfterAfter = dateAfter.addDays(1);
    DateTime sunriseAfterAfterTime = TimeComponents(
      solarAfterAfter.sunrise,
    ).utcDate(dateAfterAfter.year, dateAfterAfter.month, dateAfterAfter.day);

    final int nightSeconds = sunriseAfterTime.difference(sunsetTime).inSeconds;
    final int nightSecondsBefore = sunriseTime
        .difference(sunsetBeforeTime)
        .inSeconds;
    final int nightSecondsAfter = sunriseAfterAfterTime
        .difference(sunsetAfterTime)
        .inSeconds;

    // 5. Calculate Prayers
    DateTime maghribTime = sunsetTime;

    DateTime? fajrTime;
    double fajrAngleTime = solarToday.hourAngle(
      -1 * calculationMethod.fajrAngle,
      false,
    );
    if (!fajrAngleTime.isNaN) {
      fajrTime = TimeComponents(
        fajrAngleTime,
      ).utcDate(date.year, date.month, date.day);
    }

    DateTime? fajrAfterTime;
    double fajrAfterAngleTime = solarAfter.hourAngle(
      -1 * calculationMethod.fajrAngle,
      false,
    );
    if (!fajrAfterAngleTime.isNaN) {
      fajrAfterTime = TimeComponents(
        fajrAfterAngleTime,
      ).utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    }

    DateTime? ishaTime;
    if (calculationMethod.ishaInterval != null &&
        calculationMethod.ishaInterval! > 0) {
      ishaTime = sunsetTime.addMinutes(calculationMethod.ishaInterval!);
    } else {
      double ishaAngleTime = solarToday.hourAngle(
        -1 * calculationMethod.ishaAngle,
        true,
      );
      if (!ishaAngleTime.isNaN) {
        ishaTime = TimeComponents(
          ishaAngleTime,
        ).utcDate(date.year, date.month, date.day);
      }
    }

    DateTime? ishaBeforeTime;
    if (calculationMethod.ishaInterval != null &&
        calculationMethod.ishaInterval! > 0) {
      ishaBeforeTime = sunsetBeforeTime.addMinutes(
        calculationMethod.ishaInterval!,
      );
    } else {
      double ishaBeforeAngleTime = solarBefore.hourAngle(
        -1 * calculationMethod.ishaAngle,
        true,
      );
      if (!ishaBeforeAngleTime.isNaN) {
        ishaBeforeTime = TimeComponents(
          ishaBeforeAngleTime,
        ).utcDate(dateBefore.year, dateBefore.month, dateBefore.day);
      }
    }

    final Set<Prayer> estimated = <Prayer>{};

    DateTime seasonAdjustedMorning(DateTime sunrise) =>
        Astronomical.seasonAdjustedMorningTwilight(
          coordinates.latitude,
          date.dayOfYear,
          date.year,
          sunrise,
        );
    DateTime seasonAdjustedEvening(DateTime sunset) =>
        Astronomical.seasonAdjustedEveningTwilight(
          coordinates.latitude,
          date.dayOfYear,
          date.year,
          sunset,
          calculationMethod.shafaq,
        );

    DateTime computeSafeFajr(DateTime sunrise, int nightSecs) {
      if (calculationMethod is MoonsightingCommittee) {
        return seasonAdjustedMorning(sunrise);
      } else {
        final portion = calculationMethod.nightPortions()[Prayer.fajr]!;
        final seconds = (portion * nightSecs).round();
        return sunrise.addSeconds(-seconds);
      }
    }

    DateTime computeSafeIsha(DateTime sunset, int nightSecs) {
      if (calculationMethod is MoonsightingCommittee) {
        return seasonAdjustedEvening(sunset);
      } else {
        final portion = calculationMethod.nightPortions()[Prayer.isha]!;
        final seconds = (portion * nightSecs).round();
        return sunset.addSeconds(seconds);
      }
    }

    // High Latitude / Moonsighting Special
    if (calculationMethod is MoonsightingCommittee &&
        coordinates.latitude >= 55) {
      final double fraction = nightSeconds / 7;
      fajrTime = sunriseTime.addSeconds(-fraction.round());

      final double fractionAfter = nightSecondsAfter / 7;
      fajrAfterTime = sunriseAfterTime.addSeconds(-fractionAfter.round());

      if (calculationMethod.ishaInterval == null ||
          calculationMethod.ishaInterval! <= 0) {
        final double fractionIsha = nightSeconds / 7;
        ishaTime = sunsetTime.addSeconds(fractionIsha.round());
      }
    }

    // Validations & Adjustments
    final safeFajr = computeSafeFajr(sunriseTime, nightSeconds);
    if (fajrTime == null || !fajrTime.isBefore(sunriseTime)) {
      fajrTime = safeFajr;
      estimated.add(Prayer.fajr);
    } else if (safeFajr.isAfter(fajrTime)) {
      fajrTime = safeFajr;
      estimated.add(Prayer.fajr);
    }

    final safeFajrAfter = computeSafeFajr(sunriseAfterTime, nightSecondsAfter);
    if (fajrAfterTime == null || !fajrAfterTime.isBefore(sunriseAfterTime)) {
      fajrAfterTime = safeFajrAfter;
    } else if (safeFajrAfter.isAfter(fajrAfterTime)) {
      fajrAfterTime = safeFajrAfter;
    }

    final safeIsha = computeSafeIsha(sunsetTime, nightSeconds);
    if (ishaTime == null || !ishaTime.isAfter(maghribTime)) {
      ishaTime = safeIsha;
      estimated.add(Prayer.isha);
    } else if (safeIsha.isBefore(ishaTime)) {
      ishaTime = safeIsha;
      estimated.add(Prayer.isha);
    }

    final safeIshaBefore = computeSafeIsha(
      sunsetBeforeTime,
      nightSecondsBefore,
    );
    if (ishaBeforeTime == null || !ishaBeforeTime.isAfter(sunsetBeforeTime)) {
      ishaBeforeTime = safeIshaBefore;
    } else if (safeIshaBefore.isBefore(ishaBeforeTime)) {
      ishaBeforeTime = safeIshaBefore;
    }

    if (calculationMethod.maghribAngle != null) {
      double maghribAngleTime = solarToday.hourAngle(
        -1 * calculationMethod.maghribAngle!,
        true,
      );
      if (!maghribAngleTime.isNaN) {
        final DateTime angleBasedMaghrib = TimeComponents(
          maghribAngleTime,
        ).utcDate(date.year, date.month, date.day);
        if (maghribTime.isBefore(angleBasedMaghrib) &&
            ishaTime.isAfter(angleBasedMaghrib)) {
          maghribTime = angleBasedMaghrib;
        }
      }
    }

    // 6. Final Adjustments
    final int fajrAdj =
        (calculationMethod.adjustments[Prayer.fajr] ?? 0) +
        (calculationMethod.methodAdjustments[Prayer.fajr] ?? 0);
    final int sunriseAdj =
        (calculationMethod.adjustments[Prayer.sunrise] ?? 0) +
        (calculationMethod.methodAdjustments[Prayer.sunrise] ?? 0);
    final int dhuhrAdj =
        (calculationMethod.adjustments[Prayer.dhuhr] ?? 0) +
        (calculationMethod.methodAdjustments[Prayer.dhuhr] ?? 0);
    final int asrAdj =
        (calculationMethod.adjustments[Prayer.asr] ?? 0) +
        (calculationMethod.methodAdjustments[Prayer.asr] ?? 0);
    final int maghribAdj =
        (calculationMethod.adjustments[Prayer.maghrib] ?? 0) +
        (calculationMethod.methodAdjustments[Prayer.maghrib] ?? 0);
    final int ishaAdj =
        (calculationMethod.adjustments[Prayer.isha] ?? 0) +
        (calculationMethod.methodAdjustments[Prayer.isha] ?? 0);

    if (usedEmergencyFallback) {
      estimated.addAll({
        Prayer.fajr,
        Prayer.sunrise,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      });
    }
    if (usedAsrEmergencyFallback) {
      estimated.add(Prayer.asr);
    }

    final rounding = calculationMethod.rounding;
    final sunsetRounded = roundToMinutes
        ? sunsetTime.roundedMinute(rounding: rounding)
        : sunsetTime;

    return PrayerTimes._(
      date: date,
      coordinates: coordinates,
      calculationMethod: calculationMethod,
      fajr: _adjust(
        fajrTime,
        fajrAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      sunrise: _adjust(
        sunriseTime,
        sunriseAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      dhuhr: _adjust(
        dhuhrTime,
        dhuhrAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      asr: _adjust(asrTime, asrAdj, roundToMinutes, calculationMethod.rounding),
      sunset: sunsetRounded,
      maghrib: _adjust(
        maghribTime,
        maghribAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      isha: _adjust(
        ishaTime,
        ishaAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      ishaBefore: _adjust(
        ishaBeforeTime,
        ishaAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      fajrAfter: _adjust(
        fajrAfterTime,
        fajrAdj,
        roundToMinutes,
        calculationMethod.rounding,
      ),
      estimatedPrayers:
          estimated.isEmpty ? const {} : Set<Prayer>.unmodifiable(estimated),
    );
  }

  static DateTime _adjust(
    DateTime time,
    int minutes,
    bool round,
    Rounding rounding,
  ) {
    final adjusted = time.addMinutes(minutes);
    return round ? adjusted.roundedMinute(rounding: rounding) : adjusted;
  }

  static void _validateInputs(
    Coordinates coordinates,
    CalculationMethod method,
  ) {
    if (coordinates.latitude.abs() > 90) {
      throw ArgumentError(
        'Latitude must be between -90 and 90 degrees, got ${coordinates.latitude}',
      );
    }
    if (coordinates.longitude.abs() > 180) {
      throw ArgumentError(
        'Longitude must be between -180 and 180 degrees, got ${coordinates.longitude}',
      );
    }
    if (method.fajrAngle <= 0 || method.fajrAngle > 30) {
      throw ArgumentError(
        'Fajr angle must be between 0 and 30 degrees, got ${method.fajrAngle}',
      );
    }
    if (method.ishaInterval == null || method.ishaInterval! <= 0) {
      if (method.ishaAngle <= 0 || method.ishaAngle > 30) {
        throw ArgumentError(
          'Isha angle must be between 0 and 30 degrees when not using interval, got ${method.ishaAngle}',
        );
      }
    }
    if (method.ishaInterval != null && method.ishaInterval! < 0) {
      throw ArgumentError(
        'Isha interval must be positive, got ${method.ishaInterval}',
      );
    }
  }

  /// Convenience accessor for Sunnah times
  SunnahTimes get sunnah => SunnahTimes(this);

  /// Returns the current prayer based on the given [time] (or now).
  Prayer currentPrayer({DateTime? time}) {
    final now = time ?? DateTime.now();
    if (now.isAfter(isha) || now.isAtSameMomentAs(isha)) {
      return Prayer.isha;
    }
    if (now.isAfter(maghrib) || now.isAtSameMomentAs(maghrib)) {
      return Prayer.maghrib;
    }
    if (now.isAfter(asr) || now.isAtSameMomentAs(asr)) {
      return Prayer.asr;
    }
    if (now.isAfter(dhuhr) || now.isAtSameMomentAs(dhuhr)) {
      return Prayer.dhuhr;
    }
    if (now.isAfter(sunrise) || now.isAtSameMomentAs(sunrise)) {
      return Prayer.sunrise;
    }
    if (now.isAfter(fajr) || now.isAtSameMomentAs(fajr)) {
      return Prayer.fajr;
    }
    return Prayer.ishaBefore;
  }

  /// Returns the next prayer based on the given [time] (or now).
  Prayer nextPrayer({DateTime? time}) {
    final now = time ?? DateTime.now();
    if (now.isBefore(fajr)) return Prayer.fajr;
    if (now.isBefore(sunrise)) return Prayer.sunrise;
    if (now.isBefore(dhuhr)) return Prayer.dhuhr;
    if (now.isBefore(asr)) return Prayer.asr;
    if (now.isBefore(maghrib)) return Prayer.maghrib;
    if (now.isBefore(isha)) return Prayer.isha;
    return Prayer.fajrAfter;
  }

  /// Returns the time of the next prayer based on the given [time] (or now).
  DateTime nextPrayerTime({DateTime? time}) {
    return timeForPrayer(nextPrayer(time: time));
  }

  /// Returns the time for the specified [prayer].
  DateTime timeForPrayer(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajr;
      case Prayer.sunrise:
        return sunrise;
      case Prayer.dhuhr:
        return dhuhr;
      case Prayer.asr:
        return asr;
      case Prayer.maghrib:
        return maghrib;
      case Prayer.isha:
        return isha;
      case Prayer.ishaBefore:
        return ishaBefore;
      case Prayer.fajrAfter:
        return fajrAfter;
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PrayerTimes &&
            date == other.date &&
            coordinates == other.coordinates &&
            calculationMethod == other.calculationMethod &&
            fajr == other.fajr &&
            sunrise == other.sunrise &&
            dhuhr == other.dhuhr &&
            asr == other.asr &&
            sunset == other.sunset &&
            maghrib == other.maghrib &&
            isha == other.isha &&
            ishaBefore == other.ishaBefore &&
            fajrAfter == other.fajrAfter &&
            _setEquals(estimatedPrayers, other.estimatedPrayers);
  }

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    return a.length == b.length && a.containsAll(b);
  }

  @override
  int get hashCode => Object.hash(
    date,
    coordinates,
    calculationMethod,
    fajr,
    sunrise,
    dhuhr,
    asr,
    sunset,
    maghrib,
    isha,
    ishaBefore,
    fajrAfter,
    Object.hashAllUnordered(estimatedPrayers),
  );

  @override
  String toString() {
    return 'PrayerTimes(date: $date, fajr: $fajr, sunrise: $sunrise, dhuhr: $dhuhr, asr: $asr, maghrib: $maghrib, isha: $isha)';
  }
}
