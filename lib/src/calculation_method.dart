import 'package:adhan_dart/src/high_latitude_rule.dart';
import 'package:adhan_dart/src/madhab.dart';
import 'package:adhan_dart/src/polar_circle_resolution.dart';
import 'package:adhan_dart/src/prayer.dart';
import 'package:adhan_dart/src/rounding.dart';
import 'package:adhan_dart/src/shafaq.dart';
import 'package:equatable/equatable.dart';

bool _prayerIntMapsEqual(Map<Prayer, int> a, Map<Prayer, int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

/// Sentinel for [CalculationMethod.copyWith] to distinguish "omit" from "clear".
const Object _copyWithUnset = Object();

Map<Prayer, int> _mergePrayerIntMaps(
  Map<Prayer, int> defaults,
  Map<Prayer, int> overrides,
) {
  return {...defaults, ...overrides};
}

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
    this.polarCircleResolution = PolarCircleResolution.unresolved,
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

  /// Creates a copy of this CalculationMethod with the given fields replaced.
  ///
  /// Preserves the runtime type: preset subclasses stay the same subclass
  /// (e.g. [MoonsightingCommittee.copyWith] remains [MoonsightingCommittee]).
  ///
  /// Pass `null` for [ishaInterval] or [maghribAngle] to clear those values.
  CalculationMethod copyWith({
    double? fajrAngle,
    double? ishaAngle,
    Object? ishaInterval = _copyWithUnset,
    Object? maghribAngle = _copyWithUnset,
    Madhab? madhab,
    HighLatitudeRule? highLatitudeRule,
    Map<Prayer, int>? adjustments,
    Map<Prayer, int>? methodAdjustments,
    PolarCircleResolution? polarCircleResolution,
    Rounding? rounding,
    Shafaq? shafaq,
  }) {
    final nextFajr = fajrAngle ?? this.fajrAngle;
    final nextIsha = ishaAngle ?? this.ishaAngle;
    final nextIshaInterval = identical(ishaInterval, _copyWithUnset)
        ? this.ishaInterval
        : ishaInterval as int?;
    final nextMaghribAngle = identical(maghribAngle, _copyWithUnset)
        ? this.maghribAngle
        : maghribAngle as double?;
    final nextMadhab = madhab ?? this.madhab;
    final nextHighLatitudeRule = highLatitudeRule ?? this.highLatitudeRule;
    final nextAdjustments = adjustments ?? this.adjustments;
    final nextMethodAdjustments =
        methodAdjustments ?? this.methodAdjustments;
    final nextPolarCircleResolution =
        polarCircleResolution ?? this.polarCircleResolution;
    final nextRounding = rounding ?? this.rounding;
    final nextShafaq = shafaq ?? this.shafaq;

    if (nextFajr == this.fajrAngle &&
        nextIsha == this.ishaAngle &&
        nextIshaInterval == this.ishaInterval &&
        nextMaghribAngle == this.maghribAngle &&
        nextMadhab == this.madhab &&
        nextHighLatitudeRule == this.highLatitudeRule &&
        _prayerIntMapsEqual(nextAdjustments, this.adjustments) &&
        _prayerIntMapsEqual(nextMethodAdjustments, this.methodAdjustments) &&
        nextPolarCircleResolution == this.polarCircleResolution &&
        nextRounding == this.rounding &&
        nextShafaq == this.shafaq) {
      return this;
    }

    return switch (this) {
      MuslimWorldLeague() => MuslimWorldLeague(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Egyptian() => Egyptian(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Karachi() => Karachi(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      UmmAlQura() => UmmAlQura(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Dubai() => Dubai(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      MoonsightingCommittee() => MoonsightingCommittee(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      NorthAmerica() => NorthAmerica(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Kuwait() => Kuwait(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Qatar() => Qatar(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Singapore() => Singapore(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Tehran() => Tehran(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Turkiye() => Turkiye(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      Morocco() => Morocco(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      OtherCalculationMethod() => OtherCalculationMethod(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
      CustomCalculationMethod() => CustomCalculationMethod(
        fajrAngle: nextFajr,
        ishaAngle: nextIsha,
        ishaInterval: nextIshaInterval,
        maghribAngle: nextMaghribAngle,
        madhab: nextMadhab,
        highLatitudeRule: nextHighLatitudeRule,
        adjustments: nextAdjustments,
        methodAdjustments: nextMethodAdjustments,
        polarCircleResolution: nextPolarCircleResolution,
        rounding: nextRounding,
        shafaq: nextShafaq,
      ),
    };
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

    if (methodName != null && _presetMethods.containsKey(methodName)) {
      final preset = _presetMethods[methodName]!;
      final adjustmentsOverride = json.containsKey('adjustments')
          ? (json['adjustments'] as Map<String, dynamic>).map(
              (key, value) =>
                  MapEntry(Prayer.values.byName(key), value as int),
            )
          : null;
      final methodAdjustmentsOverride = json.containsKey('methodAdjustments')
          ? (json['methodAdjustments'] as Map<String, dynamic>).map(
              (key, value) =>
                  MapEntry(Prayer.values.byName(key), value as int),
            )
          : null;

      return preset.copyWith(
        fajrAngle: json.containsKey('fajrAngle')
            ? (json['fajrAngle'] as num).toDouble()
            : null,
        ishaAngle: json.containsKey('ishaAngle')
            ? (json['ishaAngle'] as num).toDouble()
            : null,
        ishaInterval: json.containsKey('ishaInterval')
            ? json['ishaInterval'] as int?
            : _copyWithUnset,
        maghribAngle: json.containsKey('maghribAngle')
            ? (json['maghribAngle'] as num?)?.toDouble()
            : _copyWithUnset,
        madhab: json.containsKey('madhab')
            ? Madhab.values.byName(json['madhab'] as String)
            : null,
        highLatitudeRule: json.containsKey('highLatitudeRule')
            ? HighLatitudeRule.values.byName(json['highLatitudeRule'] as String)
            : null,
        adjustments: adjustmentsOverride == null
            ? null
            : _mergePrayerIntMaps(preset.adjustments, adjustmentsOverride),
        methodAdjustments: methodAdjustmentsOverride == null
            ? null
            : _mergePrayerIntMaps(
                preset.methodAdjustments,
                methodAdjustmentsOverride,
              ),
        polarCircleResolution: json.containsKey('polarCircleResolution')
            ? PolarCircleResolution.values.byName(
                json['polarCircleResolution'] as String,
              )
            : null,
        rounding: json.containsKey('rounding')
            ? Rounding.values.byName(json['rounding'] as String)
            : null,
        shafaq: json.containsKey('shafaq')
            ? Shafaq.values.byName(json['shafaq'] as String)
            : null,
      );
    }

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

/// Placeholder for user-defined methods not covered by presets.
///
/// Default [fajrAngle] and [ishaAngle] are 0. Set valid angles via [copyWith]
/// before constructing [PrayerTimes].
class OtherCalculationMethod extends CalculationMethod {
  const OtherCalculationMethod({
    super.fajrAngle = 0,
    super.ishaAngle = 0,
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

class MuslimWorldLeague extends CalculationMethod {
  const MuslimWorldLeague({
    super.fajrAngle = 18.0,
    super.ishaAngle = 17.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 1,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class Egyptian extends CalculationMethod {
  const Egyptian({
    super.fajrAngle = 19.5,
    super.ishaAngle = 17.5,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 1,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class Karachi extends CalculationMethod {
  const Karachi({
    super.fajrAngle = 18.0,
    super.ishaAngle = 18.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 1,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class UmmAlQura extends CalculationMethod {
  const UmmAlQura({
    super.fajrAngle = 18.5,
    super.ishaAngle = 0.0,
    super.ishaInterval = 90,
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

class Dubai extends CalculationMethod {
  const Dubai({
    super.fajrAngle = 18.2,
    super.ishaAngle = 18.2,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: -3,
      Prayer.dhuhr: 3,
      Prayer.asr: 3,
      Prayer.maghrib: 3,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class MoonsightingCommittee extends CalculationMethod {
  const MoonsightingCommittee({
    super.fajrAngle = 18.0,
    super.ishaAngle = 18.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 5,
      Prayer.asr: 0,
      Prayer.maghrib: 3,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class NorthAmerica extends CalculationMethod {
  const NorthAmerica({
    super.fajrAngle = 15.0,
    super.ishaAngle = 15.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 1,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class Kuwait extends CalculationMethod {
  const Kuwait({
    super.fajrAngle = 18.0,
    super.ishaAngle = 17.5,
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

class Qatar extends CalculationMethod {
  const Qatar({
    super.fajrAngle = 18.0,
    super.ishaAngle = 0.0,
    super.ishaInterval = 90,
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

class Singapore extends CalculationMethod {
  const Singapore({
    super.fajrAngle = 20.0,
    super.ishaAngle = 18.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: 0,
      Prayer.dhuhr: 1,
      Prayer.asr: 0,
      Prayer.maghrib: 0,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding = Rounding.up,
    super.shafaq,
  });
}

class Tehran extends CalculationMethod {
  const Tehran({
    super.fajrAngle = 17.7,
    super.ishaAngle = 14.0,
    super.ishaInterval,
    super.maghribAngle = 4.5,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments,
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class Turkiye extends CalculationMethod {
  const Turkiye({
    super.fajrAngle = 18.0,
    super.ishaAngle = 17.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: -7,
      Prayer.dhuhr: 5,
      Prayer.asr: 4,
      Prayer.maghrib: 7,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
}

class Morocco extends CalculationMethod {
  const Morocco({
    super.fajrAngle = 19.0,
    super.ishaAngle = 17.0,
    super.ishaInterval,
    super.maghribAngle,
    super.madhab,
    super.highLatitudeRule,
    super.adjustments,
    super.methodAdjustments = const {
      Prayer.fajr: 0,
      Prayer.sunrise: -3,
      Prayer.dhuhr: 5,
      Prayer.asr: 0,
      Prayer.maghrib: 5,
      Prayer.isha: 0,
    },
    super.polarCircleResolution,
    super.rounding,
    super.shafaq,
  });
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
