/// Immutable value object holding the six obligatory prayers
/// and related helper instants for a given date/location.
///
/// This separates **data** from **calculation logic** so that
/// different algorithms can populate the object while consumer
/// code depends only on a stable, immutable API.
///
/// Instances are created by [PrayerTimesCalculator].
///
/// Note: This file is new and does NOT break the old `PrayerTimes`
/// class.  Once the migration finishes we can rename this back to
/// `PrayerTimes` and delete the mutable original.
import 'package:meta/meta.dart';

import 'Coordinates.dart';
import 'CalculationParameters.dart';

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
