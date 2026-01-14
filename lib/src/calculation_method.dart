import 'package:adhan_dart/src/high_latitude_rule.dart';
import 'package:adhan_dart/src/madhab.dart';
import 'package:adhan_dart/src/polar_circle_resolution.dart';
import 'package:adhan_dart/src/prayer.dart';
import 'package:adhan_dart/src/rounding.dart';
import 'package:adhan_dart/src/shafaq.dart';
import 'package:equatable/equatable.dart';

/// Sealed class representing a calculation method for prayer times.
///
/// This replaces the old Enum + Parameters approach.
/// Use specific subclasses like [MuslimWorldLeague] or [Karachi] for presets,
/// or [CustomCalculationMethod] for custom parameters.
sealed class CalculationMethod with EquatableMixin {
  final double fajrAngle;
  final double ishaAngle;
  final int? ishaInterval;
  final double? maghribAngle;
  final Madhab madhab;
  final HighLatitudeRule highLatitudeRule;
  final Map<Prayer, int> adjustments;
  final Map<Prayer, int> methodAdjustments;
  final PolarCircleResolution polarCircleResolution;
  final Rounding rounding;
  final Shafaq shafaq;

  static const MuslimWorldLeague muslimWorldLeague = MuslimWorldLeague();
  static const Egyptian egyptian = Egyptian();
  static const Karachi karachi = Karachi();
  static const UmmAlQura ummAlQura = UmmAlQura();
  static const Dubai dubai = Dubai();
  static const MoonsightingCommittee moonsightingCommittee =
      MoonsightingCommittee();
  static const NorthAmerica northAmerica = NorthAmerica();
  static const Kuwait kuwait = Kuwait();
  static const Qatar qatar = Qatar();
  static const Singapore singapore = Singapore();
  static const Tehran tehran = Tehran();
  static const Turkiye turkiye = Turkiye();
  static const Morocco morocco = Morocco();
  static const OtherCalculationMethod other = OtherCalculationMethod();

  /// A list of all available preset calculation methods.
  static const List<CalculationMethod> values = [
    muslimWorldLeague,
    egyptian,
    karachi,
    ummAlQura,
    dubai,
    moonsightingCommittee,
    northAmerica,
    kuwait,
    qatar,
    singapore,
    tehran,
    turkiye,
    morocco,
    other,
  ];

  const CalculationMethod({
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
    this.polarCircleResolution = PolarCircleResolution.aqrabBalad,
    this.rounding = Rounding.nearest,
    this.shafaq = Shafaq.general,
  });

  @override
  List<Object?> get props => [
    fajrAngle,
    ishaAngle,
    ishaInterval,
    maghribAngle,
    madhab,
    highLatitudeRule,
    adjustments,
    methodAdjustments,
    polarCircleResolution,
    rounding,
    shafaq,
  ];

  /// Creates a copy of this CalculationMethod with the given fields replaced with the new values.
  ///
  /// Returns a [CustomCalculationMethod] preserving the original values where not overridden.
  CalculationMethod copyWith({
    double? fajrAngle,
    double? ishaAngle,
    int? ishaInterval,
    double? maghribAngle,
    Madhab? madhab,
    HighLatitudeRule? highLatitudeRule,
    Map<Prayer, int>? adjustments,
    Map<Prayer, int>? methodAdjustments,
    PolarCircleResolution? polarCircleResolution,
    Rounding? rounding,
    Shafaq? shafaq,
  }) {
    return CustomCalculationMethod(
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle ?? this.ishaAngle,
      ishaInterval: ishaInterval ?? this.ishaInterval,
      maghribAngle: maghribAngle ?? this.maghribAngle,
      madhab: madhab ?? this.madhab,
      highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
      adjustments: adjustments ?? this.adjustments,
      methodAdjustments: methodAdjustments ?? this.methodAdjustments,
      polarCircleResolution:
          polarCircleResolution ?? this.polarCircleResolution,
      rounding: rounding ?? this.rounding,
      shafaq: shafaq ?? this.shafaq,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'method': runtimeType.toString(),
      'fajrAngle': fajrAngle,
      'ishaAngle': ishaAngle,
      'ishaInterval': ishaInterval,
      'maghribAngle': maghribAngle,
      'madhab': madhab.name,
      'highLatitudeRule': highLatitudeRule.name,
      'adjustments': adjustments.map((key, value) => MapEntry(key.name, value)),
      'methodAdjustments': methodAdjustments.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'polarCircleResolution': polarCircleResolution.name,
      'rounding': rounding.name,
      'shafaq': shafaq.name,
    };
  }

  static const _presetMethods = <String, CalculationMethod>{
    'MuslimWorldLeague': muslimWorldLeague,
    'Egyptian': egyptian,
    'Karachi': karachi,
    'UmmAlQura': ummAlQura,
    'Dubai': dubai,
    'MoonsightingCommittee': moonsightingCommittee,
    'NorthAmerica': northAmerica,
    'Kuwait': kuwait,
    'Qatar': qatar,
    'Singapore': singapore,
    'Tehran': tehran,
    'Turkiye': turkiye,
    'Morocco': morocco,
    'OtherCalculationMethod': other,
  };

  factory CalculationMethod.fromJson(Map<String, dynamic> json) {
    final methodName = json['method'] as String?;

    // Fast path: return preset if it's a known method
    if (methodName != null && _presetMethods.containsKey(methodName)) {
      return _presetMethods[methodName]!;
    }

    // Slow path: parse all fields for custom methods
    return CustomCalculationMethod(
      fajrAngle: (json['fajrAngle'] as num).toDouble(),
      ishaAngle: (json['ishaAngle'] as num).toDouble(),
      ishaInterval: json['ishaInterval'] as int?,
      maghribAngle: (json['maghribAngle'] as num?)?.toDouble(),
      madhab: Madhab.values.byName(json['madhab']),
      highLatitudeRule: HighLatitudeRule.values.byName(
        json['highLatitudeRule'],
      ),
      adjustments: (json['adjustments'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(Prayer.values.byName(key), value as int),
      ),
      methodAdjustments: (json['methodAdjustments'] as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(Prayer.values.byName(key), value as int),
          ),
      polarCircleResolution: PolarCircleResolution.values.byName(
        json['polarCircleResolution'],
      ),
      rounding: Rounding.values.byName(json['rounding']),
      shafaq: Shafaq.values.byName(json['shafaq']),
    );
  }
}

class OtherCalculationMethod extends CalculationMethod {
  const OtherCalculationMethod({super.fajrAngle = 0, super.ishaAngle = 0});
}

class MuslimWorldLeague extends CalculationMethod {
  const MuslimWorldLeague()
    : super(
        fajrAngle: 18.0,
        ishaAngle: 17.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: 0,
          Prayer.dhuhr: 1,
          Prayer.asr: 0,
          Prayer.maghrib: 0,
          Prayer.isha: 0,
        },
      );
}

class Egyptian extends CalculationMethod {
  const Egyptian()
    : super(
        fajrAngle: 19.5,
        ishaAngle: 17.5,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: 0,
          Prayer.dhuhr: 1,
          Prayer.asr: 0,
          Prayer.maghrib: 0,
          Prayer.isha: 0,
        },
      );
}

class Karachi extends CalculationMethod {
  const Karachi()
    : super(
        fajrAngle: 18.0,
        ishaAngle: 18.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: 0,
          Prayer.dhuhr: 1,
          Prayer.asr: 0,
          Prayer.maghrib: 0,
          Prayer.isha: 0,
        },
      );
}

class UmmAlQura extends CalculationMethod {
  const UmmAlQura() : super(fajrAngle: 18.5, ishaAngle: 0.0, ishaInterval: 90);
}

class Dubai extends CalculationMethod {
  const Dubai()
    : super(
        fajrAngle: 18.2,
        ishaAngle: 18.2,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: -3,
          Prayer.dhuhr: 3,
          Prayer.asr: 3,
          Prayer.maghrib: 3,
          Prayer.isha: 0,
        },
      );
}

class MoonsightingCommittee extends CalculationMethod {
  const MoonsightingCommittee()
    : super(
        fajrAngle: 18.0,
        ishaAngle: 18.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: 0,
          Prayer.dhuhr: 5,
          Prayer.asr: 0,
          Prayer.maghrib: 3,
          Prayer.isha: 0,
        },
      );
}

class NorthAmerica extends CalculationMethod {
  const NorthAmerica()
    : super(
        fajrAngle: 15.0,
        ishaAngle: 15.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: 0,
          Prayer.dhuhr: 1,
          Prayer.asr: 0,
          Prayer.maghrib: 0,
          Prayer.isha: 0,
        },
      );
}

class Kuwait extends CalculationMethod {
  const Kuwait() : super(fajrAngle: 18.0, ishaAngle: 17.5);
}

class Qatar extends CalculationMethod {
  const Qatar() : super(fajrAngle: 18.0, ishaAngle: 0.0, ishaInterval: 90);
}

class Singapore extends CalculationMethod {
  const Singapore()
    : super(
        fajrAngle: 20.0,
        ishaAngle: 18.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: 0,
          Prayer.dhuhr: 1,
          Prayer.asr: 0,
          Prayer.maghrib: 0,
          Prayer.isha: 0,
        },
        rounding: Rounding.up,
      );
}

class Tehran extends CalculationMethod {
  const Tehran() : super(fajrAngle: 17.7, ishaAngle: 14.0, maghribAngle: 4.5);
}

class Turkiye extends CalculationMethod {
  const Turkiye()
    : super(
        fajrAngle: 18.0,
        ishaAngle: 17.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: -7,
          Prayer.dhuhr: 5,
          Prayer.asr: 4,
          Prayer.maghrib: 7,
          Prayer.isha: 0,
        },
      );
}

class Morocco extends CalculationMethod {
  const Morocco()
    : super(
        fajrAngle: 19.0,
        ishaAngle: 17.0,
        methodAdjustments: const {
          Prayer.fajr: 0,
          Prayer.sunrise: -3,
          Prayer.dhuhr: 5,
          Prayer.asr: 0,
          Prayer.maghrib: 5,
          Prayer.isha: 0,
        },
      );
}

class CustomCalculationMethod extends CalculationMethod {
  const CustomCalculationMethod({
    required super.fajrAngle,
    required super.ishaAngle,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments,
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}
