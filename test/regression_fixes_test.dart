import 'package:adhan_dart/adhan_dart.dart';
import 'package:test/test.dart';

void main() {
  group('prayer time utilities', () {
    final coords = Coordinates(35.775, -78.6336);
    final method = CalculationMethod.muslimWorldLeague;

    test('helpers normalize date to calendar Y/M/D', () {
      final calendarDay = DateTime.utc(2015, 12, 1);
      final midMorning = DateTime.utc(2015, 12, 1, 16, 0);

      final direct = PrayerTimes(
        coordinates: coords,
        date: calendarDay,
        calculationMethod: method,
      );

      final nextFromMidMorning = midMorning.getNextPrayer(
        coordinates: coords,
        calculationMethod: method,
      );

      expect(nextFromMidMorning.prayer, Prayer.dhuhr);
      expect(nextFromMidMorning.time, direct.dhuhr);
    });

    test('isInPrayerWindow is inclusive at prayer start', () {
      final pt = PrayerTimes(
        coordinates: coords,
        date: DateTime(2015, 12, 1),
        calculationMethod: method,
      );

      expect(
        pt.dhuhr.isInPrayerWindow(
          Prayer.dhuhr,
          coordinates: coords,
          calculationMethod: method,
        ),
        isTrue,
      );
      expect(pt.currentPrayer(time: pt.dhuhr), Prayer.dhuhr);
    });
  });

  group('aqrabYaum tomorrow field', () {
    test('tomorrow is day after resolved testDate, not original date+1', () {
      final coords = Coordinates(66.7222444, 17.7189);
      final date = DateTime(2020, 6, 21);

      final resolved = PolarCircleResolver.resolve(
        PolarCircleResolution.aqrabYaum,
        date,
        coords,
      );

      expect(resolved.tomorrow.isAfter(date), isTrue);
      expect(
        resolved.tomorrow,
        isNot(date.addDays(1)),
        reason: 'resolver shifts testDate away from the polar invalid day',
      );
    });
  });
}
