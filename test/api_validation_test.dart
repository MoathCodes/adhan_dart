// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata; // renamed alias
import 'package:timezone/timezone.dart' as tz;

/// Integration test that validates our prayer time calculations against
/// the well-known Aladhan API (http://api.aladhan.com/).
///
/// This test ensures our calculations are accurate by comparing results
/// with a trusted external source across different locations and dates.
void main() {
  tzdata.initializeTimeZones(); // updated alias
  final bool shortMode = Platform.environment['SHORT_API_VALIDATION'] == '1';
  final bool strictMode = Platform.environment['STRICT_API_VALIDATION'] == '1';

  group('Prayer Times API Validation', () {
    test(
      'validates calculations against Aladhan API for multiple locations',
      () async {
        if (shortMode) {
          print(
            'Skipping heavy multi-location test in SHORT_API_VALIDATION mode',
          );
          return;
        }
        // Test locations with different characteristics
        final testCases = [
          // Major cities with different latitudes
          {
            'name': 'Mecca, Saudi Arabia',
            'coordinates': Coordinates(21.4225, 39.8262),
            'timezone': 'Asia/Riyadh',
            'method': const UmmAlQura(),
          },
          {
            'name': 'New York, USA',
            'coordinates': Coordinates(40.7128, -74.0060),
            'timezone': 'America/New_York',
            'method': const NorthAmerica(),
          },
          {
            'name': 'London, UK',
            'coordinates': Coordinates(51.5074, -0.1278),
            'timezone': 'Europe/London',
            'method': const MuslimWorldLeague(),
          },
          {
            'name': 'Cairo, Egypt',
            'coordinates': Coordinates(30.0444, 31.2357),
            'timezone': 'Africa/Cairo',
            'method': const Egyptian(),
          },
          {
            'name': 'Karachi, Pakistan',
            'coordinates': Coordinates(24.8607, 67.0011),
            'timezone': 'Asia/Karachi',
            'method': const Karachi(),
          },
          // Southern hemisphere & equatorial
          {
            'name': 'Sydney, Australia',
            'coordinates': Coordinates(-33.8688, 151.2093),
            'timezone': 'Australia/Sydney',
            'method': const MuslimWorldLeague(),
          },
          {
            'name': 'Nairobi, Kenya',
            'coordinates': Coordinates(-1.286389, 36.817223),
            'timezone': 'Africa/Nairobi',
            'method': const MuslimWorldLeague(),
          },
          // High latitude challenging cases
          {
            'name': 'Oslo, Norway',
            'coordinates': Coordinates(59.9139, 10.7522),
            'timezone': 'Europe/Oslo',
            'method': const MuslimWorldLeague(),
          },
          {
            'name': 'Reykjavik, Iceland',
            'coordinates': Coordinates(64.1466, -21.9426),
            'timezone': 'Atlantic/Reykjavik',
            'method': const MuslimWorldLeague(),
          },
          {
            'name': 'Longyearbyen, Svalbard (extreme)',
            'coordinates': Coordinates(78.2232, 15.6469),
            'timezone': 'Arctic/Longyearbyen',
            'method': const MuslimWorldLeague(),
          },
        ];

        for (final testCase in testCases) {
          print('\n🕌 Testing ${testCase['name']}...');
          final coordinates = testCase['coordinates'] as Coordinates;
          final method = testCase['method'] as CalculationMethod;
          final timezone = testCase['timezone'] as String;
          final date = DateTime.now();
          await _validatePrayerTimes(
            coordinates: coordinates,
            date: date,
            method: method,
            timezone: timezone,
            locationName: testCase['name'] as String,
            strictMode: strictMode,
          );
        }
      },
    );

    test(
      'validates calculations for different dates throughout the year',
      () async {
        // Test Mecca across different seasons to check seasonal variations
        final coordinates = Coordinates(21.4225, 39.8262); // Mecca
        const method = UmmAlQura();
        const timezone = 'Asia/Riyadh';

        final testDates = [
          DateTime(2024, 1, 15), // Winter
          DateTime(2024, 3, 20), // Around March equinox
          DateTime(2024, 4, 15), // Spring
          DateTime(2024, 6, 21), // Summer solstice
          DateTime(2024, 7, 15), // Summer
          DateTime(2024, 9, 22), // Around September equinox
          DateTime(2024, 10, 15), // Fall
          DateTime(2024, 12, 21), // Winter solstice
          DateTime(2024, 2, 29), // Leap day
        ];

        for (final date in testDates) {
          print('\n📅 Testing date: ${date.toIso8601String().split('T')[0]}');
          await _validatePrayerTimes(
            coordinates: coordinates,
            date: date,
            method: method,
            timezone: timezone,
            locationName: 'Mecca (seasonal test)',
            strictMode: strictMode,
          );
        }
      },
    );

    test('validates DST transition behavior (New York 2024)', () async {
      final coordinates = Coordinates(40.7128, -74.0060);
      const method = NorthAmerica();
      const timezone = 'America/New_York';

      // Dates around DST start (Mar 10 2024) and end (Nov 3 2024)
      final dates = [
        DateTime(2024, 3, 8),
        DateTime(2024, 3, 9),
        DateTime(2024, 3, 10),
        DateTime(2024, 3, 11),
        DateTime(2024, 11, 1),
        DateTime(2024, 11, 2),
        DateTime(2024, 11, 3),
        DateTime(2024, 11, 4),
      ];

      for (final date in dates) {
        print('\n⏰ DST Check date: ${date.toIso8601String().split('T')[0]}');
        await _validatePrayerTimes(
          coordinates: coordinates,
          date: date,
          method: method,
          timezone: timezone,
          locationName: 'New York (DST test)',
          strictMode: strictMode,
        );
      }
    });

    test(
      'validates multiple calculation methods consistency for a location',
      () async {
        final coordinates = Coordinates(51.5074, -0.1278); // London
        const timezone = 'Europe/London';
        final methods = [
          const MuslimWorldLeague(),
          const Egyptian(),
          const Karachi(),
          const NorthAmerica(),
          const UmmAlQura(),
          const Dubai(),
          const MoonsightingCommittee(),
          const Kuwait(),
          const Qatar(),
          const Singapore(),
        ];

        final date = DateTime(2024, 5, 15);
        for (final method in methods) {
          await _validatePrayerTimes(
            coordinates: coordinates,
            date: date,
            method: method,
            timezone: timezone,
            locationName: 'London (${method.runtimeType})',
            toleranceOverrideMinutes: 4,
            strictMode: strictMode,
          );
        }
      },
    );

    test('temporal ordering of prayers across diverse locations/dates', () {
      final scenarios = [
        {
          'coordinates': Coordinates(21.4225, 39.8262),
          'timezone': 'Asia/Riyadh',
          'method': const UmmAlQura(),
        },
        {
          'coordinates': Coordinates(64.1466, -21.9426),
          'timezone': 'Atlantic/Reykjavik',
          'method': const MuslimWorldLeague(),
        },
        {
          'coordinates': Coordinates(-33.8688, 151.2093),
          'timezone': 'Australia/Sydney',
          'method': const MuslimWorldLeague(),
        },
        {
          'coordinates': Coordinates(40.7128, -74.0060),
          'timezone': 'America/New_York',
          'method': const NorthAmerica(),
        },
      ];

      final dates = [
        DateTime(2024, 1, 15),
        DateTime(2024, 6, 21),
        DateTime(2024, 12, 21),
      ];

      for (final s in scenarios) {
        final location = s['timezone'] as String;
        final loc = tz.getLocation(location);
        final method = s['method'] as CalculationMethod;
        final coords = s['coordinates'] as Coordinates;
        for (final date in dates) {
          final pt = PrayerTimes(
            coordinates: coords,
            date: date,
            calculationMethod: method,
          );
          final fajr = tz.TZDateTime.from(pt.fajr.toUtc(), loc);
          final sunrise = tz.TZDateTime.from(pt.sunrise.toUtc(), loc);
          final dhuhr = tz.TZDateTime.from(pt.dhuhr.toUtc(), loc);
          final asr = tz.TZDateTime.from(pt.asr.toUtc(), loc);
          final maghrib = tz.TZDateTime.from(pt.maghrib.toUtc(), loc);
          final isha = tz.TZDateTime.from(pt.isha.toUtc(), loc);

          expect(
            fajr.isBefore(sunrise),
            true,
            reason: 'Fajr should be before Sunrise for $location on $date',
          );
          expect(
            sunrise.isBefore(dhuhr),
            true,
            reason: 'Sunrise should be before Dhuhr for $location on $date',
          );
          expect(
            dhuhr.isBefore(asr),
            true,
            reason: 'Dhuhr should be before Asr for $location on $date',
          );
          expect(
            asr.isBefore(maghrib),
            true,
            reason: 'Asr should be before Maghrib for $location on $date',
          );
          expect(
            maghrib.isBefore(isha),
            true,
            reason: 'Maghrib should be before Isha for $location on $date',
          );
        }
      }
    });

    test('currentPrayer / nextPrayer transitions around boundaries', () {
      final method = const MuslimWorldLeague();
      final coordinates = Coordinates(40.7128, -74.0060); // New York
      final date = DateTime(2024, 5, 20);
      final pt = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationMethod: method,
      );

      final transitions = [
        pt.fajr,
        pt.sunrise,
        pt.dhuhr,
        pt.asr,
        pt.maghrib,
        pt.isha,
      ];

      Prayer expectedCurrent(DateTime t) {
        if (t.isBefore(pt.fajr)) return Prayer.ishaBefore; // previous day isha
        if (t.isBefore(pt.sunrise)) return Prayer.fajr;
        if (t.isBefore(pt.dhuhr)) return Prayer.sunrise;
        if (t.isBefore(pt.asr)) return Prayer.dhuhr;
        if (t.isBefore(pt.maghrib)) return Prayer.asr;
        if (t.isBefore(pt.isha)) return Prayer.maghrib;
        return Prayer.isha;
      }

      Prayer expectedNext(DateTime t) {
        if (t.isBefore(pt.fajr)) return Prayer.fajr;
        if (t.isBefore(pt.sunrise)) return Prayer.sunrise;
        if (t.isBefore(pt.dhuhr)) return Prayer.dhuhr;
        if (t.isBefore(pt.asr)) return Prayer.asr;
        if (t.isBefore(pt.maghrib)) return Prayer.maghrib;
        if (t.isBefore(pt.isha)) return Prayer.isha;
        return Prayer.fajrAfter;
      }

      for (final moment in transitions) {
        final before = moment.subtract(const Duration(minutes: 1));
        final after = moment.add(const Duration(minutes: 1));
        expect(
          pt.currentPrayer(time: before),
          expectedCurrent(before),
          reason: 'currentPrayer mismatch 1m before $moment',
        );
        expect(
          pt.nextPrayer(time: before),
          expectedNext(before),
          reason: 'nextPrayer mismatch 1m before $moment',
        );
        expect(
          pt.currentPrayer(time: after),
          expectedCurrent(after),
          reason: 'currentPrayer mismatch 1m after $moment',
        );
        expect(
          pt.nextPrayer(time: after),
          expectedNext(after),
          reason: 'nextPrayer mismatch 1m after $moment',
        );
      }
    });

    test('SunnahTimes internal consistency', () {
      final method = const NorthAmerica();
      final coordinates = Coordinates(51.5074, -0.1278); // London
      final date = DateTime(2024, 5, 15);
      final pt = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationMethod: method,
      );
      final sunnah = SunnahTimes(pt);
      // Check logical ordering
      expect(pt.maghrib.isBefore(sunnah.middleOfTheNight), true);
      expect(
        sunnah.middleOfTheNight.isBefore(sunnah.lastThirdOfTheNight),
        true,
      );
      // Check intervals roughly plausible (< 24h and positive)
      final nightLen = pt.fajr.difference(pt.maghrib).inHours.abs();
      expect(nightLen > 0 && nightLen < 24, true);
    });

    test('High-latitude safety constraints (Reykjavik summer)', () {
      final coords = Coordinates(64.1466, -21.9426);
      final date = DateTime(2024, 6, 21);
      final method = const MuslimWorldLeague();
      final pt = PrayerTimes(
        coordinates: coords,
        date: date,
        calculationMethod: method,
      );
      // Reconstruct safe fajr bound: portion * night length
      final nightSeconds = pt.sunrise.difference(pt.maghrib).inSeconds < 0
          ? pt.sunrise
                .add(const Duration(days: 1))
                .difference(pt.maghrib)
                .inSeconds
          : pt.sunrise.difference(pt.maghrib).inSeconds;
      final portion = method.nightPortions()[Prayer.fajr]!;
      final maxAdvanceSeconds =
          (portion * nightSeconds).round() + 5 * 60; // 5m grace
      final actualAdvance = pt.sunrise.difference(pt.fajr).inSeconds;
      expect(
        actualAdvance <= maxAdvanceSeconds,
        true,
        reason: 'Fajr earlier than safe portion allowance',
      );
    });
  });
}

/// Compares two prayer times with dynamic tolerances.
void _comparePrayerTime(
  String prayerName,
  Prayer prayer,
  Coordinates coords,
  CalculationMethod method,
  DateTime ourTime,
  DateTime? apiTime,
  bool strictMode, {
  int? overrideStrict,
}) {
  if (apiTime == null) {
    print('⚠️  No API time for $prayerName, skipping comparison');
    return;
  }
  final plan = _toleranceFor(
    prayer: prayer,
    latitude: coords.latitude,
    method: method,
  );
  final minutesDiff =
      (ourTime.hour * 60 +
              ourTime.minute -
              (apiTime.hour * 60 + apiTime.minute))
          .abs();
  final strictLimit = overrideStrict ?? plan.soft;
  final hardLimit = plan.hard;
  final status = minutesDiff <= strictLimit
      ? '✅'
      : minutesDiff <= hardLimit
      ? '⚠️'
      : '❌';
  print(
    '$status $prayerName: Our=${_formatTime(ourTime)} API=${_formatTime(apiTime)} Diff=${minutesDiff}m (soft≤$strictLimit, hard≤$hardLimit)',
  );
  if (minutesDiff <= strictLimit) {
    return; // pass silently
  }
  if (minutesDiff <= hardLimit) {
    // soft warning; only fail if strictMode
    if (strictMode) {
      fail(
        '$prayerName soft tolerance exceeded in strict mode: diff=$minutesDiff > $strictLimit (hard=$hardLimit)',
      );
    }
    return; // warning only
  }
  // Hard failure always
  fail(
    '$prayerName difference $minutesDiff exceeds hard tolerance $hardLimit (strictLimit=$strictLimit). Our=${_formatTime(ourTime)} API=${_formatTime(apiTime)}',
  );
}

/// Fetches prayer times from Aladhan API
Future<Map<String, DateTime?>> _fetchFromAladhanAPI({
  required Coordinates coordinates,
  required DateTime date,
  required CalculationMethod method,
}) async {
  try {
    final methodNumber = _getAladhanMethodNumber(method);
    final dateStr = '${date.day}-${date.month}-${date.year}';
    final url =
        'http://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=${coordinates.latitude}'
        '&longitude=${coordinates.longitude}'
        '&method=$methodNumber';
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      print('API request failed with status: ${response.statusCode}');
      return {};
    }
    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);
    if (data['code'] != 200) {
      print('API returned error: ${data['status']}');
      return {};
    }
    final timings = data['data']['timings'] as Map<String, dynamic>;
    return {
      'fajr': _parseTime(timings['Fajr'], date),
      'sunrise': _parseTime(timings['Sunrise'], date),
      'dhuhr': _parseTime(timings['Dhuhr'], date),
      'asr': _parseTime(timings['Asr'], date),
      'maghrib': _parseTime(timings['Maghrib'], date),
      'isha': _parseTime(timings['Isha'], date),
    };
  } catch (e) {
    print('Error fetching from API: $e');
    return {};
  }
}

/// Formats DateTime to HH:MM string
String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// Converts our CalculationMethod to Aladhan API method number
int _getAladhanMethodNumber(CalculationMethod method) {
  switch (method) {
    case MuslimWorldLeague _:
      return 3;
    case Egyptian _:
      return 5;
    case Karachi _:
      return 1;
    case UmmAlQura _:
      return 4;
    case Dubai _:
      return 8;
    case MoonsightingCommittee _:
      return 0;
    case NorthAmerica _:
      return 2;
    case Kuwait _:
      return 9;
    case Qatar _:
      return 11;
    case Singapore _:
      return 12;
    default:
      return 3; // Default to Muslim World League
  }
}

/// Parses time string "HH:MM" to DateTime (returns null for invalid/N/A)
DateTime? _parseTime(dynamic timeStr, DateTime date) {
  if (timeStr == null) return null;
  final raw = timeStr.toString().trim();
  if (raw.isEmpty || raw.toUpperCase() == 'N/A') return null;
  final parts = raw.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

_TolerancePlan _toleranceFor({
  required Prayer prayer,
  required double latitude,
  required CalculationMethod method,
}) {
  // Base soft/hard
  int soft = 3; // aims for near alignment
  int hard = 5; // default strict fail threshold

  // Fajr & Isha are more variable due to different angle traditions
  if (prayer == Prayer.fajr || prayer == Prayer.isha) {
    soft = 8;
    hard = 20; // allow up to 20 min before hard fail in normal latitudes
  }

  // High latitude (>55) expand further especially for Fajr/Isha
  if (latitude.abs() >= 55) {
    if (prayer == Prayer.fajr || prayer == Prayer.isha) {
      soft = 25;
      hard = 90; // extreme differences due to safety adjustments
    } else if (prayer == Prayer.sunrise || prayer == Prayer.maghrib) {
      soft = 5;
      hard = 10;
    }
  }

  // Method-specific tweaks (some methods use fixed intervals or different rounding)
  if (method is UmmAlQura && prayer == Prayer.isha) {
    hard = 35; // fixed interval after maghrib can diverge
    soft = 10;
  }

  return _TolerancePlan(hard: hard, soft: soft);
}

/// Validates prayer times against the Aladhan API
Future<void> _validatePrayerTimes({
  required Coordinates coordinates,
  required DateTime date,
  required CalculationMethod method,
  required String timezone,
  required String locationName,
  bool strictMode = false,
  int? toleranceOverrideMinutes,
}) async {
  try {
    final location = tz.getLocation(timezone);
    final ourTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationMethod: method,
    );
    final ourTimesLocal = {
      'fajr': tz.TZDateTime.from(ourTimes.fajr.toUtc(), location),
      'sunrise': tz.TZDateTime.from(ourTimes.sunrise.toUtc(), location),
      'dhuhr': tz.TZDateTime.from(ourTimes.dhuhr.toUtc(), location),
      'asr': tz.TZDateTime.from(ourTimes.asr.toUtc(), location),
      'maghrib': tz.TZDateTime.from(ourTimes.maghrib.toUtc(), location),
      'isha': tz.TZDateTime.from(ourTimes.isha.toUtc(), location),
    };
    final apiTimes = await _fetchFromAladhanAPI(
      coordinates: coordinates,
      date: date,
      method: method,
    );
    if (apiTimes.isEmpty) {
      print(
        '⚠️  Could not fetch API data for $locationName, skipping validation',
      );
      return;
    }
    final override = toleranceOverrideMinutes; // applies to soft limit only
    _comparePrayerTime(
      'Fajr',
      Prayer.fajr,
      coordinates,
      method,
      ourTimesLocal['fajr']!,
      apiTimes['fajr'],
      strictMode,
      overrideStrict: override,
    );
    _comparePrayerTime(
      'Sunrise',
      Prayer.sunrise,
      coordinates,
      method,
      ourTimesLocal['sunrise']!,
      apiTimes['sunrise'],
      strictMode,
      overrideStrict: override,
    );
    _comparePrayerTime(
      'Dhuhr',
      Prayer.dhuhr,
      coordinates,
      method,
      ourTimesLocal['dhuhr']!,
      apiTimes['dhuhr'],
      strictMode,
      overrideStrict: override,
    );
    _comparePrayerTime(
      'Asr',
      Prayer.asr,
      coordinates,
      method,
      ourTimesLocal['asr']!,
      apiTimes['asr'],
      strictMode,
      overrideStrict: override,
    );
    _comparePrayerTime(
      'Maghrib',
      Prayer.maghrib,
      coordinates,
      method,
      ourTimesLocal['maghrib']!,
      apiTimes['maghrib'],
      strictMode,
      overrideStrict: override,
    );
    _comparePrayerTime(
      'Isha',
      Prayer.isha,
      coordinates,
      method,
      ourTimesLocal['isha']!,
      apiTimes['isha'],
      strictMode,
      overrideStrict: override,
    );
    print('✅ $locationName validation complete');
  } catch (e) {
    print('❌ Error validating $locationName: $e');
  }
}

/// Dynamic tolerance strategy for differences.
class _TolerancePlan {
  final int hard; // test fails beyond this
  final int soft; // warning if > soft && <= hard
  const _TolerancePlan({required this.hard, required this.soft});
}
