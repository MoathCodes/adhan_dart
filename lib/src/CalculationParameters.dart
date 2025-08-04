import 'package:adhan_dart/adhan_dart.dart';
import 'package:meta/meta.dart';

/// Holds calculation parameters for prayer time calculations
///
/// Contains angles, intervals, adjustments, and other settings
/// that define how prayer times are calculated for different methods.
@immutable
class CalculationParameters {
  final CalculationMethod method;
  final double fajrAngle;
  final double ishaAngle;
  final int? ishaInterval;
  final double? maghribAngle;
  final Madhab madhab;
  final HighLatitudeRule highLatitudeRule;
  final Map<Prayer, int> adjustments;
  final Map<Prayer, int> methodAdjustments;

  const CalculationParameters({
    required this.method,
    required this.fajrAngle,
    required this.ishaAngle,
    this.ishaInterval,
    this.maghribAngle,
    this.madhab = Madhab.shafi,
    this.highLatitudeRule = HighLatitudeRule.middleOfTheNight,
    this.adjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 0,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
    this.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 0,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
  });

  CalculationParameters copyWith({
    CalculationMethod? method,
    double? fajrAngle,
    double? ishaAngle,
    int? ishaInterval,
    double? maghribAngle,
    Madhab? madhab,
    HighLatitudeRule? highLatitudeRule,
    Map<Prayer, int>? adjustments,
    Map<Prayer, int>? methodAdjustments,
  }) =>
      CalculationParameters(
        method: method ?? this.method,
        fajrAngle: fajrAngle ?? this.fajrAngle,
        ishaAngle: ishaAngle ?? this.ishaAngle,
        ishaInterval: ishaInterval ?? this.ishaInterval,
        maghribAngle: maghribAngle ?? this.maghribAngle,
        madhab: madhab ?? this.madhab,
        highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
        adjustments: adjustments ?? this.adjustments,
        methodAdjustments: methodAdjustments ?? this.methodAdjustments,
      );

  Map<Prayer, double> nightPortions() {
    switch (highLatitudeRule) {
      case HighLatitudeRule.middleOfTheNight:
        return {Prayer.fajr: 1 / 2, Prayer.isha: 1 / 2};
      case HighLatitudeRule.seventhOfTheNight:
        return {Prayer.fajr: 1 / 7, Prayer.isha: 1 / 7};
      case HighLatitudeRule.twilightAngle:
        return {Prayer.fajr: fajrAngle / 60, Prayer.isha: ishaAngle / 60};
    }
  }
}
