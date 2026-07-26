/// DateTime utilities for enhanced prayer time calculations and developer experience
library;

import 'package:adhan_dart/adhan_dart.dart';

/// Information about the next prayer
class NextPrayerInfo {
  /// The next prayer to be performed
  final Prayer prayer;

  /// The time when the prayer should be performed
  final DateTime time;

  const NextPrayerInfo(this.prayer, this.time);

  @override
  String toString() => '${prayer.name} at ${time.toString()}';
}

/// Extension on PrayerTimes for additional utilities
extension PrayerTimesUtilities on PrayerTimes {
  /// Gets all prayer times as a Map for easy iteration
  ///
  /// Example:
  /// ```dart
  /// for (final entry in prayerTimes.allPrayerTimes.entries) {
  ///   print('${entry.key.name}: ${entry.value}');
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
    final nextDayPrayerTimes = PrayerTimes(
      date: nextDay,
      coordinates: coordinates,
      calculationMethod: calculationMethod,
    );
    return nextDayPrayerTimes.fajr.difference(maghrib);
  }

  /// Gets only the obligatory prayer times
  ///
  /// Example:
  /// ```dart
  /// for (final entry in prayerTimes.obligatoryPrayerTimes.entries) {
  ///   print('${entry.key.name}: ${entry.value}');
  /// }
  /// ```
  Map<Prayer, DateTime> get obligatoryPrayerTimes => {
    Prayer.fajr: fajr,
    Prayer.dhuhr: dhuhr,
    Prayer.asr: asr,
    Prayer.maghrib: maghrib,
    Prayer.isha: isha,
  };

  /// Formats prayer times for display.
  ///
  /// All [PrayerTimes] values are UTC instants (same contract as adhan-js).
  /// By default this prints the UTC clock time with a `UTC` suffix. Pass
  /// [convert] to map each instant into a local (or other) zone before
  /// formatting, for example with the `timezone` package:
  ///
  /// ```dart
  /// final riyadh = tz.getLocation('Asia/Riyadh');
  /// print(prayerTimes.formatForDisplay(
  ///   convert: (utc) => tz.TZDateTime.from(utc, riyadh),
  /// ));
  /// ```
  String formatForDisplay({
    bool includeDate = true,
    bool include24Hour = true,
    DateTime Function(DateTime utc)? convert,
  }) {
    final buffer = StringBuffer();
    final utcLabel = convert == null ? ' UTC' : '';

    if (includeDate) {
      buffer.writeln('Prayer Times for ${date.toString().split(' ')[0]}:');
      if (convert == null) {
        buffer.writeln('(times shown in UTC)');
      }
    }

    for (final entry in allPrayerTimes.entries) {
      final displayTime = convert?.call(entry.value) ?? entry.value;
      final timeStr = include24Hour
          ? '${displayTime.hour.toString().padLeft(2, '0')}:${displayTime.minute.toString().padLeft(2, '0')}$utcLabel'
          : '${_to12HourFormat(displayTime)}$utcLabel';
      buffer.writeln('${entry.key.name}: $timeStr');
    }

    return buffer.toString().trim();
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
  /// Delegates to [PrayerTimes.currentPrayer], including sunrise in the
  /// day chain and [Prayer.ishaBefore] before Fajr.
  ///
  /// Example:
  /// ```dart
  /// final currentPrayer = DateTime.now().getCurrentPrayer(
  ///   coordinates: coords,
  ///   calculationMethod: method,
  /// );
  /// ```
  Prayer getCurrentPrayer({
    required Coordinates coordinates,
    required CalculationMethod calculationMethod,
  }) {
    return _prayerTimesFor(
      coordinates: coordinates,
      calculationMethod: calculationMethod,
    ).currentPrayer(time: this);
  }

  /// Gets the next prayer time after this DateTime
  ///
  /// Delegates to [PrayerTimes.nextPrayer] and [PrayerTimes.timeForPrayer],
  /// including sunrise in the chain and [Prayer.fajrAfter] after Isha.
  ///
  /// Example:
  /// ```dart
  /// final nextPrayer = DateTime.now().getNextPrayer(
  ///   coordinates: coords,
  ///   calculationMethod: method,
  /// );
  /// print('Next prayer: ${nextPrayer.prayer.name} at ${nextPrayer.time}');
  /// ```
  NextPrayerInfo getNextPrayer({
    required Coordinates coordinates,
    required CalculationMethod calculationMethod,
  }) {
    final prayerTimes = _prayerTimesFor(
      coordinates: coordinates,
      calculationMethod: calculationMethod,
    );
    final next = prayerTimes.nextPrayer(time: this);
    return NextPrayerInfo(next, prayerTimes.timeForPrayer(next));
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
  ///   calculationMethod: method,
  /// );
  /// ```
  bool isInPrayerWindow(
    Prayer prayer, {
    required Coordinates coordinates,
    required CalculationMethod calculationMethod,
  }) {
    if (!prayer.isObligatory) {
      throw ArgumentError('Can only check windows for obligatory prayers');
    }

    final prayerTimes = _prayerTimesFor(
      coordinates: coordinates,
      calculationMethod: calculationMethod,
    );

    final prayerTime = prayerTimes.timeForPrayer(prayer);
    final windowEnd = _obligatoryPrayerWindowEnd(prayerTimes, prayer);

    return !isBefore(prayerTime) && isBefore(windowEnd);
  }

  /// Gets time remaining until the next prayer
  ///
  /// Example:
  /// ```dart
  /// final timeLeft = DateTime.now().timeUntilNextPrayer(
  ///   coordinates: coords,
  ///   calculationMethod: method,
  /// );
  /// print('${timeLeft.inMinutes} minutes until next prayer');
  /// ```
  Duration timeUntilNextPrayer({
    required Coordinates coordinates,
    required CalculationMethod calculationMethod,
  }) {
    final nextPrayer = getNextPrayer(
      coordinates: coordinates,
      calculationMethod: calculationMethod,
    );
    return nextPrayer.time.difference(this);
  }

  PrayerTimes _prayerTimesFor({
    required Coordinates coordinates,
    required CalculationMethod calculationMethod,
  }) {
    return PrayerTimes(
      date: _calendarDate(this),
      coordinates: coordinates,
      calculationMethod: calculationMethod,
    );
  }
}

/// Normalizes a [DateTime] to UTC midnight of its calendar Y/M/D components.
DateTime _calendarDate(DateTime dateTime) {
  return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

DateTime _obligatoryPrayerWindowEnd(PrayerTimes prayerTimes, Prayer prayer) {
  switch (prayer) {
    case Prayer.fajr:
      return prayerTimes.sunrise;
    case Prayer.dhuhr:
      return prayerTimes.asr;
    case Prayer.asr:
      return prayerTimes.maghrib;
    case Prayer.maghrib:
      return prayerTimes.isha;
    case Prayer.isha:
      return prayerTimes.fajrAfter;
    default:
      throw ArgumentError('Invalid prayer for window calculation');
  }
}
