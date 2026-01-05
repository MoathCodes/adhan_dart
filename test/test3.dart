import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Updated behavior notes (library changed semantics):
/// - After Isha begins, currentPrayer returns fajrAfter and nextPrayer returns fajr.
/// - After Midnight (and before Fajr), currentPrayer returns ishaBefore and nextPrayer returns fajr.
/// This test demonstrates both scenarios deterministically for Asia/Riyadh.
void main() {
  tz.initializeTimeZones();
  // final location = tz.getLocation('America/New_York');
  final location = tz.getLocation('Asia/Riyadh');

  // Definitions
  // Use a fixed reference date to make the output deterministic across runs
  final DateTime reference = tz.TZDateTime(location, 2025, 9, 7, 12, 0, 0);

  // Coordinates (Madinah, KSA). You can change this if needed.
  const Coordinates coordinates = Coordinates(24.469874, 39.556430);

  // Parameters
  final CalculationParameters params = CalculationMethodParameters.ummAlQura();

  // Calculate prayer times for the reference date
  final PrayerTimesData prayerTimes = const PrayerTimesCalculator().calculate(
    date: reference,
    coordinates: coordinates,
    params: params,
    roundToMinutes: true,
  );

  // Sunnah times (derived from maghrib → next fajr)
  final SunnahTimes sunnahTimes = SunnahTimes(prayerTimes);

  // Build deterministic scenario times based on the computed schedule
  final DateTime afterIsha = prayerTimes.isha.add(const Duration(minutes: 1));
  final DateTime beforeFajr =
      sunnahTimes.middleOfTheNight.add(const Duration(hours: 4));

  // Pretty printers
  String hhmm(DateTime t) =>
      '${t.toLocal().hour.toString().padLeft(2, '0')}:${t.toLocal().minute.toString().padLeft(2, '0')}';

  print(
      'Location: Asia/Riyadh  |  Coords: ${coordinates.latitude}, ${coordinates.longitude}');
  print('Method: Umm Al-Qura');
  print('Date: ${reference.toLocal()}');
  print('— Computed Times (local) —');
  print('Fajr    : ${hhmm(prayerTimes.fajr)}');
  print('Sunrise : ${hhmm(prayerTimes.sunrise)}');
  print('Dhuhr   : ${hhmm(prayerTimes.dhuhr)}');
  print('Asr     : ${hhmm(prayerTimes.asr)}');
  print('Maghrib : ${hhmm(prayerTimes.maghrib)}');
  print('Isha    : ${hhmm(prayerTimes.isha)}');
  print('Middle of Night : ${hhmm(sunnahTimes.middleOfTheNight)}');
  print('Last Third      : ${hhmm(sunnahTimes.lastThirdOfTheNight)}');

  // Scenario 1: After Isha
  print('\nScenario: After Isha (+1 min) at ${hhmm(afterIsha)}');
  print('currentPrayer → ${prayerTimes.currentPrayer(date: afterIsha)}');
  print('nextPrayer    → ${prayerTimes.nextPrayer(date: afterIsha)}');

  // Scenario 2: After Midnight (1 hour before Fajr)
  print('\nScenario: After Midnight (1h before Fajr) at ${hhmm(beforeFajr)}');
  print('currentPrayer → ${prayerTimes.currentPrayer(date: beforeFajr)}');
  print('nextPrayer    → ${prayerTimes.nextPrayer(date: beforeFajr)}');

  // --- Transition Scanner -------------------------------------------------
  // We scan a 30h window centered on the reference day to capture all relevant
  // transitions (including fajrAfter/ishaBefore semantics around midnight).
  final DateTime startScan = tz.TZDateTime(
      location, reference.year, reference.month, reference.day, 0, 0, 0);
  final DateTime endScan = startScan.add(const Duration(hours: 30));

  Prayer? lastPrayer;
  DateTime? lastChangeTime;

  final List<_Transition> transitions = [];

  DateTime cursor = startScan;
  while (cursor.isBefore(endScan)) {
    final Prayer current = prayerTimes.currentPrayer(date: cursor);
    if (lastPrayer == null) {
      lastPrayer = current;
      lastChangeTime = cursor;
    } else if (current != lastPrayer) {
      // We detected a boundary between lastChangeTime..cursor.
      final refined = _refineBoundary(
          prayerTimes, lastPrayer, current, lastChangeTime!, cursor);
      transitions.add(_Transition(from: lastPrayer, to: current, at: refined));
      lastPrayer = current;
      lastChangeTime = refined;
    }
    cursor = cursor.add(const Duration(minutes: 1));
  }

  print('\n— Detected currentPrayer transitions (refined) —');
  for (final t in transitions) {
    print('${hhmm(t.at)}  :  ${t.from.name} → ${t.to.name}');
  }

  // Also log the raw prayer times for comparison to expected boundaries
  print('\n— Expected canonical prayer boundaries —');
  print('Fajr -> Sunrise boundary at  ${hhmm(prayerTimes.sunrise)}');
  print('Sunrise -> Dhuhr boundary at ${hhmm(prayerTimes.dhuhr)}');
  print('Dhuhr -> Asr boundary at    ${hhmm(prayerTimes.asr)}');
  print('Asr -> Maghrib boundary at  ${hhmm(prayerTimes.maghrib)}');
  print('Maghrib -> Isha boundary at ${hhmm(prayerTimes.isha)}');
  print('Isha extended states around:');
  print('  Middle of Night (sunnah)  ${hhmm(sunnahTimes.middleOfTheNight)}');
  print(
      '  Last Third start           ${hhmm(sunnahTimes.lastThirdOfTheNight)}');
}

/// Refine the transition moment between [lo] (where prayer == fromPrayer)
/// and [hi] (where prayer == toPrayer) using binary search to minute
/// resolution (since the calculator was rounded to minutes already).
DateTime _refineBoundary(PrayerTimesData data, Prayer fromPrayer,
    Prayer toPrayer, DateTime lo, DateTime hi) {
  while (hi.difference(lo).inMinutes > 1) {
    final mid = lo.add(Duration(minutes: hi.difference(lo).inMinutes ~/ 2));
    final midPrayer = data.currentPrayer(date: mid);
    if (midPrayer == fromPrayer) {
      lo = mid; // boundary is after mid
    } else {
      hi = mid; // boundary is at or before mid
    }
  }
  return hi; // first minute where toPrayer applies
}

/// Simple structure to hold a transition record.
class _Transition {
  final Prayer from;
  final Prayer to;
  final DateTime at;
  _Transition({required this.from, required this.to, required this.at});
}
