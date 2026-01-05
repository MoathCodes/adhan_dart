/// Comprehensive UX improvements demonstration for adhan_dart library
///
/// This demo showcases the enhanced developer experience features:
/// - Enhanced enum extensions with regional guidance
/// - DateTime utilities for prayer time calculations
/// - Improved discoverability and type safety
/// - Better error handling and validation

import 'package:adhan_dart/adhan_dart.dart';

void main() {
  print('🚀 Advanced UX Improvements Demo\n');

  demoEnhancedEnums();
  demoCalculationMethodDiscovery();
  demoDateTimeUtilities();
  demoValidationAndErrorHandling();
  demoFormattingAndDisplay();

  print('\n✨ UX improvements demo complete!');
}

void demoCalculationMethodDiscovery() {
  print('2️⃣  Regional Method Discovery');
  print('   ===========================\n');

  // Regional method discovery
  final regions = [
    'Middle East',
    'South Asia',
    'Southeast Asia',
    'North America',
    'Europe'
  ];

  for (final region in regions) {
    final methods = CalculationMethodExtensions.forRegion(region);
    print('   📍 $region:');
    for (final method in methods) {
      print('      • ${method.displayName} - ${method.description}');
    }
    print('');
  }
}

void demoDateTimeUtilities() {
  print('3️⃣  DateTime Utilities & Current Prayer Detection');
  print('   ===============================================\n');

  const coordinates = Coordinates(21.3891, 39.8579); // Mecca
  final params = CalculationMethodParameters.ummAlQura();
  final now = DateTime.now();

  // Current prayer detection
  final currentPrayer = now.getCurrentPrayer(
    coordinates: coordinates,
    calculationParameters: params,
  );

  if (currentPrayer != null) {
    print('   🕐 Current prayer: ${currentPrayer.displayName}');
  } else {
    print('   🌙 Currently between prayers (night time or interval)');
  }

  // Next prayer information
  final nextPrayer = now.getNextPrayer(
    coordinates: coordinates,
    calculationParameters: params,
  );

  final timeUntil = now.timeUntilNextPrayer(
    coordinates: coordinates,
    calculationParameters: params,
  );

  print('   ⏰ Next prayer: ${nextPrayer.prayer.displayName}');
  print('   📅 Time: ${nextPrayer.time}');
  print(
      '   ⏳ Time remaining: ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m');

  // Prayer window checking
  print('\n   📊 Prayer Window Analysis:');
  for (final prayer in PrayerExtensions.obligatoryPrayers) {
    final inWindow = now.isInPrayerWindow(
      prayer,
      coordinates: coordinates,
      calculationParameters: params,
    );
    final status = inWindow ? '✅ Active' : '⏸️  Inactive';
    print('   ${prayer.displayName}: $status');
  }

  print('');
}

void demoEnhancedEnums() {
  print('1️⃣  Enhanced Enum Extensions');
  print('   ========================\n');

  // Prayer enum improvements
  print('   📿 Prayer Information:');
  for (final prayer in PrayerExtensions.obligatoryPrayers) {
    print('   ${prayer.displayName}: ${prayer.description}');
    print('      Obligatory: ${prayer.isObligatory}');
  }

  print('\n   ⏰ Additional Times:');
  print('   ${Prayer.sunrise.displayName}: ${Prayer.sunrise.description}');

  print('\n   🕌 Calculation Method Information:');
  const method = CalculationMethod.ummAlQura;
  print('   Method: ${method.displayName}');
  print('   Region: ${method.region}');
  print('   Description: ${method.description}');

  print('\n   🌍 High Latitude Rule Guidance:');
  for (final rule in HighLatitudeRule.values) {
    print('   ${rule.displayName}:');
    print('      ${rule.description}');
    print('      Usage: ${rule.usageGuidance}');
  }

  print('');
}

void demoFormattingAndDisplay() {
  print('5️⃣  Enhanced Formatting & Display');
  print('   ===============================\n');

  const coordinates = Coordinates(40.7128, -74.0060); // New York
  final params = CalculationMethodParameters.northAmerica();
  final date = DateTime.now();

  final prayerTimes = PrayerTimesData.calculate(
    date: date,
    coordinates: coordinates,
    calculationParameters: params,
  );

  // Formatted display
  print('   📋 Formatted Prayer Times:');
  print(prayerTimes.formatForDisplay(includeDate: true, include24Hour: true));

  print('\n   🕐 12-Hour Format:');
  print(prayerTimes.formatForDisplay(includeDate: false, include24Hour: false));

  // Duration calculations
  print('\n   ⏰ Duration Information:');
  print(
      '   Day duration (Fajr to Maghrib): ${_formatDuration(prayerTimes.dayDuration)}');
  print(
      '   Night duration (Maghrib to next Fajr): ${_formatDuration(prayerTimes.nightDuration)}');

  // Prayer times map
  print('\n   📊 Prayer Times Analysis:');
  final allTimes = prayerTimes.allPrayerTimes;
  final obligatoryTimes = prayerTimes.obligatoryPrayerTimes;

  print('   Total times available: ${allTimes.length}');
  print('   Obligatory prayers: ${obligatoryTimes.length}');

  // Time between prayers
  print('\n   ⏱️  Intervals Between Prayers:');
  final obligatoryList = PrayerExtensions.obligatoryPrayers;
  for (int i = 0; i < obligatoryList.length - 1; i++) {
    final current = prayerTimes.timeForPrayer(obligatoryList[i]);
    final next = prayerTimes.timeForPrayer(obligatoryList[i + 1]);
    final interval = next.difference(current);
    print(
        '   ${obligatoryList[i].displayName} → ${obligatoryList[i + 1].displayName}: ${_formatDuration(interval)}');
  }

  print('');
}

void demoValidationAndErrorHandling() {
  print('4️⃣  Enhanced Validation & Error Handling');
  print('   =======================================\n');

  // Coordinate validation
  print('   🌐 Coordinate Validation:');
  try {
    final validCoords = Coordinates.validated(25.2048, 55.2708); // Dubai
    print(
        '   ✅ Valid coordinates: ${validCoords.latitude}, ${validCoords.longitude}');
  } catch (e) {
    print('   ❌ Validation error: $e');
  }

  try {
    final invalidCoords = Coordinates.validated(91.0, 181.0); // Invalid
    print(
        '   Coordinates: ${invalidCoords.latitude}, ${invalidCoords.longitude}');
  } catch (e) {
    print('   ❌ Caught validation error: $e');
  }

  // Prayer times validation
  print('\n   ⚠️  Prayer Times Validation:');
  const extremeCoords = Coordinates(70.0, 23.0); // Northern Norway
  final extremeParams = CalculationMethodParameters.muslimWorldLeague()
      .copyWith(highLatitudeRule: HighLatitudeRule.middleOfTheNight);

  final extremePrayerTimes = PrayerTimesData.calculate(
    date: DateTime(2024, 6, 21), // Summer solstice
    coordinates: extremeCoords,
    calculationParameters: extremeParams,
  );

  final warnings = extremePrayerTimes.validate();
  print('   Validation warnings for extreme latitude:');
  for (final warning in warnings) {
    print('   ⚠️  $warning');
  }

  print('');
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  return '${hours}h ${minutes}m';
}
