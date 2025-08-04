import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';

void main() {
  print('🧪 PUB.DEV VERSION BENCHMARK');
  print('📅 Date: ${DateTime.now()}');
  print('🖥️  Platform: ${Platform.operatingSystem}');
  print('📦 Version: Using pub.dev adhan_dart ^1.1.2');
  print('');

  _runBenchmarks();
}

void _runBenchmarks() {
  print('1️⃣ Basic Prayer Time Calculation Test');

  final coords = Coordinates(21.3891, 39.8579); // Mecca
  final date = DateTime(2024, 6, 15);

  // Use the correct constructor for the pub.dev version
  final params = CalculationParameters(
    method: 'other', // String instead of enum in pub.dev version
    fajrAngle: 18.0,
    ishaAngle: 17.0,
  );

  const iterations = 500;
  print('   🎯 Running $iterations iterations...');

  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    final prayerTimes = PrayerTimes(
      coordinates: coords,
      date: date,
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
  print(
      '   📈 Throughput: ${throughput.toStringAsFixed(0)} calculations/second');
  print('');

  // Test repeated calculations (no caching expected)
  print('2️⃣ Repeated Calculations Test (Same Parameters)');
  const repeatedIterations = 100;

  final repeatedStopwatch = Stopwatch()..start();

  for (int i = 0; i < repeatedIterations; i++) {
    final prayerTimes = PrayerTimes(
      coordinates: coords, // Same coordinates
      date: date, // Same date
      calculationParameters: params, // Same parameters
    );
    SunnahTimes(prayerTimes);
  }

  repeatedStopwatch.stop();

  final repeatedAvgTime =
      repeatedStopwatch.elapsedMicroseconds / repeatedIterations;

  print(
      '   ⏱️  Average time: ${repeatedAvgTime.toStringAsFixed(1)}μs per calculation');
  print('   🎯 Total time: ${repeatedStopwatch.elapsedMilliseconds}ms');
  print('   📊 No caching optimizations expected in pub.dev version');
  print('');

  // Memory usage test
  print('3️⃣ Memory Usage Test');
  _testMemoryUsage(coords, date, params);

  print('✅ PUB.DEV VERSION BENCHMARK COMPLETED');
  print('');
}

void _testMemoryUsage(
    Coordinates coords, DateTime date, CalculationParameters params) {
  const objectCount = 500;
  final objects = <dynamic>[];

  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < objectCount; i++) {
    final prayerTimes = PrayerTimes(
      coordinates: coords,
      date: date.add(Duration(days: i)),
      calculationParameters: params,
    );
    objects.add(prayerTimes);
    objects.add(SunnahTimes(prayerTimes));
  }

  stopwatch.stop();

  print(
      '   📦 Created ${objects.length} objects in ${stopwatch.elapsedMilliseconds}ms');
  print(
      '   ⏱️  Average creation time: ${(stopwatch.elapsedMicroseconds / objectCount).toStringAsFixed(1)}μs per object');
  print('   🧠 Objects use mutable state (pub.dev version)');
}
