import 'package:adhan_dart/adhan_dart.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

/// Parses a fixture time like `6:25 AM` into 24-hour hour/minute.
(int hour, int minute) parseAmPm(String time) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    caseSensitive: false,
  ).firstMatch(time.trim());
  if (match == null) {
    throw FormatException('Invalid AM/PM time: $time');
  }

  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3)!.toUpperCase();

  if (period == 'AM') {
    if (hour == 12) hour = 0;
  } else {
    if (hour != 12) hour += 12;
  }

  return (hour, minute);
}

/// Builds a [TZDateTime] for a fixture row in the fixture timezone.
tz.TZDateTime parseFixtureTime(
  String dateStr,
  String timeStr,
  tz.Location location,
) {
  final dateParts = dateStr.split('-');
  final year = int.parse(dateParts[0]);
  final month = int.parse(dateParts[1]);
  final day = int.parse(dateParts[2]);
  final (hour, minute) = parseAmPm(timeStr);
  return tz.TZDateTime(location, year, month, day, hour, minute);
}

/// Formats a UTC prayer instant as local `h:mm AM/PM` (adhan-js moment style).
String formatLocalPrayerTime(DateTime utc, tz.Location location) {
  final local = tz.TZDateTime.from(utc.toUtc(), location);
  final period = local.hour >= 12 ? 'PM' : 'AM';
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  return '$hour12:${local.minute.toString().padLeft(2, '0')} $period';
}

void expectWithinMinutes(
  DateTime actualUtc,
  tz.TZDateTime expectedLocal, {
  required int varianceMinutes,
  String? reason,
}) {
  final expectedUtc = expectedLocal.toUtc();
  final diffMs =
      (actualUtc.toUtc().millisecondsSinceEpoch -
              expectedUtc.millisecondsSinceEpoch)
          .abs();
  expect(
    diffMs,
    lessThanOrEqualTo(varianceMinutes * 60 * 1000),
    reason:
        reason ??
        'expected within $varianceMinutes min of $expectedLocal, got $actualUtc',
  );
}

void expectLocalTime(
  DateTime actualUtc,
  tz.Location location,
  String expected, {
  String? reason,
}) {
  expect(
    formatLocalPrayerTime(actualUtc, location),
    expected,
    reason: reason,
  );
}

CalculationMethod parseFixtureParams(Map<String, dynamic> params) {
  CalculationMethod method = switch (params['method'] as String) {
    'MuslimWorldLeague' => CalculationMethod.muslimWorldLeague,
    'Egyptian' => CalculationMethod.egyptian,
    'Karachi' => CalculationMethod.karachi,
    'UmmAlQura' => CalculationMethod.ummAlQura,
    'Dubai' => CalculationMethod.dubai,
    'MoonsightingCommittee' => CalculationMethod.moonsightingCommittee,
    'NorthAmerica' => CalculationMethod.northAmerica,
    'Kuwait' => CalculationMethod.kuwait,
    'Qatar' => CalculationMethod.qatar,
    'Singapore' => CalculationMethod.singapore,
    'Tehran' => CalculationMethod.tehran,
    'Turkey' => CalculationMethod.turkiye,
    _ => CalculationMethod.other,
  };

  method = switch (params['madhab'] as String) {
    'Hanafi' => method.copyWith(madhab: Madhab.hanafi),
    'Shafi' => method.copyWith(madhab: Madhab.shafi),
    _ => method,
  };

  method = switch (params['highLatitudeRule'] as String) {
    'SeventhOfTheNight' => method.copyWith(
      highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
    ),
    'TwilightAngle' => method.copyWith(
      highLatitudeRule: HighLatitudeRule.twilightAngle,
    ),
    _ => method.copyWith(
      highLatitudeRule: HighLatitudeRule.middleOfTheNight,
    ),
  };

  // Golden fixtures assume adhan-js default (unresolved).
  return method.copyWith(polarCircleResolution: PolarCircleResolution.unresolved);
}

DateTime parseFixtureDate(String dateStr) {
  final parts = dateStr.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
