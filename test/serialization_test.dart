import 'package:adhan_dart/adhan_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CalculationMethod Serialization', () {
    test('toJson and fromJson preserve values', () {
      final original = CalculationMethod.muslimWorldLeague;
      final json = original.toJson();
      final restored = CalculationMethod.fromJson(json);

      expect(restored.fajrAngle, original.fajrAngle);
      expect(restored.ishaAngle, original.ishaAngle);
      expect(restored.ishaInterval, original.ishaInterval);
      expect(restored.maghribAngle, original.maghribAngle);
      expect(restored.madhab, original.madhab);
      expect(restored.highLatitudeRule, original.highLatitudeRule);
      expect(restored.adjustments, original.adjustments);
      expect(restored.methodAdjustments, original.methodAdjustments);
      expect(restored.polarCircleResolution, original.polarCircleResolution);
      expect(restored.rounding, original.rounding);
      expect(restored.shafaq, original.shafaq);
    });

    test('fromJson returns exact preset constant for known methods', () {
      // Test that fromJson returns the identical static constant
      final presets = [
        CalculationMethod.muslimWorldLeague,
        CalculationMethod.egyptian,
        CalculationMethod.karachi,
        CalculationMethod.ummAlQura,
        CalculationMethod.dubai,
        CalculationMethod.moonsightingCommittee,
        CalculationMethod.northAmerica,
        CalculationMethod.kuwait,
        CalculationMethod.qatar,
        CalculationMethod.singapore,
        CalculationMethod.tehran,
        CalculationMethod.turkiye,
        CalculationMethod.morocco,
        CalculationMethod.other,
      ];

      for (final preset in presets) {
        final json = preset.toJson();
        final restored = CalculationMethod.fromJson(json);
        expect(
          identical(restored, preset),
          isTrue,
          reason:
              'fromJson should return identical instance for ${preset.runtimeType}',
        );
      }
    });

    test('toJson and fromJson with CustomCalculationMethod', () {
      final custom = CustomCalculationMethod(
        fajrAngle: 18.0,
        ishaAngle: 17.0,
        ishaInterval: 20,
        maghribAngle: 4.0,
        madhab: Madhab.hanafi,
        highLatitudeRule: HighLatitudeRule.seventhOfTheNight,
        adjustments: {Prayer.fajr: 10, Prayer.isha: -5},
        methodAdjustments: {Prayer.dhuhr: 5},
        polarCircleResolution: PolarCircleResolution.aqrabYaum,
        rounding: Rounding.up,
        shafaq: Shafaq.ahmer,
      );

      final json = custom.toJson();
      final restored = CalculationMethod.fromJson(json);

      expect(restored.fajrAngle, custom.fajrAngle);
      expect(restored.ishaAngle, custom.ishaAngle);
      expect(restored.ishaInterval, custom.ishaInterval);
      expect(restored.maghribAngle, custom.maghribAngle);
      expect(restored.madhab, custom.madhab);
      expect(restored.highLatitudeRule, custom.highLatitudeRule);
      expect(restored.adjustments, custom.adjustments);
      expect(restored.methodAdjustments, custom.methodAdjustments);
      expect(restored.polarCircleResolution, custom.polarCircleResolution);
      expect(restored.rounding, custom.rounding);
      expect(restored.shafaq, custom.shafaq);
    });

    test('default polarCircleResolution is unresolved', () {
      expect(
        CalculationMethod.muslimWorldLeague.polarCircleResolution,
        PolarCircleResolution.unresolved,
      );
      expect(
        CalculationMethod.moonsightingCommittee.polarCircleResolution,
        PolarCircleResolution.unresolved,
      );
    });

    test('copyWith preserves preset subclass identity', () {
      final adjusted = CalculationMethod.moonsightingCommittee.copyWith(
        madhab: Madhab.hanafi,
      );

      expect(adjusted, isA<MoonsightingCommittee>());
      expect(adjusted.madhab, Madhab.hanafi);
      expect(adjusted.fajrAngle, CalculationMethod.moonsightingCommittee.fajrAngle);
    });

    test('fromJson with preset name and custom adjustments restores overrides', () {
      final json = {
        'method': 'MoonsightingCommittee',
        'fajrAngle': 18.0,
        'ishaAngle': 18.0,
        'ishaInterval': null,
        'maghribAngle': null,
        'madhab': Madhab.hanafi.name,
        'highLatitudeRule': HighLatitudeRule.middleOfTheNight.name,
        'adjustments': {
          Prayer.fajr.name: 5,
          Prayer.sunrise.name: 0,
          Prayer.dhuhr.name: 0,
          Prayer.asr.name: 0,
          Prayer.maghrib.name: 0,
          Prayer.isha.name: -3,
        },
        'methodAdjustments': {
          Prayer.fajr.name: 0,
          Prayer.sunrise.name: 0,
          Prayer.dhuhr.name: 5,
          Prayer.asr.name: 0,
          Prayer.maghrib.name: 3,
          Prayer.isha.name: 0,
        },
        'polarCircleResolution': PolarCircleResolution.aqrabBalad.name,
        'rounding': Rounding.nearest.name,
        'shafaq': Shafaq.general.name,
      };

      final restored = CalculationMethod.fromJson(json);

      expect(restored, isA<MoonsightingCommittee>());
      expect(restored.madhab, Madhab.hanafi);
      expect(restored.adjustments[Prayer.fajr], 5);
      expect(restored.adjustments[Prayer.isha], -3);
      expect(
        restored.polarCircleResolution,
        PolarCircleResolution.aqrabBalad,
      );
    });

    test('copyWith clears ishaInterval and maghribAngle', () {
      final cleared = CalculationMethod.ummAlQura.copyWith(
        ishaInterval: null,
        maghribAngle: null,
      );

      expect(cleared.ishaInterval, isNull);
      expect(cleared.maghribAngle, isNull);
      expect(cleared, isA<UmmAlQura>());

      final tehranCleared = CalculationMethod.tehran.copyWith(
        maghribAngle: null,
      );
      expect(tehranCleared.maghribAngle, isNull);
      expect(tehranCleared, isA<Tehran>());
    });

    test('fromJson merges partial adjustments onto preset defaults', () {
      final json = {
        'method': 'MuslimWorldLeague',
        'adjustments': {Prayer.fajr.name: 7},
        'methodAdjustments': {Prayer.dhuhr.name: 9},
      };

      final restored = CalculationMethod.fromJson(json);
      final preset = CalculationMethod.muslimWorldLeague;

      expect(restored, isA<MuslimWorldLeague>());
      expect(restored.adjustments[Prayer.fajr], 7);
      expect(restored.adjustments[Prayer.sunrise], preset.adjustments[Prayer.sunrise]);
      expect(restored.methodAdjustments[Prayer.dhuhr], 9);
      expect(
        restored.methodAdjustments[Prayer.fajr],
        preset.methodAdjustments[Prayer.fajr],
      );
    });
  });

  group('PrayerTimes copyWith', () {
    test('estimatedPrayers override is unmodifiable', () {
      final pt = PrayerTimes(
        coordinates: Coordinates(35.775, -78.6336),
        date: DateTime(2015, 12, 1),
        calculationMethod: CalculationMethod.muslimWorldLeague,
      );

      final copy = pt.copyWith(estimatedPrayers: {Prayer.fajr});

      expect(copy.estimatedPrayers, {Prayer.fajr});
      expect(
        () => copy.estimatedPrayers.add(Prayer.isha),
        throwsUnsupportedError,
      );
    });
  });
}
