import 'dart:convert';
import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'test_helpers.dart';

void main() {
  tzdata.initializeTimeZones();

  final fixtureDir = Directory('test/fixtures/shared_times');
  if (!fixtureDir.existsSync()) {
    // Fallback for local dev when fixtures live only under /tmp/adhan-js.
    final fallback = Directory('/tmp/adhan-js/Shared/Times');
    if (!fallback.existsSync()) {
      throw StateError(
        'Missing fixtures: expected test/fixtures/shared_times or /tmp/adhan-js/Shared/Times',
      );
    }
    for (final file in fallback.listSync().whereType<File>()) {
      if (file.path.endsWith('.json')) {
        _registerFixtureTests(file);
      }
    }
    return;
  }

  for (final file in fixtureDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))) {
    _registerFixtureTests(file);
  }
}

void _registerFixtureTests(File file) {
  final data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final params = data['params'] as Map<String, dynamic>;
  final times = data['times'] as List<dynamic>;
  final variance = (data['variance'] as num?)?.toInt() ?? 1;
  final filename = file.uri.pathSegments.last;

  test('compare calculated times against $filename', () {
    final coordinates = Coordinates(
      (params['latitude'] as num).toDouble(),
      (params['longitude'] as num).toDouble(),
    );
    final method = parseFixtureParams(params);
    final location = tz.getLocation(params['timezone'] as String);

    for (final entry in times) {
      final time = entry as Map<String, dynamic>;
      final date = parseFixtureDate(time['date'] as String);
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationMethod: method,
      );

      expectWithinMinutes(
        prayerTimes.fajr,
        parseFixtureTime(
          time['date'] as String,
          time['fajr'] as String,
          location,
        ),
        varianceMinutes: variance,
        reason: '${time['date']} fajr',
      );
      expectWithinMinutes(
        prayerTimes.sunrise,
        parseFixtureTime(
          time['date'] as String,
          time['sunrise'] as String,
          location,
        ),
        varianceMinutes: variance,
        reason: '${time['date']} sunrise',
      );
      expectWithinMinutes(
        prayerTimes.dhuhr,
        parseFixtureTime(
          time['date'] as String,
          time['dhuhr'] as String,
          location,
        ),
        varianceMinutes: variance,
        reason: '${time['date']} dhuhr',
      );
      expectWithinMinutes(
        prayerTimes.asr,
        parseFixtureTime(
          time['date'] as String,
          time['asr'] as String,
          location,
        ),
        varianceMinutes: variance,
        reason: '${time['date']} asr',
      );
      expectWithinMinutes(
        prayerTimes.maghrib,
        parseFixtureTime(
          time['date'] as String,
          time['maghrib'] as String,
          location,
        ),
        varianceMinutes: variance,
        reason: '${time['date']} maghrib',
      );
      expectWithinMinutes(
        prayerTimes.isha,
        parseFixtureTime(
          time['date'] as String,
          time['isha'] as String,
          location,
        ),
        varianceMinutes: variance,
        reason: '${time['date']} isha',
      );
    }
  });
}
