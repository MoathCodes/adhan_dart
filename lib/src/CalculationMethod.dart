import 'package:adhan_dart/adhan_dart.dart';

/// Enum holding all the available methods
enum CalculationMethod {
  dubai,
  egyptian,
  karachi,
  kuwait,
  moonsightingCommittee,
  morocco,
  muslimWorldLeague,
  northAmerica,
  other,
  qatar,
  singapore,
  tehran,
  turkiye,
  ummAlQura;
}

/// Class holding the calculation parameters for each method
class CalculationMethodParameters {
  /// Dubai
  ///
  /// Settings:
  /// - Fajr Angle: 18.2°
  /// - Isha Angle: 18.2°
  /// - Method Adjustments: Sunrise -3min, Dhuhr +3min, Asr +3min, Maghrib +3min
  static CalculationParameters dubai() {
    return const CalculationParameters(
      method: CalculationMethod.dubai,
      fajrAngle: 18.2,
      ishaAngle: 18.2,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: -3,
        Prayer.dhuhr: 3,
        Prayer.asr: 3,
        Prayer.maghrib: 3,
        Prayer.isha: 0,
      },
    );
  }

  /// Egyptian General Authority of Survey
  ///
  /// Settings:
  /// - Fajr Angle: 19.5°
  /// - Isha Angle: 17.5°
  /// - Method Adjustments: Dhuhr +1min
  static CalculationParameters egyptian() {
    return const CalculationParameters(
      method: CalculationMethod.egyptian,
      fajrAngle: 19.5,
      ishaAngle: 17.5,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: 0,
        Prayer.dhuhr: 1,
        Prayer.asr: 0,
        Prayer.maghrib: 0,
        Prayer.isha: 0,
      },
    );
  }

  /// University of Islamic Sciences, Karachi
  ///
  /// Settings:
  /// - Fajr Angle: 18°
  /// - Isha Angle: 18°
  /// - Method Adjustments: Dhuhr +1min
  static CalculationParameters karachi() {
    return const CalculationParameters(
      method: CalculationMethod.karachi,
      fajrAngle: 18,
      ishaAngle: 18,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: 0,
        Prayer.dhuhr: 1,
        Prayer.asr: 0,
        Prayer.maghrib: 0,
        Prayer.isha: 0,
      },
    );
  }

  /// Kuwait
  ///
  /// Settings:
  /// - Fajr Angle: 18°
  /// - Isha Angle: 17.5°
  static CalculationParameters kuwait() {
    return const CalculationParameters(
        method: CalculationMethod.kuwait, fajrAngle: 18, ishaAngle: 17.5);
  }

  /// Moonsighting Committee
  ///
  /// Settings:
  /// - Fajr Angle: 18°
  /// - Isha Angle: 18°
  /// - Method Adjustments: Dhuhr +5min, Maghrib +3min
  static CalculationParameters moonsightingCommittee() {
    return const CalculationParameters(
      method: CalculationMethod.moonsightingCommittee,
      fajrAngle: 18,
      ishaAngle: 18,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: 0,
        Prayer.dhuhr: 5,
        Prayer.asr: 0,
        Prayer.maghrib: 3,
        Prayer.isha: 0,
      },
    );
  }

  /// Morocco
  ///
  /// Settings:
  /// - Fajr Angle: 19°
  /// - Isha Angle: 17°
  /// - Method Adjustments: Sunrise -3min, Dhuhr +5min, Maghrib +5min
  static CalculationParameters morocco() {
    return const CalculationParameters(
      method: CalculationMethod.morocco,
      fajrAngle: 19,
      ishaAngle: 17,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: -3,
        Prayer.dhuhr: 5,
        Prayer.asr: 0,
        Prayer.maghrib: 5,
        Prayer.isha: 0,
      },
    );
  }

  /// Muslim World League
  ///
  /// Settings:
  /// - Fajr Angle: 18°
  /// - Isha Angle: 17°
  /// - Method Adjustments: Dhuhr +1min
  static CalculationParameters muslimWorldLeague() {
    return const CalculationParameters(
      method: CalculationMethod.muslimWorldLeague,
      fajrAngle: 18,
      ishaAngle: 17,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: 0,
        Prayer.dhuhr: 1,
        Prayer.asr: 0,
        Prayer.maghrib: 0,
        Prayer.isha: 0,
      },
    );
  }

  /// North America (ISNA)
  ///
  /// Settings:
  /// - Fajr Angle: 15°
  /// - Isha Angle: 15°
  /// - Method Adjustments: Dhuhr +1min
  static CalculationParameters northAmerica() {
    return const CalculationParameters(
      method: CalculationMethod.northAmerica,
      fajrAngle: 15,
      ishaAngle: 15,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: 0,
        Prayer.dhuhr: 1,
        Prayer.asr: 0,
        Prayer.maghrib: 0,
        Prayer.isha: 0,
      },
    );
  }

  /// Other (Custom)
  ///
  /// Settings:
  /// - Fajr Angle: 0°
  /// - Isha Angle: 0°
  static CalculationParameters other() {
    return const CalculationParameters(
        method: CalculationMethod.other, fajrAngle: 0, ishaAngle: 0);
  }

  /// Qatar
  ///
  /// Settings:
  /// - Fajr Angle: 18°
  /// - Isha Interval: 90 minutes after Maghrib
  static CalculationParameters qatar() {
    return const CalculationParameters(
        method: CalculationMethod.qatar,
        fajrAngle: 18,
        ishaAngle: 0,
        ishaInterval: 90);
  }

  /// Singapore
  ///
  /// Settings:
  /// - Fajr Angle: 20°
  /// - Isha Angle: 18°
  /// - Method Adjustments: Dhuhr +1min
  static CalculationParameters singapore() {
    return const CalculationParameters(
      method: CalculationMethod.singapore,
      fajrAngle: 20,
      ishaAngle: 18,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: 0,
        Prayer.dhuhr: 1,
        Prayer.asr: 0,
        Prayer.maghrib: 0,
        Prayer.isha: 0,
      },
    );
  }

  /// Tehran
  ///
  /// Settings:
  /// - Fajr Angle: 17.7°
  /// - Isha Angle: 14°
  /// - Maghrib Angle: 4.5°
  /// - Isha Interval: 0 (not used)
  static CalculationParameters tehran() {
    CalculationParameters params = const CalculationParameters(
        method: CalculationMethod.tehran,
        fajrAngle: 17.7,
        ishaAngle: 14,
        ishaInterval: 0,
        maghribAngle: 4.5);
    return params;
  }

  /// Turkey (Diyanet)
  ///
  /// Settings:
  /// - Fajr Angle: 18°
  /// - Isha Angle: 17°
  /// - Method Adjustments: Sunrise -7min, Dhuhr +5min, Asr +4min, Maghrib +7min
  static CalculationParameters turkiye() {
    return const CalculationParameters(
      method: CalculationMethod.turkiye,
      fajrAngle: 18,
      ishaAngle: 17,
      methodAdjustments: {
        Prayer.fajr: 0,
        Prayer.sunrise: -7,
        Prayer.dhuhr: 5,
        Prayer.asr: 4,
        Prayer.maghrib: 7,
        Prayer.isha: 0,
      },
    );
  }

  /// Umm al-Qura University, Makkah
  ///
  /// Settings:
  /// - Fajr Angle: 18.5°
  /// - Isha Interval: 90 minutes after Maghrib
  ///
  /// Note: Add +30 minute custom adjustment for Isha during Ramadan
  static CalculationParameters ummAlQura() {
    return const CalculationParameters(
        method: CalculationMethod.ummAlQura,
        fajrAngle: 18.5,
        ishaAngle: 0,
        ishaInterval: 90);
  }
}
