import 'package:adhan_dart/adhan_dart.dart';
import 'package:meta/meta.dart';

import 'PrayerTimes.dart' as legacy;
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
    final legacyTimes = legacy.PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
      precision: precision,
    );

    return PrayerTimesData(
      date: date,
      coordinates: coordinates,
      params: params,
      fajr: legacyTimes.fajr,
      sunrise: legacyTimes.sunrise,
      dhuhr: legacyTimes.dhuhr,
      asr: legacyTimes.asr,
      maghrib: legacyTimes.maghrib,
      isha: legacyTimes.isha,
      ishaBefore: legacyTimes.ishaBefore,
      fajrAfter: legacyTimes.fajrAfter,
    );
  }
}
