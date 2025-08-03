/// Immutable value object holding the obligatory prayers
/// Modern, immutable prayer times implementation for the adhan_dart library.
/// 
/// This class provides a clean, Dart-idiomatic API for calculating Islamic prayer times.
/// It replaces the legacy mutable PrayerTimes class with an immutable data structure
/// and separate calculation logic.
/// 
/// Key features:
/// - Immutable data structure (thread-safe)
/// - Simple static factory method for easy usage
/// - Non-nullable convenience methods
/// - Proper Dart naming conventions
/// - Full backward compatibility during migration
library prayer_times_data;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:meta/meta.dart';

@immutable
class PrayerTimesData {
  /// Convenience factory method for calculating prayer times.
  /// This is the recommended way to create prayer times.
  static PrayerTimesData calculate({
    required DateTime date,
    required Coordinates coordinates,
    required CalculationParameters calculationParameters,
    bool precision = false,
  }) {
    return const PrayerTimesCalculator().calculate(
      date: date,
      coordinates: coordinates,
      params: calculationParameters,
      precision: precision,
    );
  }

  /// Gregorian date at local midnight of the calculation location.
  final DateTime date;

  /// Geographic coordinates used for the calculation.
  final Coordinates coordinates;

  /// The calculation method / parameters that produced these times.
  final CalculationParameters params;

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Convenience: high-latitude adjustment before isha.
  final DateTime ishaBefore;

  /// Convenience: high-latitude adjustment after fajr.
  final DateTime fajrAfter;

  // Convenience API parity with legacy PrayerTimes -----------------------
  /// Returns the current prayer at [date]. Uses system time if [date] is omitted.
  /// Returns the active prayer, or the most recent prayer if between prayer times.
  Prayer currentPrayer({DateTime? date}) {
    final now = date ?? DateTime.now();
    if (now.isBefore(fajr)) {
      // Before fajr - return previous day's isha (ishaBefore)
      return Prayer.isha;
    }
    if (now.isBefore(sunrise)) return Prayer.fajr;
    if (now.isBefore(dhuhr)) return Prayer.sunrise;
    if (now.isBefore(asr)) return Prayer.dhuhr;
    if (now.isBefore(maghrib)) return Prayer.asr;
    if (now.isBefore(isha)) return Prayer.maghrib;
    return Prayer.isha;
  }

  /// Returns the next prayer after [date]. Uses system time if [date] is omitted.
  /// Returns the next upcoming prayer, or fajr of the next day if after isha.
  Prayer nextPrayer({DateTime? date}) {
    final now = date ?? DateTime.now();
    if (now.isBefore(fajr)) return Prayer.fajr;
    if (now.isBefore(sunrise)) return Prayer.sunrise;
    if (now.isBefore(dhuhr)) return Prayer.dhuhr;
    if (now.isBefore(asr)) return Prayer.asr;
    if (now.isBefore(maghrib)) return Prayer.maghrib;
    if (now.isBefore(isha)) return Prayer.isha;
    // After isha - return next day's fajr (fajrAfter)
    return Prayer.fajr;
  }

  /// Returns the time for the specified [prayer].
  DateTime? timeForPrayer(Prayer prayer) {
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
      default:
        return null;
    }
  }

  const PrayerTimesData({
    required this.date,
    required this.coordinates,
    required this.params,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.ishaBefore,
    required this.fajrAfter,
  });

  PrayerTimesData copyWith({
    DateTime? date,
    Coordinates? coordinates,
    CalculationParameters? params,
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    DateTime? ishaBefore,
    DateTime? fajrAfter,
  }) {
    return PrayerTimesData(
      date: date ?? this.date,
      coordinates: coordinates ?? this.coordinates,
      params: params ?? this.params,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      ishaBefore: ishaBefore ?? this.ishaBefore,
      fajrAfter: fajrAfter ?? this.fajrAfter,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PrayerTimesData &&
            date == other.date &&
            coordinates == other.coordinates &&
            params == other.params &&
            fajr == other.fajr &&
            sunrise == other.sunrise &&
            dhuhr == other.dhuhr &&
            asr == other.asr &&
            maghrib == other.maghrib &&
            isha == other.isha &&
            ishaBefore == other.ishaBefore &&
            fajrAfter == other.fajrAfter;
  }

  @override
  int get hashCode => Object.hash(
        date,
        coordinates,
        params,
        fajr,
        sunrise,
        dhuhr,
        asr,
        maghrib,
        isha,
        ishaBefore,
        fajrAfter,
      );

  @override
  String toString() =>
      'PrayerTimesData(date: $date, fajr: $fajr, sunrise: $sunrise, dhuhr: $dhuhr, asr: $asr, maghrib: $maghrib, isha: $isha)';
}
