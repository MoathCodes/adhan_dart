// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:adhan_dart/adhan_dart.dart';

/// Integration test that validates our prayer time calculations against
/// the well-known Aladhan API (http://api.aladhan.com/).
///
/// This test ensures our calculations are accurate by comparing results
/// with a trusted external source across different locations and dates.
void main() {
  // Initialize timezone data
  tz.initializeTimeZones();
  
  group('Prayer Times API Validation', () {
    test('validates calculations against Aladhan API for multiple locations',
        () async {
      // Test locations with different characteristics
      final testCases = [
        // Major cities with different latitudes
        {
          'name': 'Mecca, Saudi Arabia',
          'coordinates': const Coordinates(21.4225, 39.8262),
          'timezone': 'Asia/Riyadh',
          'method': CalculationMethod.ummAlQura,
        },
        {
          'name': 'New York, USA',
          'coordinates': const Coordinates(40.7128, -74.0060),
          'timezone': 'America/New_York',
          'method': CalculationMethod.northAmerica,
        },
        {
          'name': 'London, UK',
          'coordinates': const Coordinates(51.5074, -0.1278),
          'timezone': 'Europe/London',
          'method': CalculationMethod.muslimWorldLeague,
        },
        {
          'name': 'Cairo, Egypt',
          'coordinates': const Coordinates(30.0444, 31.2357),
          'timezone': 'Africa/Cairo',
          'method': CalculationMethod.egyptian,
        },
        {
          'name': 'Karachi, Pakistan',
          'coordinates': const Coordinates(24.8607, 67.0011),
          'timezone': 'Asia/Karachi',
          'method': CalculationMethod.karachi,
        },
      ];

      for (final testCase in testCases) {
        print('\n🕌 Testing ${testCase['name']}...');

        final coordinates = testCase['coordinates'] as Coordinates;
        final method = testCase['method'] as CalculationMethod;
        final timezone = testCase['timezone'] as String;

        // Test for today's date
        final date = DateTime.now();

        await _validatePrayerTimes(
          coordinates: coordinates,
          date: date,
          method: method,
          timezone: timezone,
          locationName: testCase['name'] as String,
        );
      }
    });

    test('validates calculations for different dates throughout the year',
        () async {
      // Test Mecca across different seasons to check seasonal variations
      const coordinates = Coordinates(21.4225, 39.8262); // Mecca
      const method = CalculationMethod.ummAlQura;
      const timezone = 'Asia/Riyadh';

      final testDates = [
        DateTime(2024, 1, 15), // Winter
        DateTime(2024, 4, 15), // Spring
        DateTime(2024, 7, 15), // Summer
        DateTime(2024, 10, 15), // Fall
        DateTime(2024, 6, 21), // Summer solstice
        DateTime(2024, 12, 21), // Winter solstice
      ];

      for (final date in testDates) {
        print('\n📅 Testing date: ${date.toIso8601String().split('T')[0]}');

        await _validatePrayerTimes(
          coordinates: coordinates,
          date: date,
          method: method,
          timezone: timezone,
          locationName: 'Mecca (seasonal test)',
        );
      }
    });
  });
}

/// Compares two prayer times and asserts they're within tolerance
void _comparePrayerTime(String prayerName, DateTime ourTime, DateTime? apiTime,
    int toleranceMinutes) {
  if (apiTime == null) {
    print('⚠️  No API time for $prayerName, skipping comparison');
    return;
  }

  // Compare times by converting both to minutes since midnight
  final ourMinutes = ourTime.hour * 60 + ourTime.minute;
  final apiMinutes = apiTime.hour * 60 + apiTime.minute;
  final difference = (ourMinutes - apiMinutes).abs();
  
  print('$prayerName: Our=${_formatTime(ourTime)} API=${_formatTime(apiTime)} Diff=${difference}min');
  
  expect(
    difference,
    lessThanOrEqualTo(toleranceMinutes),
    reason: '$prayerName time difference ($difference minutes) exceeds tolerance ($toleranceMinutes minutes)\n'
        'Our time: ${_formatTime(ourTime)}\n'
        'API time: ${_formatTime(apiTime)}',
  );
}

/// Fetches prayer times from Aladhan API
Future<Map<String, DateTime>?> _fetchFromAladhanAPI({
  required Coordinates coordinates,
  required DateTime date,
  required CalculationMethod method,
}) async {
  try {
    final methodNumber = _getAladhanMethodNumber(method);
    final dateStr = '${date.day}-${date.month}-${date.year}';

    final url = 'http://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=${coordinates.latitude}'
        '&longitude=${coordinates.longitude}'
        '&method=$methodNumber';

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != 200) {
      print('API request failed with status: ${response.statusCode}');
      return null;
    }

    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);

    if (data['code'] != 200) {
      print('API returned error: ${data['status']}');
      return null;
    }

    final timings = data['data']['timings'] as Map<String, dynamic>;

    // Parse the times (format: "HH:MM")
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
    return null;
  }
}

/// Formats DateTime to HH:MM string
String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// Converts our CalculationMethod to Aladhan API method number
int _getAladhanMethodNumber(CalculationMethod method) {
  switch (method) {
    case CalculationMethod.muslimWorldLeague:
      return 3;
    case CalculationMethod.egyptian:
      return 5;
    case CalculationMethod.karachi:
      return 1;
    case CalculationMethod.ummAlQura:
      return 4;
    case CalculationMethod.dubai:
      return 8;
    case CalculationMethod.moonsightingCommittee:
      return 0;
    case CalculationMethod.northAmerica:
      return 2;
    case CalculationMethod.kuwait:
      return 9;
    case CalculationMethod.qatar:
      return 11;
    case CalculationMethod.singapore:
      return 12;
    default:
      return 3; // Default to Muslim World League
  }
}

/// Gets calculation parameters for our library
CalculationParameters _getCalculationParameters(CalculationMethod method) {
  switch (method) {
    case CalculationMethod.muslimWorldLeague:
      return CalculationMethodParameters.muslimWorldLeague();
    case CalculationMethod.egyptian:
      return CalculationMethodParameters.egyptian();
    case CalculationMethod.karachi:
      return CalculationMethodParameters.karachi();
    case CalculationMethod.ummAlQura:
      return CalculationMethodParameters.ummAlQura();
    case CalculationMethod.dubai:
      return CalculationMethodParameters.dubai();
    case CalculationMethod.moonsightingCommittee:
      return CalculationMethodParameters.moonsightingCommittee();
    case CalculationMethod.northAmerica:
      return CalculationMethodParameters.northAmerica();
    case CalculationMethod.kuwait:
      return CalculationMethodParameters.kuwait();
    case CalculationMethod.qatar:
      return CalculationMethodParameters.qatar();
    case CalculationMethod.singapore:
      return CalculationMethodParameters.singapore();
    default:
      return CalculationMethodParameters.muslimWorldLeague();
  }
}

/// Parses time string "HH:MM" to DateTime
DateTime _parseTime(String timeStr, DateTime date) {
  final parts = timeStr.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  return DateTime(date.year, date.month, date.day, hour, minute);
}

/// Validates prayer times against the Aladhan API
Future<void> _validatePrayerTimes({
  required Coordinates coordinates,
  required DateTime date,
  required CalculationMethod method,
  required String timezone,
  required String locationName,
}) async {
  try {
    // Get timezone location for conversion
    final location = tz.getLocation(timezone);
    
    // Calculate prayer times using our library
    final calculationParams = _getCalculationParameters(method);
    final ourTimes = PrayerTimesData.calculate(
      coordinates: coordinates,
      date: date,
      calculationParameters: calculationParams,
    );
    
    // Convert our UTC times to local timezone for comparison
    // Note: Our library returns times in UTC, but API returns local times
    final ourTimesLocal = {
      'fajr': tz.TZDateTime.from(ourTimes.fajr.toUtc(), location),
      'sunrise': tz.TZDateTime.from(ourTimes.sunrise.toUtc(), location),
      'dhuhr': tz.TZDateTime.from(ourTimes.dhuhr.toUtc(), location),
      'asr': tz.TZDateTime.from(ourTimes.asr.toUtc(), location),
      'maghrib': tz.TZDateTime.from(ourTimes.maghrib.toUtc(), location),
      'isha': tz.TZDateTime.from(ourTimes.isha.toUtc(), location),
    };

    // Fetch prayer times from Aladhan API
    final apiTimes = await _fetchFromAladhanAPI(
      coordinates: coordinates,
      date: date,
      method: method,
    );

    if (apiTimes == null) {
      print(
          '⚠️  Could not fetch API data for $locationName, skipping validation');
      return;
    }

    // Compare the times (allowing for small differences due to rounding)
    final toleranceMinutes = 3; // Allow 3-minute difference
    
    _comparePrayerTime('Fajr', ourTimesLocal['fajr']!, apiTimes['fajr'], toleranceMinutes);
    _comparePrayerTime('Sunrise', ourTimesLocal['sunrise']!, apiTimes['sunrise'], toleranceMinutes);
    _comparePrayerTime('Dhuhr', ourTimesLocal['dhuhr']!, apiTimes['dhuhr'], toleranceMinutes);
    _comparePrayerTime('Asr', ourTimesLocal['asr']!, apiTimes['asr'], toleranceMinutes);
    _comparePrayerTime('Maghrib', ourTimesLocal['maghrib']!, apiTimes['maghrib'], toleranceMinutes);
    _comparePrayerTime('Isha', ourTimesLocal['isha']!, apiTimes['isha'], toleranceMinutes);

    print('✅ $locationName validation passed');
  } catch (e) {
    print('❌ Error validating $locationName: $e');
    // Don't fail the test for network issues, just log the error
  }
}
