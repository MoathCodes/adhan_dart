import 'package:adhan_dart/adhan_dart.dart';

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

/// Various calculation methods
class CalculationMethodParameters {
  // Dubai
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

  // Egyptian General Authority of Survey
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

  // University of Islamic Sciences, Karachi
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

  // Kuwait
  static CalculationParameters kuwait() {
    return const CalculationParameters(
        method: CalculationMethod.kuwait, fajrAngle: 18, ishaAngle: 17.5);
  }

  // Moonsighting Committee
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

  // Moroccan ministry of Habous and Islamic Affairs
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

  // Muslim World League
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

  // ISNA
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

  // Other
  static CalculationParameters other() {
    return const CalculationParameters(
        method: CalculationMethod.other, fajrAngle: 0, ishaAngle: 0);
  }

  // Qatar
  static CalculationParameters qatar() {
    return const CalculationParameters(
        method: CalculationMethod.qatar,
        fajrAngle: 18,
        ishaAngle: 0,
        ishaInterval: 90);
  }

  // Singapore
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

  // Institute of Geophysics, University of Tehran
  static CalculationParameters tehran() {
    CalculationParameters params = const CalculationParameters(
        method: CalculationMethod.tehran,
        fajrAngle: 17.7,
        ishaAngle: 14,
        ishaInterval: 0,
        maghribAngle: 4.5);
    return params;
  }

  // Dianet
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

  // Umm al-Qura University, Makkah
  static CalculationParameters ummAlQura() {
    return const CalculationParameters(
        method: CalculationMethod.ummAlQura,
        fajrAngle: 18.5,
        ishaAngle: 0,
        ishaInterval: 90);
  }
}
