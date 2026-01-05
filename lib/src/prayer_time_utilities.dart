/// DateTime utilities for enhanced prayer time calculations and developer experience
library prayer_time_utilities;

import 'package:adhan_dart/adhan_dart.dart';

/// Information about the next prayer
class NextPrayerInfo {
  /// The next prayer to be performed
  final Prayer prayer;

  /// The time when the prayer should be performed
  final DateTime time;

  const NextPrayerInfo(this.prayer, this.time);

  @override
  String toString() => '${prayer.displayName} at ${time.toString()}';
}

/// Extension on PrayerTimesData for additional utilities
extension PrayerTimesDataUtilities on PrayerTimesData {
  /// Gets all prayer times as a Map for easy iteration
  ///
  /// Example:
  /// ```dart
  /// for (final entry in prayerTimes.allPrayerTimes.entries) {
  ///   print('${entry.key.displayName}: ${entry.value}');
  /// }
  /// ```
  Map<Prayer, DateTime> get allPrayerTimes => {
        Prayer.fajr: fajr,
        Prayer.sunrise: sunrise,
        Prayer.dhuhr: dhuhr,
        Prayer.asr: asr,
        Prayer.maghrib: maghrib,
        Prayer.isha: isha,
      };

  /// Gets the duration of the day (from Fajr to Maghrib)
  Duration get dayDuration {
    return maghrib.difference(fajr);
  }

  /// Gets the duration of the night (from Maghrib to Fajr next day)
  ///
  /// Useful for calculating Qiyam times or high-latitude rules.
  Duration get nightDuration {
    final nextDay = date.add(const Duration(days: 1));
    final nextDayPrayerTimes = PrayerTimesData.calculate(
      date: nextDay,
      coordinates: coordinates,
      calculationParameters: params,
    );
    return nextDayPrayerTimes.fajr.difference(maghrib);
  }

  /// Gets only the obligatory prayer times
  ///
  /// Example:
  /// ```dart
  /// for (final entry in prayerTimes.obligatoryPrayerTimes.entries) {
  ///   print('${entry.key.displayName}: ${entry.value}');
  /// }
  /// ```
  Map<Prayer, DateTime> get obligatoryPrayerTimes => {
        Prayer.fajr: fajr,
        Prayer.dhuhr: dhuhr,
        Prayer.asr: asr,
        Prayer.maghrib: maghrib,
        Prayer.isha: isha,
      };

  /// Formats prayer times for display
  ///
  /// Example:
  /// ```dart
  /// print(prayerTimes.formatForDisplay());
  /// // Output:
  /// // Prayer Times for 2024-01-15:
  /// // Fajr: 05:30
  /// // Sunrise: 07:15
  /// // Dhuhr: 12:30
  /// // ...
  /// ```
  String formatForDisplay(
      {bool includeDate = true, bool include24Hour = true}) {
    final buffer = StringBuffer();

    if (includeDate) {
      buffer.writeln('Prayer Times for ${date.toString().split(' ')[0]}:');
    }

    for (final entry in allPrayerTimes.entries) {
      final timeStr = include24Hour
          ? '${entry.value.hour.toString().padLeft(2, '0')}:${entry.value.minute.toString().padLeft(2, '0')}'
          : _to12HourFormat(entry.value);
      buffer.writeln('${entry.key.displayName}: $timeStr');
    }

    return buffer.toString().trim();
  }

  /// Gets the time for a specific prayer
  ///
  /// Returns null if the prayer is not available (e.g., ishaBefore, fajrAfter)
  ///
  /// Example:
  /// ```dart
  /// final fajrTime = prayerTimes.timeForPrayer(Prayer.fajr);
  /// ```
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
      case Prayer.ishaBefore:
        return null; // Not available in PrayerTimesData
      case Prayer.fajrAfter:
        return null; // Not available in PrayerTimesData
    }
  }

  String _to12HourFormat(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    if (hour == 0) {
      return '12:$minute AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }
}

/// Extension on DateTime for prayer time related utilities
extension PrayerTimeUtilities on DateTime {
  /// Gets the current prayer time for this DateTime
  ///
  /// Returns the prayer that should be performed at this time,
  /// or null if it's between Isha and Fajr (night time).
  ///
  /// Example:
  /// ```dart
  /// final currentPrayer = DateTime.now().getCurrentPrayer(
  ///   coordinates: coords,
  ///   calculationParameters: params,
  /// );
  /// ```
  Prayer? getCurrentPrayer({
    required Coordinates coordinates,
    required CalculationParameters calculationParameters,
  }) {
    final prayerTimes = PrayerTimesData.calculate(
      date: this,
      coordinates: coordinates,
      calculationParameters: calculationParameters,
    );

    // Check each prayer time in order
    if (isBefore(prayerTimes.fajr)) {
      return null; // Night time (before Fajr)
    } else if (isBefore(prayerTimes.sunrise)) {
      return Prayer.fajr;
    } else if (isBefore(prayerTimes.dhuhr)) {
      return null; // Between sunrise and Dhuhr (no prayer)
    } else if (isBefore(prayerTimes.asr)) {
      return Prayer.dhuhr;
    } else if (isBefore(prayerTimes.maghrib)) {
      return Prayer.asr;
    } else if (isBefore(prayerTimes.isha)) {
      return Prayer.maghrib;
    } else {
      return Prayer.isha;
    }
  }

  /// Gets the next prayer time after this DateTime
  ///
  /// Example:
  /// ```dart
  /// final nextPrayer = DateTime.now().getNextPrayer(
  ///   coordinates: coords,
  ///   calculationParameters: params,
  /// );
  /// print('Next prayer: ${nextPrayer.prayer.displayName} at ${nextPrayer.time}');
  /// ```
  NextPrayerInfo getNextPrayer({
    required Coordinates coordinates,
    required CalculationParameters calculationParameters,
  }) {
    final prayerTimes = PrayerTimesData.calculate(
      date: this,
      coordinates: coordinates,
      calculationParameters: calculationParameters,
    );

    // Check which prayer comes next
    if (isBefore(prayerTimes.fajr)) {
      return NextPrayerInfo(Prayer.fajr, prayerTimes.fajr);
    } else if (isBefore(prayerTimes.dhuhr)) {
      return NextPrayerInfo(Prayer.dhuhr, prayerTimes.dhuhr);
    } else if (isBefore(prayerTimes.asr)) {
      return NextPrayerInfo(Prayer.asr, prayerTimes.asr);
    } else if (isBefore(prayerTimes.maghrib)) {
      return NextPrayerInfo(Prayer.maghrib, prayerTimes.maghrib);
    } else if (isBefore(prayerTimes.isha)) {
      return NextPrayerInfo(Prayer.isha, prayerTimes.isha);
    } else {
      // After Isha, next prayer is tomorrow's Fajr
      final tomorrowPrayerTimes = PrayerTimesData.calculate(
        date: add(const Duration(days: 1)),
        coordinates: coordinates,
        calculationParameters: calculationParameters,
      );
      return NextPrayerInfo(Prayer.fajr, tomorrowPrayerTimes.fajr);
    }
  }

  /// Checks if this time is within a prayer window
  ///
  /// A prayer window is from the prayer time until the next prayer time.
  ///
  /// Example:
  /// ```dart
  /// final isDhuhrTime = DateTime.now().isInPrayerWindow(
  ///   Prayer.dhuhr,
  ///   coordinates: coords,
  ///   calculationParameters: params,
  /// );
  /// ```
  bool isInPrayerWindow(
    Prayer prayer, {
    required Coordinates coordinates,
    required CalculationParameters calculationParameters,
  }) {
    if (!prayer.isObligatory) {
      throw ArgumentError('Can only check windows for obligatory prayers');
    }

    final prayerTimes = PrayerTimesData.calculate(
      date: this,
      coordinates: coordinates,
      calculationParameters: calculationParameters,
    );

    final prayerTime = prayerTimes.timeForPrayer(prayer);
    final nextPrayerTime = _getNextPrayerTime(
        prayer, prayerTimes, coordinates, calculationParameters);

    return isAfter(prayerTime) && isBefore(nextPrayerTime);
  }

  /// Gets time remaining until the next prayer
  ///
  /// Example:
  /// ```dart
  /// final timeLeft = DateTime.now().timeUntilNextPrayer(
  ///   coordinates: coords,
  ///   calculationParameters: params,
  /// );
  /// print('${timeLeft.inMinutes} minutes until next prayer');
  /// ```
  Duration timeUntilNextPrayer({
    required Coordinates coordinates,
    required CalculationParameters calculationParameters,
  }) {
    final nextPrayer = getNextPrayer(
      coordinates: coordinates,
      calculationParameters: calculationParameters,
    );
    return nextPrayer.time.difference(this);
  }

  DateTime _getNextPrayerTime(Prayer prayer, PrayerTimesData prayerTimes,
      Coordinates coordinates, CalculationParameters calculationParameters) {
    switch (prayer) {
      case Prayer.fajr:
        return prayerTimes.dhuhr;
      case Prayer.dhuhr:
        return prayerTimes.asr;
      case Prayer.asr:
        return prayerTimes.maghrib;
      case Prayer.maghrib:
        return prayerTimes.isha;
      case Prayer.isha:
        // Next prayer is tomorrow's Fajr
        final tomorrow = add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimesData.calculate(
          date: tomorrow,
          coordinates: coordinates,
          calculationParameters: calculationParameters,
        );
        return tomorrowPrayerTimes.fajr;
      default:
        throw ArgumentError('Invalid prayer for window calculation');
    }
  }
}
