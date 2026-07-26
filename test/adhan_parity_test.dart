import 'package:adhan_dart/adhan_dart.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'test_helpers.dart';

void main() {
  tzdata.initializeTimeZones();

  group('Raleigh parity (adhan-js adhan.test.ts)', () {
    final raleigh = Coordinates(35.775, -78.6336);
    final newYork = tz.getLocation('America/New_York');

    test('ISNA Hanafi 2015-07-12', () {
      final method = CalculationMethod.northAmerica.copyWith(
        madhab: Madhab.hanafi,
      );
      final pt = PrayerTimes(
        coordinates: raleigh,
        date: DateTime(2015, 7, 12),
        calculationMethod: method,
      );

      expectLocalTime(pt.fajr, newYork, '4:42 AM');
      expectLocalTime(pt.sunrise, newYork, '6:08 AM');
      expectLocalTime(pt.dhuhr, newYork, '1:21 PM');
      expectLocalTime(pt.asr, newYork, '6:22 PM');
      expectLocalTime(pt.maghrib, newYork, '8:32 PM');
      expectLocalTime(pt.isha, newYork, '9:57 PM');
    });

    test('MWL 2015-12-01', () {
      final method = CalculationMethod.muslimWorldLeague.copyWith(
        madhab: Madhab.shafi,
      );
      final pt = PrayerTimes(
        coordinates: raleigh,
        date: DateTime(2015, 12, 1),
        calculationMethod: method,
      );

      expectLocalTime(pt.fajr, newYork, '5:35 AM');
      expectLocalTime(pt.sunrise, newYork, '7:06 AM');
      expectLocalTime(pt.dhuhr, newYork, '12:05 PM');
      expectLocalTime(pt.asr, newYork, '2:42 PM');
      expectLocalTime(pt.maghrib, newYork, '5:01 PM');
      expectLocalTime(pt.isha, newYork, '6:26 PM');
    });
  });

  group('Oslo Moonsighting Committee Hanafi 2016-01-01', () {
    test('matches moonsighting.com reference', () {
      final oslo = tz.getLocation('Europe/Oslo');
      final method = CalculationMethod.moonsightingCommittee.copyWith(
        madhab: Madhab.hanafi,
      );
      final pt = PrayerTimes(
        coordinates: Coordinates(59.9094, 10.7349),
        date: DateTime(2016, 1, 1),
        calculationMethod: method,
      );

      expectLocalTime(pt.fajr, oslo, '7:34 AM');
      expectLocalTime(pt.sunrise, oslo, '9:19 AM');
      expectLocalTime(pt.dhuhr, oslo, '12:25 PM');
      expectLocalTime(pt.asr, oslo, '1:36 PM');
      expectLocalTime(pt.maghrib, oslo, '3:25 PM');
      expectLocalTime(pt.isha, oslo, '5:02 PM');
    });
  });

  group('International Date Line 2025-12-01', () {
    final params = CalculationMethod.muslimWorldLeague.copyWith(
      madhab: Madhab.shafi,
      highLatitudeRule: HighLatitudeRule.twilightAngle,
    );

    test('prayer ordering is correct near 177.24°E', () {
      final pt = PrayerTimes(
        coordinates: Coordinates(42.74674252600066, 177.2401196144623),
        date: DateTime(2025, 12, 1),
        calculationMethod: params,
      );

      expect(pt.fajr.isBefore(pt.sunrise), isTrue);
      expect(pt.sunrise.isBefore(pt.dhuhr), isTrue);
      expect(pt.dhuhr.isBefore(pt.asr), isTrue);
      expect(pt.asr.isBefore(pt.maghrib), isTrue);
      expect(pt.maghrib.isBefore(pt.isha), isTrue);
    });

    test('prayer ordering is correct near 177.25°E', () {
      final pt = PrayerTimes(
        coordinates: Coordinates(47.082209457885355, 177.24642294208638),
        date: DateTime(2025, 12, 1),
        calculationMethod: params,
      );

      expect(pt.fajr.isBefore(pt.sunrise), isTrue);
      expect(pt.sunrise.isBefore(pt.dhuhr), isTrue);
      expect(pt.dhuhr.isBefore(pt.asr), isTrue);
      expect(pt.asr.isBefore(pt.maghrib), isTrue);
      expect(pt.maghrib.isBefore(pt.isha), isTrue);
    });
  });

  group('Edinburgh high-latitude middleOfTheNight', () {
    final edinburgh = Coordinates(55.983226, -3.216649);
    final london = tz.getLocation('Europe/London');
    final date = DateTime(2020, 6, 15);

    test('middleOfTheNight rule', () {
      final pt = PrayerTimes(
        coordinates: edinburgh,
        date: date,
        calculationMethod: CalculationMethod.muslimWorldLeague,
      );

      expectLocalTime(pt.fajr, london, '1:14 AM');
      expectLocalTime(pt.sunrise, london, '4:26 AM');
      expectLocalTime(pt.dhuhr, london, '1:14 PM');
      expectLocalTime(pt.asr, london, '5:46 PM');
      expectLocalTime(pt.maghrib, london, '10:01 PM');
      expectLocalTime(pt.isha, london, '1:14 AM');
    });
  });

  group('copyWith preserves MoonsightingCommittee at lat >= 55', () {
    test('MSC identity and Oslo times after copyWith', () {
      final adjusted = CalculationMethod.moonsightingCommittee.copyWith(
        madhab: Madhab.hanafi,
      );
      expect(adjusted, isA<MoonsightingCommittee>());

      final oslo = tz.getLocation('Europe/Oslo');
      final pt = PrayerTimes(
        coordinates: Coordinates(59.9094, 10.7349),
        date: DateTime(2016, 1, 1),
        calculationMethod: adjusted,
      );

      expectLocalTime(pt.fajr, oslo, '7:34 AM');
      expectLocalTime(pt.isha, oslo, '5:02 PM');
    });
  });

  group('nextPrayer / timeForPrayer / nextPrayerTime after Isha', () {
    test('returns fajrAfter and its time', () {
      final pt = PrayerTimes(
        coordinates: Coordinates(33.720817, 73.090032),
        date: DateTime(2015, 9, 1),
        calculationMethod: CalculationMethod.karachi.copyWith(
          madhab: Madhab.hanafi,
          highLatitudeRule: HighLatitudeRule.twilightAngle,
        ),
      );

      final afterIsha = pt.isha.add(const Duration(minutes: 1));

      expect(pt.nextPrayer(time: afterIsha), Prayer.fajrAfter);
      expect(pt.timeForPrayer(Prayer.fajrAfter), pt.fajrAfter);
      expect(pt.nextPrayerTime(time: afterIsha), pt.fajrAfter);
      expect(pt.timeForPrayer(Prayer.ishaBefore), pt.ishaBefore);
    });

    test('full next-prayer chain through the day', () {
      final pt = PrayerTimes(
        coordinates: Coordinates(33.720817, 73.090032),
        date: DateTime(2015, 9, 1),
        calculationMethod: CalculationMethod.karachi.copyWith(
          madhab: Madhab.hanafi,
          highLatitudeRule: HighLatitudeRule.twilightAngle,
        ),
      );

      expect(pt.nextPrayer(time: pt.fajr.subtract(const Duration(minutes: 1))),
          Prayer.fajr);
      expect(pt.nextPrayer(time: pt.fajr), Prayer.sunrise);
      expect(pt.nextPrayer(time: pt.fajr.add(const Duration(minutes: 1))),
          Prayer.sunrise);
      expect(pt.nextPrayer(time: pt.sunrise.add(const Duration(minutes: 1))),
          Prayer.dhuhr);
      expect(pt.nextPrayer(time: pt.dhuhr.add(const Duration(minutes: 1))),
          Prayer.asr);
      expect(pt.nextPrayer(time: pt.asr.add(const Duration(minutes: 1))),
          Prayer.maghrib);
      expect(pt.nextPrayer(time: pt.maghrib.add(const Duration(minutes: 1))),
          Prayer.isha);
      expect(pt.nextPrayer(time: pt.isha.add(const Duration(minutes: 1))),
          Prayer.fajrAfter);
    });
  });

  group('cross-day prayer instants', () {
    final raleigh = Coordinates(35.775, -78.6336);
    final edinburgh = Coordinates(55.983226, -3.216649);
    final mwl = CalculationMethod.muslimWorldLeague;

    test('Raleigh MWL fajrAfter matches next day fajr', () {
      final date = DateTime(2015, 12, 1);
      final pt = PrayerTimes(
        coordinates: raleigh,
        date: date,
        calculationMethod: mwl,
      );
      final nextDayPt = PrayerTimes(
        coordinates: raleigh,
        date: date.addDays(1),
        calculationMethod: mwl,
      );
      final prevDayPt = PrayerTimes(
        coordinates: raleigh,
        date: date.addDays(-1),
        calculationMethod: mwl,
      );

      expect(pt.fajrAfter, nextDayPt.fajr);
      expect(pt.ishaBefore, prevDayPt.isha);
    });

    test('Edinburgh summer fajrAfter matches next day fajr', () {
      final date = DateTime(2020, 6, 15);
      final pt = PrayerTimes(
        coordinates: edinburgh,
        date: date,
        calculationMethod: mwl,
      );
      final nextDayPt = PrayerTimes(
        coordinates: edinburgh,
        date: date.addDays(1),
        calculationMethod: mwl,
      );
      final prevDayPt = PrayerTimes(
        coordinates: edinburgh,
        date: date.addDays(-1),
        calculationMethod: mwl,
      );

      expect(pt.fajrAfter, nextDayPt.fajr);
      expect(pt.ishaBefore, prevDayPt.isha);
    });
  });

  group('polar circle resolution', () {
    final raleigh = Coordinates(35.775, -78.6336);
    final date = DateTime(2015, 12, 1);
    final mwl = CalculationMethod.muslimWorldLeague;

    test('default unresolved does not shift mid-latitude Raleigh', () {
      expect(mwl.polarCircleResolution, PolarCircleResolution.unresolved);

      final pt = PrayerTimes(
        coordinates: raleigh,
        date: date,
        calculationMethod: mwl,
      );

      final newYork = tz.getLocation('America/New_York');
      expectLocalTime(pt.fajr, newYork, '5:35 AM');
      expectLocalTime(pt.isha, newYork, '6:26 PM');
    });

    test('unresolved and aqrabBalad agree at mid-latitude', () {
      final unresolved = PrayerTimes(
        coordinates: raleigh,
        date: date,
        calculationMethod: mwl,
      );
      final aqrabBalad = PrayerTimes(
        coordinates: raleigh,
        date: date,
        calculationMethod: mwl.copyWith(
          polarCircleResolution: PolarCircleResolution.aqrabBalad,
        ),
      );

      expect(aqrabBalad.fajr, unresolved.fajr);
      expect(aqrabBalad.isha, unresolved.isha);
    });

    test('aqrabYaum resolves polar midnight sun', () {
      final coords = Coordinates(66.7222444, 17.7189);
      final date = DateTime(2020, 6, 21);
      final method = CalculationMethod.muslimWorldLeague.copyWith(
        polarCircleResolution: PolarCircleResolution.aqrabYaum,
        highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
      );
      final pt = PrayerTimes(
        coordinates: coords,
        date: date,
        calculationMethod: method,
      );
      final stockholm = tz.getLocation('Europe/Stockholm');

      expectWithinMinutes(
        pt.fajr,
        parseFixtureTime('2020-06-21', '12:40 AM', stockholm),
        varianceMinutes: 5,
        reason: 'polar fajr',
      );
      expectWithinMinutes(
        pt.sunrise,
        parseFixtureTime('2020-06-21', '12:54 AM', stockholm),
        varianceMinutes: 5,
        reason: 'polar sunrise',
      );
      expectWithinMinutes(
        pt.dhuhr,
        parseFixtureTime('2020-06-21', '12:55 PM', stockholm),
        varianceMinutes: 5,
        reason: 'polar dhuhr',
      );
      expectWithinMinutes(
        pt.asr,
        parseFixtureTime('2020-06-21', '5:49 PM', stockholm),
        varianceMinutes: 5,
        reason: 'polar asr',
      );
      expectWithinMinutes(
        pt.maghrib,
        parseFixtureTime('2020-06-21', '11:36 PM', stockholm),
        varianceMinutes: 5,
        reason: 'polar maghrib',
      );
      expectWithinMinutes(
        pt.isha,
        parseFixtureTime('2020-06-21', '11:51 PM', stockholm),
        varianceMinutes: 5,
        reason: 'polar isha',
      );
    });

    test('unresolved uses emergency fallback at polar midnight sun', () {
      final coords = Coordinates(66.7222444, 17.7189);
      final date = DateTime(2020, 6, 21);
      final pt = PrayerTimes(
        coordinates: coords,
        date: date,
        calculationMethod: CalculationMethod.muslimWorldLeague,
      );

      expect(pt.estimatedPrayers, isNotEmpty);
      expect(pt.fajr.isBefore(pt.sunrise), isTrue);
      expect(pt.maghrib.isBefore(pt.isha), isTrue);
    });
  });
}
