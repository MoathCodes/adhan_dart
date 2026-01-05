import 'dart:io';
import 'package:adhan_dart/adhan_dart.dart';

void main() {
  print('🧪 LOCAL VERSION BENCHMARK');
  print('📅 Date: ${DateTime.now()}');
  print('🖥️  Platform: ${Platform.operatingSystem}');
  print('📦 Version: Using local enhanced adhan_dart');
  print('');

  _runBenchmarks();
}

void _runBenchmarks() {
  print('1️⃣ Basic Prayer Time Calculation Test (New API)');
  
  const coords = Coordinates(21.3891, 39.8579); // Mecca
  final date = DateTime(2024, 6, 15);
  final params = CalculationMethodParameters.ummAlQura();
  
  const iterations = 500;
  print('   🎯 Running $iterations iterations...');
  
  final stopwatch = Stopwatch()..start();
  
  for (int i = 0; i < iterations; i++) {
    final prayerTimes = PrayerTimesData.calculate(
      date: date,
      coordinates: coords,
      calculationParameters: params,
    );
    
    // Also test SunnahTimes
    SunnahTimes(prayerTimes);
  }
  
  stopwatch.stop();
  
  final avgTime = stopwatch.elapsedMicroseconds / iterations;
  final throughput = iterations / (stopwatch.elapsedMilliseconds / 1000);
  
  print('   ⏱️  Average time: ${avgTime.toStringAsFixed(1)}μs per calculation');
  print('   🎯 Total time: ${stopwatch.elapsedMilliseconds}ms');
  print('   📈 Throughput: ${throughput.toStringAsFixed(0)} calculations/second');
  print('');
  
  // Test repeated calculations (caching expected to help)
  print('2️⃣ Repeated Calculations Test (Same Parameters) - CACHING ACTIVE');
  const repeatedIterations = 100;
  
  final repeatedStopwatch = Stopwatch()..start();
  
  for (int i = 0; i < repeatedIterations; i++) {
    final prayerTimes = PrayerTimesData.calculate(
      coordinates: coords,  // Same coordinates
      date: date,          // Same date
      calculationParameters: params, // Same parameters
    );
    SunnahTimes(prayerTimes);
  }
  
  repeatedStopwatch.stop();
  
  final repeatedAvgTime = repeatedStopwatch.elapsedMicroseconds / repeatedIterations;
  
  print('   ⏱️  Average time: ${repeatedAvgTime.toStringAsFixed(1)}μs per calculation');
  print('   🎯 Total time: ${repeatedStopwatch.elapsedMilliseconds}ms');
  print('   🚀 Caching optimizations active in local version');
  print('');
  
  // Memory usage test
  print('3️⃣ Memory Usage Test');
  _testMemoryUsage(coords, date, params);
  
  // Test coordinate validation
  print('4️⃣ Coordinate Validation Test');
  _testCoordinateValidation();
  
  print('✅ LOCAL VERSION BENCHMARK COMPLETED');
  print('');
}

void _testMemoryUsage(Coordinates coords, DateTime date, CalculationParameters params) {
  const objectCount = 500;
  final objects = <dynamic>[];
  
  final stopwatch = Stopwatch()..start();
  
  for (int i = 0; i < objectCount; i++) {
    final prayerTimes = PrayerTimesData.calculate(
      coordinates: coords,
      date: date.add(Duration(days: i)),
      calculationParameters: params,
    );
    objects.add(prayerTimes);
    objects.add(SunnahTimes(prayerTimes));
  }
  
  stopwatch.stop();
  
  print('   📦 Created ${objects.length} objects in ${stopwatch.elapsedMilliseconds}ms');
  print('   ⏱️  Average creation time: ${(stopwatch.elapsedMicroseconds / objectCount).toStringAsFixed(1)}μs per object');
  print('   🛡️  Objects use immutable state (local version)');
}

void _testCoordinateValidation() {
  const iterations = 5000;
  
  // Test regular constructor
  final regularStopwatch = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    Coordinates(21.3891 + i * 0.0001, 39.8579 + i * 0.0001);
  }
  regularStopwatch.stop();
  
  // Test validated constructor
  final validatedStopwatch = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    Coordinates.validated(21.3891 + i * 0.0001, 39.8579 + i * 0.0001);
  }
  validatedStopwatch.stop();
  
  print('   🔧 Regular coordinates: ${regularStopwatch.elapsedMicroseconds}μs total');
  print('   🛡️  Validated coordinates: ${validatedStopwatch.elapsedMicroseconds}μs total');
  
  final overhead = ((validatedStopwatch.elapsedMicroseconds - regularStopwatch.elapsedMicroseconds) / 
      regularStopwatch.elapsedMicroseconds * 100);
  print('   📈 Validation overhead: ${overhead.toStringAsFixed(1)}%');
  print('');
}
