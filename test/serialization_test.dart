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
  });
}
