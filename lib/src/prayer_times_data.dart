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

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}

@immutable
class PrayerTimesData {
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

  /// Prayers whose times were produced using a safety fallback (e.g. high-latitude portion, fixed interval)
  /// instead of a direct astronomical angle solution.
  ///
  /// This allows client applications to surface transparency to users and optionally
  /// apply alternative UI/logic for estimated times.
  final Set<Prayer> estimatedPrayers;

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
    this.estimatedPrayers = const {},
  });

  // Convenience API parity with legacy PrayerTimes -----------------------
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
        // Sets are unordered; hash the combined content deterministically
        Object.hashAll(estimatedPrayers.toList()
          ..sort((a, b) => a.index.compareTo(b.index))),
      );

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
            fajrAfter == other.fajrAfter &&
            _setEquals(estimatedPrayers, other.estimatedPrayers);
  }

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
    Set<Prayer>? estimatedPrayers,
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
      estimatedPrayers: estimatedPrayers ?? this.estimatedPrayers,
    );
  }

  /// Returns the current prayer at [date]. Uses system time if [date] is omitted.
  /// Returns the active prayer, or the most recent prayer if between prayer times.
  Prayer currentPrayer({DateTime? date}) {
    final now = date ?? DateTime.now();
    if (now.isBefore(fajr)) return Prayer.ishaBefore;
    if (now.isBefore(sunrise)) return Prayer.fajr;
    if (now.isBefore(dhuhr)) return Prayer.sunrise;
    if (now.isBefore(asr)) return Prayer.dhuhr;
    if (now.isBefore(maghrib)) return Prayer.asr;
    if (now.isBefore(isha)) return Prayer.maghrib;
    return Prayer.fajrAfter;
  }

  /// Returns true if the given [prayer] time was computed using a fallback / safety estimation.
  bool isEstimated(Prayer prayer) => estimatedPrayers.contains(prayer);

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
  String toString() =>
      'PrayerTimesData(date: $date, fajr: $fajr, sunrise: $sunrise, dhuhr: $dhuhr, asr: $asr, maghrib: $maghrib, isha: $isha, estimated: $estimatedPrayers)';

  /// Validates prayer times for logical consistency and returns warnings.
  ///
  /// This is useful for debugging unusual calculation results.
  List<String> validate() {
    final warnings = <String>[];

    if (!fajr.isBefore(sunrise)) {
      warnings.add(
          'Fajr (${_formatTime(fajr)}) is not before sunrise (${_formatTime(sunrise)})');
    }

    if (!sunrise.isBefore(dhuhr)) {
      warnings.add(
          'Sunrise (${_formatTime(sunrise)}) is not before dhuhr (${_formatTime(dhuhr)})');
    }

    if (!dhuhr.isBefore(asr)) {
      warnings.add(
          'Dhuhr (${_formatTime(dhuhr)}) is not before asr (${_formatTime(asr)})');
    }

    if (!asr.isBefore(maghrib)) {
      warnings.add(
          'Asr (${_formatTime(asr)}) is not before maghrib (${_formatTime(maghrib)})');
    }

    if (!maghrib.isBefore(isha)) {
      warnings.add(
          'Maghrib (${_formatTime(maghrib)}) is not before isha (${_formatTime(isha)})');
    }

    if (estimatedPrayers.isNotEmpty) {
      final estimated = estimatedPrayers.map((p) => p.name).join(', ');
      warnings.add(
          'Using estimated times for: $estimated (high latitude or extreme conditions)');
    }

    // Check for unusually long twilight periods
    final fajrToSunrise = sunrise.difference(fajr).inMinutes;
    if (fajrToSunrise > 180) {
      // >3 hours
      warnings.add(
          'Unusually long Fajr period: ${fajrToSunrise}min (may indicate polar conditions)');
    }

    final maghribToIsha = isha.difference(maghrib).inMinutes;
    if (maghribToIsha > 180) {
      // >3 hours
      warnings.add(
          'Unusually long Isha period: ${maghribToIsha}min (may indicate polar conditions)');
    }

    return warnings;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Convenience factory method for calculating prayer times.
  /// This is the recommended way to create prayer times.
  ///
  /// Example:
  /// ```dart
  /// final times = PrayerTimesData.calculate(
  ///   date: DateTime.now(),
  ///   coordinates: Coordinates(40.7128, -74.0060), // NYC
  ///   calculationParameters: CalculationMethodParameters.northAmerica(),
  /// );
  ///
  /// print('Fajr: ${times.fajr}');
  /// print('Is Fajr estimated? ${times.isEstimated(Prayer.fajr)}');
  /// ```
  static PrayerTimesData calculate({
    required DateTime date,
    required Coordinates coordinates,
    required CalculationParameters calculationParameters,
    bool roundToMinutes = true,
  }) {
    return const PrayerTimesCalculator().calculate(
      date: date,
      coordinates: coordinates,
      params: calculationParameters,
      roundToMinutes: roundToMinutes,
    );
  }
}
