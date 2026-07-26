/// Dart extensions and utility functions for the adhan_dart library.
/// Provides idiomatic Dart replacements for legacy JavaScript-style helpers.
library;

import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';

// Mathematical utility functions
double degreesToRadians(double degrees) => (degrees * math.pi) / 180.0;

double normalizeToScale(double number, double max) {
  if (number.isNaN) return double.nan;
  return number - (max * ((number / max).floor()));
}

double quadrantShiftAngle(double angle) {
  if (angle.isNaN) return double.nan;
  if (angle >= -180 && angle <= 180) {
    return angle;
  }
  return angle - (360 * (angle / 360).round());
}

double radiansToDegrees(double radians) => (radians * 180.0) / math.pi;

double unwindAngle(double angle) => normalizeToScale(angle, 360.0);

/// Porter parity for adhan-js `Madhab.getShadowLength()`.
///
/// Equivalent to the top-level [shadowLength] function exported from
/// `madhab.dart`.
extension MadhabShadowLength on Madhab {
  /// Asr shadow length multiplier (1 = Shafi'i, 2 = Hanafi).
  int get asrShadowLength => shadowLength(this);
}

/// Extension to provide convenient prayer times calculation from coordinates
extension CoordinatesExtension on Coordinates {
  /// Calculate prayer times for a specific date using the specified method
  PrayerTimes prayerTimesFor(
    DateTime date,
    CalculationMethod method, {
    bool roundToMinutes = true,
  }) {
    return PrayerTimes(
      date: date,
      coordinates: this,
      calculationMethod: method,
      roundToMinutes: roundToMinutes,
    );
  }

  /// Calculate prayer times for today using the specified method
  PrayerTimes todaysPrayerTimes(
    CalculationMethod method, {
    bool roundToMinutes = true,
  }) {
    return PrayerTimes(
      date: DateTime.now(),
      coordinates: this,
      calculationMethod: method,
      roundToMinutes: roundToMinutes,
    );
  }
}

/// Extensions for common DateTime operations.
extension DateTimeExtensions on DateTime {
  /// Returns the day of year (1-based, calendar-safe).
  int get dayOfYear {
    final diff = difference(DateTime(year, 1, 1, 0, 0));
    return diff.inDays + 1; // 1st Jan should be day 1
  }

  /// Adds [days] days and returns a new `DateTime`.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Adds [minutes] minutes and returns a new `DateTime`.
  DateTime addMinutes(int minutes) => add(Duration(minutes: minutes));

  /// Adds [seconds] seconds and returns a new `DateTime`.
  DateTime addSeconds(int seconds) => add(Duration(seconds: seconds));

  /// Rounds to nearest minute unless [precision] is true, in which case the
  /// original instance is returned.
  DateTime roundedMinute({Rounding rounding = Rounding.nearest}) {
    if (rounding == Rounding.none) {
      return this;
    }

    final seconds = toUtc().second;
    int offset;

    if (rounding == Rounding.up) {
      offset = 60 - seconds;
    } else {
      offset = seconds >= 30 ? 60 - seconds : -1 * seconds;
    }

    return addSeconds(offset);
  }
}

/// Extensions for common angle operations on numbers.
extension NumAngleExtensions on double {
  /// Converts radians to degrees.
  double get toDegrees => (this * 180.0) / math.pi;

  /// Converts degrees to radians.
  double get toRadians => (this * math.pi) / 180.0;

  /// Shifts an angle into the (-180,180] range.
  double quadrantShift() {
    if (this >= -180 && this <= 180) return toDouble();
    return this - (360 * (this / 360).round());
  }

  /// Normalises an angle to a [0,360) scale.
  double unwind() => this - (360 * (this / 360).floor());
}
