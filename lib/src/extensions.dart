/// Dart extensions and utility functions for the adhan_dart library.
/// Provides idiomatic Dart replacements for legacy JavaScript-style helpers.
library extensions;

import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';

int dayOfYear(DateTime date) {
  final diff = date.difference(DateTime(date.year, 1, 1, 0, 0));
  return diff.inDays + 1; // 1st Jan should be day 1
}

// Mathematical utility functions
double degreesToRadians(double degrees) => (degrees * math.pi) / 180.0;

double normalizeToScale(double number, double max) {
  return number - (max * ((number / max).floor()));
}

double quadrantShiftAngle(double angle) {
  if (angle >= -180 && angle <= 180) {
    return angle;
  }
  return angle - (360 * (angle / 360).round());
}

double radiansToDegrees(double radians) => (radians * 180.0) / math.pi;

double unwindAngle(double angle) => normalizeToScale(angle, 360.0);

extension CalculationMethodParametersExtension on CalculationMethod {
  CalculationParameters get parameters {
    switch (this) {
      case CalculationMethod.muslimWorldLeague:
        return CalculationMethodParameters.muslimWorldLeague();
      case CalculationMethod.egyptian:
        return CalculationMethodParameters.egyptian();
      case CalculationMethod.karachi:
        return CalculationMethodParameters.karachi();
      case CalculationMethod.ummAlQura:
        return CalculationMethodParameters.ummAlQura();
      case CalculationMethod.moonsightingCommittee:
        return CalculationMethodParameters.moonsightingCommittee();
      case CalculationMethod.dubai:
        return CalculationMethodParameters.dubai();
      case CalculationMethod.kuwait:
        return CalculationMethodParameters.kuwait();
      case CalculationMethod.morocco:
        return CalculationMethodParameters.morocco();
      case CalculationMethod.northAmerica:
        return CalculationMethodParameters.northAmerica();
      case CalculationMethod.other:
        return CalculationMethodParameters.other();
      case CalculationMethod.qatar:
        return CalculationMethodParameters.qatar();
      case CalculationMethod.singapore:
        return CalculationMethodParameters.singapore();
      case CalculationMethod.tehran:
        return CalculationMethodParameters.tehran();
      case CalculationMethod.turkiye:
        return CalculationMethodParameters.turkiye();
    }
  }
}

/// Extension to provide convenient prayer times calculation from coordinates
extension CoordinatesExtension on Coordinates {
  /// Calculate prayer times for a specific date using the specified method
  PrayerTimesData prayerTimesFor(DateTime date, CalculationMethod method,
      {bool precision = false}) {
    return PrayerTimesData.calculate(
      date: date,
      coordinates: this,
      calculationParameters: method.parameters,
      precision: precision,
    );
  }

  /// Calculate prayer times for today using the specified method
  PrayerTimesData todaysPrayerTimes(CalculationMethod method,
      {bool precision = false}) {
    return PrayerTimesData.calculate(
      date: DateTime.now(),
      coordinates: this,
      calculationParameters: method.parameters,
      precision: precision,
    );
  }
}

/// Extensions for common DateTime operations.
extension DateTimeExtensions on DateTime {
  /// Returns the day of year (1-based).
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
  DateTime roundedMinute({bool precision = true}) {
    if (precision) return this;
    final seconds = toUtc().second % 60;
    final offset = seconds >= 30 ? 60 - seconds : -1 * seconds;
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
