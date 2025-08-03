/// Collection of small Dart extensions that replace helper functions
/// originally ported from JavaScript.
///
/// Keeping them together simplifies import management while we migrate the
/// codebase.  Once the refactor is complete we can split into domain-specific
/// files if desired.

import 'dart:math' as math;

extension DateTimeExtensions on DateTime {
  /// Returns the day of year (1-based).
  int get dayOfYear {
    final first = DateTime(year, 1, 1);
    return difference(first).inDays + 1;
  }

  /// Adds [days] days and returns a new `DateTime`.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Adds [seconds] seconds and returns a new `DateTime`.
  DateTime addSeconds(int seconds) => add(Duration(seconds: seconds));

  /// Adds [minutes] minutes and returns a new `DateTime`.
  DateTime addMinutes(int minutes) => add(Duration(minutes: minutes));

  /// Rounds to nearest minute unless [precision] is true, in which case the
  /// original instance is returned.
  DateTime roundedMinute({bool precision = true}) {
    if (precision) return this;
    final seconds = toUtc().second;
    final offset = seconds >= 30 ? 60 - seconds : -seconds;
    return add(Duration(seconds: offset));
  }
}

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
