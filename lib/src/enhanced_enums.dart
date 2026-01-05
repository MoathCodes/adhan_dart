/// Enhanced enums with better documentation and utility methods for improved DX
library enhanced_enums;

import 'package:adhan_dart/adhan_dart.dart';

/// Extension on CalculationMethod enum for better developer experience
extension CalculationMethodExtensions on CalculationMethod {
  /// Brief description of the method's characteristics
  String get description {
    switch (this) {
      case CalculationMethod.muslimWorldLeague:
        return 'Widely accepted standard, moderate timings';
      case CalculationMethod.egyptian:
        return 'Conservative Fajr, moderate Isha timings';
      case CalculationMethod.karachi:
        return 'Early Fajr, late Isha (18° both)';
      case CalculationMethod.ummAlQura:
        return 'Used in Saudi Arabia, 90min Isha offset';
      case CalculationMethod.dubai:
        return 'UAE standard with minor adjustments';
      case CalculationMethod.moonsightingCommittee:
        return 'Conservative, astronomical-based';
      case CalculationMethod.northAmerica:
        return 'ISNA standard for North America';
      case CalculationMethod.kuwait:
        return 'Kuwait standard method';
      case CalculationMethod.qatar:
        return 'Qatar standard method';
      case CalculationMethod.singapore:
        return 'Southeast Asia standard';
      case CalculationMethod.tehran:
        return 'Iran standard, 17.7° Fajr, 14° Isha';
      case CalculationMethod.turkiye:
        return 'Turkey standard method';
      case CalculationMethod.morocco:
        return 'Morocco standard method';
      case CalculationMethod.other:
        return 'Customizable parameters';
    }
  }

  /// Human-readable name for the calculation method
  String get displayName {
    switch (this) {
      case CalculationMethod.muslimWorldLeague:
        return 'Muslim World League';
      case CalculationMethod.egyptian:
        return 'Egyptian General Authority of Survey';
      case CalculationMethod.karachi:
        return 'Karachi (University of Islamic Sciences)';
      case CalculationMethod.ummAlQura:
        return 'Umm Al-Qura (Makkah)';
      case CalculationMethod.dubai:
        return 'Dubai';
      case CalculationMethod.moonsightingCommittee:
        return 'Moonsighting Committee Worldwide';
      case CalculationMethod.northAmerica:
        return 'North America (ISNA)';
      case CalculationMethod.kuwait:
        return 'Kuwait';
      case CalculationMethod.qatar:
        return 'Qatar';
      case CalculationMethod.singapore:
        return 'Singapore';
      case CalculationMethod.tehran:
        return 'Tehran (Institute of Geophysics)';
      case CalculationMethod.turkiye:
        return 'Turkey (Diyanet)';
      case CalculationMethod.morocco:
        return 'Morocco';
      case CalculationMethod.other:
        return 'Custom Method';
    }
  }

  /// Region where this method is commonly used
  String get region {
    switch (this) {
      case CalculationMethod.muslimWorldLeague:
        return 'Global (default)';
      case CalculationMethod.egyptian:
        return 'Egypt, Syria, Iraq, Lebanon, Malaysia, Brunei';
      case CalculationMethod.karachi:
        return 'Pakistan, Afghanistan, Bangladesh, India';
      case CalculationMethod.ummAlQura:
        return 'Saudi Arabia';
      case CalculationMethod.dubai:
        return 'UAE';
      case CalculationMethod.moonsightingCommittee:
        return 'Global (conservative estimates)';
      case CalculationMethod.northAmerica:
        return 'North America';
      case CalculationMethod.kuwait:
        return 'Kuwait';
      case CalculationMethod.qatar:
        return 'Qatar';
      case CalculationMethod.singapore:
        return 'Singapore, Indonesia, Malaysia';
      case CalculationMethod.tehran:
        return 'Iran, some Shia communities';
      case CalculationMethod.turkiye:
        return 'Turkey';
      case CalculationMethod.morocco:
        return 'Morocco';
      case CalculationMethod.other:
        return 'Custom configuration';
    }
  }

  /// Gets methods commonly used in a specific region
  static List<CalculationMethod> forRegion(String region) {
    switch (region.toLowerCase()) {
      case 'middle east':
      case 'arab':
        return [
          CalculationMethod.ummAlQura,
          CalculationMethod.dubai,
          CalculationMethod.kuwait,
          CalculationMethod.qatar,
          CalculationMethod.egyptian,
        ];
      case 'south asia':
      case 'india':
      case 'pakistan':
        return [
          CalculationMethod.karachi,
          CalculationMethod.muslimWorldLeague,
        ];
      case 'southeast asia':
      case 'malaysia':
      case 'indonesia':
        return [
          CalculationMethod.singapore,
          CalculationMethod.egyptian,
        ];
      case 'north america':
      case 'usa':
      case 'canada':
        return [
          CalculationMethod.northAmerica,
          CalculationMethod.moonsightingCommittee,
        ];
      case 'europe':
        return [
          CalculationMethod.muslimWorldLeague,
          CalculationMethod.moonsightingCommittee,
        ];
      default:
        return [CalculationMethod.muslimWorldLeague];
    }
  }
}

/// Extension on HighLatitudeRule for better developer experience
extension HighLatitudeRuleExtensions on HighLatitudeRule {
  /// Description of how this rule works
  String get description {
    switch (this) {
      case HighLatitudeRule.middleOfTheNight:
        return 'Fajr and Isha are set to the middle of the night duration';
      case HighLatitudeRule.seventhOfTheNight:
        return 'Fajr and Isha are set to 1/7th of the night duration from sunset/sunrise';
      case HighLatitudeRule.twilightAngle:
        return 'Use the twilight angle to calculate Fajr and Isha';
    }
  }

  /// Human-readable name for the rule
  String get displayName {
    switch (this) {
      case HighLatitudeRule.middleOfTheNight:
        return 'Middle of the Night';
      case HighLatitudeRule.seventhOfTheNight:
        return 'Seventh of the Night';
      case HighLatitudeRule.twilightAngle:
        return 'Twilight Angle';
    }
  }

  /// When to use this rule
  String get usageGuidance {
    switch (this) {
      case HighLatitudeRule.middleOfTheNight:
        return 'Recommended for extreme latitudes where twilight never ends';
      case HighLatitudeRule.seventhOfTheNight:
        return 'Traditional method, good balance for high latitudes';
      case HighLatitudeRule.twilightAngle:
        return 'Most accurate when twilight angles are still meaningful';
    }
  }
}

/// Extension on Prayer enum to provide better developer experience
extension PrayerExtensions on Prayer {
  /// Gets all obligatory prayers in order
  static List<Prayer> get obligatoryPrayers => [
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      ];

  /// Description of the prayer's significance
  String get description {
    switch (this) {
      case Prayer.fajr:
        return 'Dawn prayer, performed before sunrise';
      case Prayer.sunrise:
        return 'Astronomical sunrise (not a prayer)';
      case Prayer.dhuhr:
        return 'Midday prayer, performed after sun passes meridian';
      case Prayer.asr:
        return 'Afternoon prayer, performed in late afternoon';
      case Prayer.maghrib:
        return 'Sunset prayer, performed just after sunset';
      case Prayer.isha:
        return 'Night prayer, performed after twilight disappears';
      case Prayer.ishaBefore:
        return 'Previous day\'s Isha for night calculations';
      case Prayer.fajrAfter:
        return 'Next day\'s Fajr for night calculations';
    }
  }

  /// Human-readable name for the prayer
  String get displayName {
    switch (this) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      case Prayer.ishaBefore:
        return 'Previous Isha';
      case Prayer.fajrAfter:
        return 'Next Fajr';
    }
  }

  /// Whether this is one of the five obligatory prayers
  bool get isObligatory {
    switch (this) {
      case Prayer.fajr:
      case Prayer.dhuhr:
      case Prayer.asr:
      case Prayer.maghrib:
      case Prayer.isha:
        return true;
      case Prayer.sunrise:
      case Prayer.ishaBefore:
      case Prayer.fajrAfter:
        return false;
    }
  }
}
