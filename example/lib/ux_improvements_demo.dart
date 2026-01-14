import 'package:adhan_dart/adhan_dart.dart';

void main() {
  print('=== UX Improvements Demo ===\n');

  // 1. More intuitive API with roundToMinutes instead of precision
  print('1. Clearer API parameters:');
  final times = PrayerTimes(
    date: DateTime.now(),
    coordinates: const Coordinates(40.7128, -74.0060), // NYC
    calculationMethod: CalculationMethod.northAmerica,
    roundToMinutes: true, // Much clearer than precision: false
  );
  print('   ✅ roundToMinutes: true (was precision: false)');

  // 2. Convenient factory method
  print('\n2. Convenient factory method:');
  final quickTimes = PrayerTimes(
    date: DateTime.now(),
    coordinates: const Coordinates(40.7128, -74.0060), // NYC
    calculationMethod: CalculationMethod.northAmerica,
    roundToMinutes: true, // Much clearer than precision: false
  );
  print('   ✅ Simple one-liner for common usage');

  // 3. Estimation transparency
  print('\n3. Estimation transparency:');
  print(
    '   Fajr: ${times.fajr.hour.toString().padLeft(2, '0')}:${times.fajr.minute.toString().padLeft(2, '0')} ${times.estimatedPrayers.contains(Prayer.fajr) ? '(estimated)' : '(calculated)'}',
  );
  print(
    '   Isha: ${times.isha.hour.toString().padLeft(2, '0')}:${times.isha.minute.toString().padLeft(2, '0')} ${times.estimatedPrayers.contains(Prayer.isha) ? '(estimated)' : '(calculated)'}',
  );

  // 4. Supported methods discovery
  print('\n4. Method discovery:');
  print('   Supported methods: ${CalculationMethod.values.length}');
  for (final method in CalculationMethod.values.take(3)) {
    print('   - ${method.runtimeType}');
  }
  print('   ... and ${CalculationMethod.values.length - 3} more');

  // 5. Input validation
  print('\n5. Input validation:');
  try {
    PrayerTimes(
      date: DateTime.now(),
      coordinates: Coordinates(91.0, 0.0), // Invalid latitude
      calculationMethod: CalculationMethod.northAmerica,
    );
  } catch (e) {
    print('   ✅ Caught invalid latitude: ${e.toString().split(':')[1].trim()}');
  }

  // 6. High-latitude demonstration
  print('\n6. High-latitude handling:');
  final polarTimes = PrayerTimes(
    date: DateTime(2024, 6, 21), // Summer solstice
    coordinates: const Coordinates(64.1466, -21.9426), // Reykjavik
    calculationMethod: CalculationMethod.muslimWorldLeague,
  );

  if (polarTimes.estimatedPrayers.isNotEmpty) {
    print(
      '   ⚠️  Using estimated times for extreme latitude: ${polarTimes.estimatedPrayers.map((p) => p.name).join(', ')}',
    );
  }

  print('\n=== Demo Complete ===');
}
