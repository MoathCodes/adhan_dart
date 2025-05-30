import 'dart:math';

import 'package:adhan_dart/src/Coordinates.dart';
import 'package:adhan_dart/src/MathUtils.dart';

class Qibla {
  static double qibla(coordinates) {
    Coordinates makkah = Coordinates(21.4225241, 39.8261818);

    // Equation from "Spherical Trigonometry For the use of colleges and schools" page 50
    double term1 =
        (sin(degreesToRadians(makkah.longitude) - degreesToRadians(coordinates.longitude)));
    double term2 =
        (cos(degreesToRadians(coordinates.latitude)) * tan(degreesToRadians(makkah.latitude)));
    double term3 = (sin(degreesToRadians(coordinates.latitude)) *
        cos(degreesToRadians(makkah.longitude) - degreesToRadians(coordinates.longitude)));
    double angle = atan2(term1, term2 - term3);

    return unwindAngle(radiansToDegrees(angle));
  }
}
