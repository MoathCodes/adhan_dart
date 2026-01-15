import 'package:adhan_dart/src/coordinates.dart';
import 'package:adhan_dart/src/solar_time.dart';
import 'package:adhan_dart/src/extensions.dart';

enum PolarCircleResolution { aqrabBalad, aqrabYaum, unresolved }

class PolarCircleResolvedValues {
  final DateTime date;
  final DateTime tomorrow;
  final Coordinates coordinates;
  final SolarTime solarTime;
  final SolarTime tomorrowSolarTime;

  PolarCircleResolvedValues({
    required this.date,
    required this.tomorrow,
    required this.coordinates,
    required this.solarTime,
    required this.tomorrowSolarTime,
  });
}

class PolarCircleResolver {
  static const double _latitudeVariationStep = 0.5;
  static const double _unsafeLatitude = 65.0;

  static bool _isValidSolarTime(SolarTime solarTime) {
    return !solarTime.sunrise.isNaN && !solarTime.sunset.isNaN;
  }

  static PolarCircleResolvedValues? _aqrabYaumResolver(
    Coordinates coordinates,
    DateTime date, {
    int daysAdded = 1,
    int direction = 1,
  }) {
    if (daysAdded > (365 / 2).ceil()) {
      return null;
    }

    final testDate = date.addDays(direction * daysAdded);
    final tomorrow = testDate.addDays(1);
    final solarTime = SolarTime(testDate, coordinates);
    final tomorrowSolarTime = SolarTime(tomorrow, coordinates);

    if (!_isValidSolarTime(solarTime) ||
        !_isValidSolarTime(tomorrowSolarTime)) {
      return _aqrabYaumResolver(
        coordinates,
        date,
        daysAdded: daysAdded + (direction > 0 ? 0 : 1),
        direction: -direction,
      );
    }

    return PolarCircleResolvedValues(
      date: date,
      tomorrow: date.addDays(1),
      coordinates: coordinates,
      solarTime: solarTime,
      tomorrowSolarTime: tomorrowSolarTime,
    );
  }

  static PolarCircleResolvedValues? _aqrabBaladResolver(
    Coordinates coordinates,
    DateTime date,
    double latitude,
  ) {
    final solarTime = SolarTime(
      date,
      Coordinates(latitude, coordinates.longitude),
    );
    final tomorrow = date.addDays(1);
    final tomorrowSolarTime = SolarTime(
      tomorrow,
      Coordinates(latitude, coordinates.longitude),
    );

    if (!_isValidSolarTime(solarTime) ||
        !_isValidSolarTime(tomorrowSolarTime)) {
      return latitude.abs() >= _unsafeLatitude
          ? _aqrabBaladResolver(
              coordinates,
              date,
              latitude - (latitude.sign * _latitudeVariationStep),
            )
          : null;
    }

    return PolarCircleResolvedValues(
      date: date,
      tomorrow: tomorrow,
      coordinates: Coordinates(latitude, coordinates.longitude),
      solarTime: solarTime,
      tomorrowSolarTime: tomorrowSolarTime,
    );
  }

  static PolarCircleResolvedValues resolve(
    PolarCircleResolution resolver,
    DateTime date,
    Coordinates coordinates,
  ) {
    final defaultReturn = PolarCircleResolvedValues(
      date: date,
      tomorrow: date.addDays(1),
      coordinates: coordinates,
      solarTime: SolarTime(date, coordinates),
      tomorrowSolarTime: SolarTime(date.addDays(1), coordinates),
    );

    switch (resolver) {
      case PolarCircleResolution.aqrabYaum:
        return _aqrabYaumResolver(coordinates, date) ?? defaultReturn;
      case PolarCircleResolution.aqrabBalad:
        return _aqrabBaladResolver(
              coordinates,
              date,
              coordinates.latitude -
                  (coordinates.latitude.sign * _latitudeVariationStep),
            ) ??
            defaultReturn;
      default:
        return defaultReturn;
    }
  }
}
