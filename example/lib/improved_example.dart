import 'package:adhan_dart/adhan_dart.dart';

/// Example demonstrating the improved adhan_dart API and new features
void main() {
  print('🚀 Enhanced Adhan Dart Example\n');

  // 1. Improved Coordinates with validation
  print('1. Coordinates with validation:');
  try {
    final coords = Coordinates.validated(21.3891, 39.8579); // Mecca
    print('   ✅ Valid coordinates: $coords');
    print('   📍 Is valid: ${coords.isValid}');
  } catch (e) {
    print('   ❌ Invalid coordinates: $e');
  }

  // Test invalid coordinates
  try {
    Coordinates.validated(91, 0); // Invalid latitude
  } catch (e) {
    print('   ❌ Caught validation error: $e');
  }

  // 2. Regional calculation methods
  print('\n2. Regional calculation methods:');
  final saudiParams = CalculationMethodParameters.ummAlQura();
  final usaParams = CalculationMethodParameters.northAmerica();
  final ukParams = CalculationMethodParameters.other();

  print('   🇸🇦 Saudi Arabia method: ${saudiParams.method}');
  print('   🇺🇸 USA method: ${usaParams.method}');
  print('   🇬🇧 UK method: ${ukParams.method}');

  // 3. Convenient extension methods
  print('\n3. Convenient extension methods:');
  const meccaCoords = Coordinates(21.3891, 39.8579);

  // Get today's prayer times with one method call
  final todaysPrayers =
      meccaCoords.todaysPrayerTimes(CalculationMethod.ummAlQura);
  print('   🕌 Today\'s Fajr in Mecca: ${todaysPrayers.fajr}');

  // Get prayer times for a specific date
  final specificDate = DateTime(2024, 12, 25);
  final christmasPrayers =
      meccaCoords.prayerTimesFor(specificDate, CalculationMethod.ummAlQura);
  print('   🎄 Christmas Day Fajr in Mecca: ${christmasPrayers.fajr}');

  // 4. Improved copyWith functionality
  print('\n4. Improved copyWith functionality:');
  final baseParams = CalculationMethodParameters.muslimWorldLeague();
  final customParams = baseParams.copyWith(
    madhab: Madhab.hanafi,
    ishaInterval: 90, // Now works correctly!
    adjustments: {
      Prayer.fajr: 5,
      Prayer.dhuhr: 3,
      Prayer.asr: 0,
      Prayer.maghrib: 2,
      Prayer.isha: 0,
      Prayer.sunrise: 0,
    },
  );
  print('   📋 Base method: ${baseParams.method}');
  print('   ⚙️ Custom madhab: ${customParams.madhab}');
  print('   ⏰ Custom isha interval: ${customParams.ishaInterval} minutes');

  // 5. Enhanced type safety
  print('\n5. Enhanced type safety:');
  const coordinates = Coordinates(35.7796, -78.6382); // Raleigh, NC
  final prayerTimes = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: coordinates,
    calculationParameters: CalculationMethodParameters.moonsightingCommittee(),
    precision: true,
  );

  print('   📍 Location: Raleigh, NC');
  print('   🌅 Fajr: ${prayerTimes.fajr}');
  print('   ☀️ Sunrise: ${prayerTimes.sunrise}');
  print('   🌞 Dhuhr: ${prayerTimes.dhuhr}');
  print('   🌆 Asr: ${prayerTimes.asr}');
  print('   🌇 Maghrib: ${prayerTimes.maghrib}');
  print('   🌙 Isha: ${prayerTimes.isha}');

  // 6. Optimized Sunnah times (avoids duplicate calculations)
  print('\n6. Optimized Sunnah times:');
  final sunnahTimes = SunnahTimes(prayerTimes, precision: true);
  print('   🌃 Middle of night: ${sunnahTimes.middleOfTheNight}');
  print('   ⭐ Last third of night: ${sunnahTimes.lastThirdOfTheNight}');

  // 7. Qibla direction
  print('\n7. Qibla direction:');
  final qiblaDirection = Qibla.qibla(coordinates);
  print(
      '   🧭 Qibla direction from Raleigh: ${qiblaDirection.toStringAsFixed(2)}°');

  print('\n✨ All improvements demonstrated successfully!');
}
