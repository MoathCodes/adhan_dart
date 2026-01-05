import 'package:adhan_dart/adhan_dart.dart';

void main() {
  print('=== UX Improvements Demo ===\n');

  // 1. More intuitive API with roundToMinutes instead of precision
  print('1. Clearer API parameters:');
  final times = PrayerTimesData.calculate(
    date: DateTime.now(),
    coordinates: const Coordinates(40.7128, -74.0060), // NYC
    calculationParameters: CalculationMethodParameters.northAmerica(),
    roundToMinutes: true, // Much clearer than precision: false
  );
  print('   ✅ roundToMinutes: true (was precision: false)');

  // 2. Convenient factory method
  print('\n2. Convenient factory method:');
  final quickTimes = PrayerTimesCalculator.forLocation(
    date: DateTime.now(),
    latitude: 40.7128,
    longitude: -74.0060,
    method: CalculationMethod.northAmerica,
  );
  print('   ✅ Simple one-liner for common usage');

  // 3. Estimation transparency
  print('\n3. Estimation transparency:');
  print(
      '   Fajr: ${times.fajr.hour.toString().padLeft(2, '0')}:${times.fajr.minute.toString().padLeft(2, '0')} ${times.isEstimated(Prayer.fajr) ? '(estimated)' : '(calculated)'}');
  print(
      '   Isha: ${times.isha.hour.toString().padLeft(2, '0')}:${times.isha.minute.toString().padLeft(2, '0')} ${times.isEstimated(Prayer.isha) ? '(estimated)' : '(calculated)'}');

  // 4. Validation warnings
  print('\n4. Validation warnings:');
  final warnings = times.validate();
  if (warnings.isEmpty) {
    print('   ✅ No validation warnings');
  } else {
    for (final warning in warnings) {
      print('   ⚠️  $warning');
    }
  }

  // 5. Supported methods discovery
  print('\n5. Method discovery:');
  print(
      '   Supported methods: ${PrayerTimesCalculator.supportedMethods.length}');
  for (final method in PrayerTimesCalculator.supportedMethods.take(3)) {
    print('   - ${method.name}');
  }
  print('   ... and ${PrayerTimesCalculator.supportedMethods.length - 3} more');

  // 6. Input validation
  print('\n6. Input validation:');
  try {
    PrayerTimesCalculator.forLocation(
      date: DateTime.now(),
      latitude: 91.0, // Invalid latitude
      longitude: 0.0,
      method: CalculationMethod.northAmerica,
    );
  } catch (e) {
    print('   ✅ Caught invalid latitude: ${e.toString().split(':')[1].trim()}');
  }

  // 7. High-latitude demonstration
  print('\n7. High-latitude handling:');
  final polarTimes = PrayerTimesCalculator.forLocation(
    date: DateTime(2024, 6, 21), // Summer solstice
    latitude: 64.1466, // Reykjavik
    longitude: -21.9426,
    method: CalculationMethod.muslimWorldLeague,
  );

  if (polarTimes.estimatedPrayers.isNotEmpty) {
    print(
        '   ⚠️  Using estimated times for extreme latitude: ${polarTimes.estimatedPrayers.map((p) => p.name).join(', ')}');
  }

  print('\n=== Demo Complete ===');
}
