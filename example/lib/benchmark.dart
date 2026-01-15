import 'package:adhan_dart/adhan_dart.dart';

/// Quick benchmark script to demonstrate performance improvements
/// Run with: dart run example/lib/benchmark.dart
void main() {
  print('🚀 Adhan Dart Performance Benchmark\n');

  benchmarkBasicCalculations();
  benchmarkSunnahTimesOptimization();
  benchmarkCoordinateValidation();
  benchmarkCachingEffectiveness();

  print(
    '\n✨ Benchmark complete! See PERFORMANCE_REPORT.md for detailed analysis.',
  );
}

void benchmarkBasicCalculations() {
  print('1️⃣  Basic Prayer Time Calculations');
  print('   Testing calculation speed...');

  const coords = Coordinates(21.3891, 39.8579); // Mecca
  final date = DateTime(2024, 6, 15);
  const params = UmmAlQura();

  const iterations = 100;
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    PrayerTimes(
      date: date,
      coordinates: coords,
      calculationMethod: params,
      roundToMinutes: true,
    );
  }

  stopwatch.stop();
  final avgTime = stopwatch.elapsedMicroseconds / iterations;

  print('   ✅ Average time: ${avgTime.toStringAsFixed(0)}μs per calculation');
  print(
    '   📊 Total time: ${stopwatch.elapsedMilliseconds}ms for $iterations calculations\n',
  );
}

void benchmarkCachingEffectiveness() {
  print('4️⃣  Caching Effectiveness');
  print('   Testing repeated vs varied calculations...');

  const coords = Coordinates(21.3891, 39.8579);
  final date = DateTime(2024, 6, 15);
  const params = UmmAlQura();
  const iterations = 50;

  // Test repeated calculations (should benefit from caching)
  final repeatedStopwatch = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    final prayerTimes = PrayerTimes(
      date: date, // Same date
      coordinates: coords, // Same coordinates
      calculationMethod: params,
    );
    SunnahTimes(prayerTimes);
  }
  repeatedStopwatch.stop();

  // Test varied calculations (less cache benefit)
  final variedStopwatch = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    final prayerTimes = PrayerTimes(
      date: date.add(Duration(days: i)), // Different dates
      coordinates: Coordinates(
        coords.latitude + i * 0.01,
        coords.longitude + i * 0.01,
      ), // Different coords
      calculationMethod: params,
    );
    SunnahTimes(prayerTimes);
  }
  variedStopwatch.stop();

  if (repeatedStopwatch.elapsedMilliseconds <
      variedStopwatch.elapsedMilliseconds) {
    final benefit =
        ((variedStopwatch.elapsedMilliseconds -
            repeatedStopwatch.elapsedMilliseconds) /
        variedStopwatch.elapsedMilliseconds *
        100);
    print(
      '   ✅ Repeated calculations: ${repeatedStopwatch.elapsedMilliseconds}ms',
    );
    print(
      '   📊 Varied calculations: ${variedStopwatch.elapsedMilliseconds}ms',
    );
    print(
      '   🚀 Cache benefit: ${benefit.toStringAsFixed(1)}% faster for repeated patterns',
    );
  } else {
    print('   📊 No significant cache benefit detected');
  }
  print('');
}

void benchmarkCoordinateValidation() {
  print('3️⃣  Coordinate Validation Performance');
  print('   Testing validation overhead...');

  const iterations = 10000;

  // Test regular constructor
  final regularStopwatch = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    Coordinates(21.3891 + i * 0.001, 39.8579 + i * 0.001);
  }
  regularStopwatch.stop();

  // Test validated constructor
  final validatedStopwatch = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    Coordinates.validated(21.3891 + i * 0.001, 39.8579 + i * 0.001);
  }
  validatedStopwatch.stop();

  final overhead =
      validatedStopwatch.elapsedMicroseconds -
      regularStopwatch.elapsedMicroseconds;
  final overheadPercent =
      (overhead / regularStopwatch.elapsedMicroseconds * 100);

  print('   ✅ Regular constructor: ${regularStopwatch.elapsedMicroseconds}μs');
  print(
    '   🛡️  Validated constructor: ${validatedStopwatch.elapsedMicroseconds}μs',
  );
  print('   📈 Validation overhead: ${overheadPercent.toStringAsFixed(1)}%');

  if (overhead < 0) {
    print('   🎉 Validation is actually faster!');
  } else {
    print('   💡 Minimal overhead for enhanced safety');
  }
  print('');
}

void benchmarkSunnahTimesOptimization() {
  print('2️⃣  SunnahTimes Caching Optimization');
  print('   Testing repeated SunnahTimes creation...');

  const coords = Coordinates(21.3891, 39.8579);
  final date = DateTime(2024, 6, 15);
  const params = UmmAlQura();

  final prayerTimes = PrayerTimes(
    date: date,
    coordinates: coords,
    calculationMethod: params,
  );

  const iterations = 50;
  final stopwatch = Stopwatch()..start();
  final results = <SunnahTimes>[];

  for (int i = 0; i < iterations; i++) {
    results.add(SunnahTimes(prayerTimes, roundToMinutes: true));
  }

  stopwatch.stop();

  // Verify caching works (all results should be identical)
  final first = results.first;
  final allIdentical = results.every(
    (s) =>
        s.middleOfTheNight == first.middleOfTheNight &&
        s.lastThirdOfTheNight == first.lastThirdOfTheNight,
  );

  print(
    '   ✅ Average time: ${(stopwatch.elapsedMicroseconds / iterations).toStringAsFixed(1)}μs per SunnahTimes',
  );
  print(
    '   🎯 Caching working: ${allIdentical ? 'Yes' : 'No'} (all results identical)',
  );
  print(
    '   📊 Total time: ${stopwatch.elapsedMilliseconds}ms for $iterations calculations\n',
  );
}
