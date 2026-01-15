import 'package:adhan_dart/src/coordinates.dart';

/// Used to handle prayer time calculations in high latitude regions
enum HighLatitudeRule {
  middleOfTheNight,
  seventhOfTheNight,
  twilightAngle;

  static HighLatitudeRule recommended(Coordinates coordinates) {
    if (coordinates.latitude > 48) {
      return HighLatitudeRule.seventhOfTheNight;
    } else {
      return HighLatitudeRule.middleOfTheNight;
    }
  }
}
