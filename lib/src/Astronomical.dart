import 'dart:math';

import 'package:adhan_dart/src/extensions.dart';

class Astronomical {
  static double altitudeOfCelestialBody(
      observerLatitude, declination, localHourAngle) {
    final phi = observerLatitude;
    final delta = declination;
    final H = localHourAngle;
    final term1 = sin(degreesToRadians(phi)) * sin(degreesToRadians(delta));
    final term2 = cos(degreesToRadians(phi)) *
        cos(degreesToRadians(delta)) *
        cos(degreesToRadians(H));
    return radiansToDegrees(asin(term1 + term2));
  }

  static double apparentObliquityOfTheEcliptic(
      julianCentury, meanObliquityOfTheEcliptic) {
    final T = julianCentury;
    final epsilon0 = meanObliquityOfTheEcliptic;
    final O = 125.04 - (1934.136 * T);
    return epsilon0 + (0.00256 * cos(degreesToRadians(O)));
  }

  static double apparentSolarLongitude(julianCentury, meanLongitude) {
    final T = julianCentury;
    final l0 = meanLongitude;
    final longitude = l0 +
        Astronomical.solarEquationOfTheCenter(
            T, Astronomical.meanSolarAnomaly(T));
    final omega = 125.04 - (1934.136 * T);
    final lambda =
        longitude - 0.00569 - (0.00478 * sin(degreesToRadians(omega)));
    return unwindAngle(lambda);
  }

  static double approximateTransit(longitude, siderealTime, rightAscension) {
    final L = longitude;
    final theta0 = siderealTime;
    final a2 = rightAscension;
    final lw = L * -1;
    return normalizeToScale((a2 + lw - theta0) / 360, 1);
  }

  static double ascendingLunarNodeLongitude(double julianCentury) {
    final T = julianCentury;
    const term1 = 125.04452;
    final term2 = 1934.136261 * T;
    final term3 = 0.0020708 * pow(T, 2);
    final term4 = pow(T, 3) / 450000;
    final omega = term1 - term2 + term3 + term4;
    return unwindAngle(omega);
  }

  static double correctedHourAngle(
    approximateTransit,
    angle,
    coordinates,
    afterTransit,
    siderealTime,
    rightAscension,
    previousRightAscension,
    nextRightAscension,
    declination,
    previousDeclination,
    nextDeclination,
  ) {
    final m0 = approximateTransit as double?;
    final h02 = angle as double;
    final theta0 = siderealTime as double;
    final a2 = rightAscension as double;
    final a1 = previousRightAscension as double?;
    final a3 = nextRightAscension as double;
    final d2 = declination as double;
    final d1 = previousDeclination as double?;
    final d3 = nextDeclination as double;

    final lw = coordinates.longitude * -1;
    final term1 = sin(degreesToRadians(h02)) -
        (sin(degreesToRadians(coordinates.latitude)) *
            sin(degreesToRadians(d2)));
    final term2 =
        cos(degreesToRadians(coordinates.latitude)) * cos(degreesToRadians(d2));

    // Clamp ratio to [-1,1] to avoid NaN from acos when numerical rounding pushes it out of range.
    final ratio = term1 / term2;
    final clamped = ratio > 1 ? 1.0 : (ratio < -1 ? -1.0 : ratio);
    final h021 = radiansToDegrees(acos(clamped));

    final m = (afterTransit as bool) ? m0! + (h021 / 360) : m0! - (h021 / 360);
    final theta = unwindAngle((theta0 + (360.985647 * m)));
    final a = unwindAngle(Astronomical.interpolateAngles(a2, a1, a3, m)!);
    final delta = Astronomical.interpolate(d2, d1, d3, m)!;
    final H = (theta - lw - a);
    final h =
        Astronomical.altitudeOfCelestialBody(coordinates.latitude, delta, H);
    final term3 = h - h02;
    final term4 = 360 *
        cos(degreesToRadians(delta)) *
        cos(degreesToRadians(coordinates.latitude)) *
        sin(degreesToRadians(H));
    final dm = term3 / term4;
    return (m + dm) * 24;
  }

  static double correctedTransit(approximateTransit, longitude, siderealTime,
      rightAscension, previousRightAscension, nextRightAscension) {
    final m0 = approximateTransit;
    final L = longitude;
    final theta0 = siderealTime;
    final a2 = rightAscension;
    final a1 = previousRightAscension;
    final a3 = nextRightAscension;
    final lw = L * -1;
    final theta = unwindAngle((theta0 + (360.985647 * m0)));
    final a = unwindAngle(Astronomical.interpolateAngles(a2, a1, a3, m0)!);
    final H = quadrantShiftAngle(theta - lw - a);
    final dm = H / -360;
    return (m0 + dm) * 24;
  }

  static int daysSinceSolstice(int dayOfYear, int year, double latitude) {
    int daysSinceSolstice;
    const northernOffset = 10;
    final southernOffset = Astronomical.isLeapYear(year) ? 173 : 172;
    final daysInYear = Astronomical.isLeapYear(year) ? 366 : 365;

    if (latitude >= 0) {
      daysSinceSolstice = dayOfYear + northernOffset;
      if (daysSinceSolstice >= daysInYear) {
        daysSinceSolstice -= daysInYear;
      }
    } else {
      daysSinceSolstice = dayOfYear - southernOffset;
      if (daysSinceSolstice < 0) {
        daysSinceSolstice += daysInYear;
      }
    }
    return daysSinceSolstice;
  }

  static double? interpolate(y2, y1, y3, n) {
    final a = y2 - y1;
    final b = y3 - y2;
    final c = b - a;
    return y2 + ((n / 2) * (a + b + (n * c)));
  }

  static double? interpolateAngles(y2, y1, y3, n) {
    final a = unwindAngle(y2 - y1);
    final b = unwindAngle(y3 - y2);
    final c = b - a;
    return y2 + ((n / 2) * (a + b + (n * c)));
  }

  static bool isLeapYear(year) {
    if (year % 4 != 0) return false;
    if (year % 100 == 0 && year % 400 != 0) return false;
    return true;
  }

  static double julianCentury(double julianDay) =>
      (julianDay - 2451545.0) / 36525;

  static double julianDay(year, month, day, hours) {
    hours ??= 0;
    trunc(val) => val.truncate();
    final Y = trunc(month > 2 ? year : year - 1);
    final M = trunc(month > 2 ? month : month + 12);
    final D = day + (hours / 24);
    final A = trunc(Y / 100);
    final B = trunc(2 - A + trunc(A / 4));
    final i0 = trunc(365.25 * (Y + 4716));
    final i1 = trunc(30.6001 * (M + 1));
    return i0 + i1 + D + B - 1524.5;
  }

  static double meanLunarLongitude(double julianCentury) {
    final T = julianCentury;
    const term1 = 218.3165;
    final term2 = 481267.8813 * T;
    final lp = term1 + term2;
    return unwindAngle(lp);
  }

  static double meanObliquityOfTheEcliptic(double julianCentury) {
    final T = julianCentury;
    const term1 = 23.439291;
    final term2 = 0.013004167 * T;
    final term3 = 0.0000001639 * pow(T, 2);
    final term4 = 0.0000005036 * pow(T, 3);
    return term1 - term2 - term3 + term4;
  }

  static double meanSiderealTime(double julianCentury) {
    final T = julianCentury;
    final jd = (T * 36525) + 2451545.0;
    const term1 = 280.46061837;
    final term2 = 360.98564736629 * (jd - 2451545);
    final term3 = 0.000387933 * pow(T, 2);
    final term4 = pow(T, 3) / 38710000;
    final theta = term1 + term2 + term3 - term4;
    return unwindAngle(theta);
  }

  static double meanSolarAnomaly(double julianCentury) {
    final T = julianCentury;
    const term1 = 357.52911;
    final term2 = 35999.05029 * T;
    final term3 = 0.0001537 * pow(T, 2);
    final M = term1 + term2 - term3;
    return unwindAngle(M);
  }

  static double meanSolarLongitude(double julianCentury) {
    final T = julianCentury;
    const term1 = 280.4664567;
    final term2 = 36000.76983 * T;
    final term3 = 0.0003032 * pow(T, 2);
    final l0 = term1 + term2 + term3;
    return unwindAngle(l0);
  }

  static double nutationInLongitude(
      julianCentury, solarLongitude, lunarLongitude, ascendingNode) {
    final l0 = solarLongitude;
    final lp = lunarLongitude;
    final omega = ascendingNode;
    final term1 = (-17.2 / 3600) * sin(degreesToRadians(omega));
    final term2 = (1.32 / 3600) * sin(2 * degreesToRadians(l0));
    final term3 = (0.23 / 3600) * sin(2 * degreesToRadians(lp));
    final term4 = (0.21 / 3600) * sin(2 * degreesToRadians(omega));
    return term1 - term2 - term3 + term4;
  }

  static double nutationInObliquity(
      julianCentury, solarLongitude, lunarLongitude, ascendingNode) {
    final l0 = solarLongitude;
    final lp = lunarLongitude;
    final omega = ascendingNode;
    final term1 = (9.2 / 3600) * cos(degreesToRadians(omega));
    final term2 = (0.57 / 3600) * cos(2 * degreesToRadians(l0));
    final term3 = (0.10 / 3600) * cos(2 * degreesToRadians(lp));
    final term4 = (0.09 / 3600) * cos(2 * degreesToRadians(omega));
    return term1 + term2 + term3 - term4;
  }

  static DateTime seasonAdjustedEveningTwilight(
      double latitude, int dayOfYear, int year, DateTime sunset) {
    final a = 75 + ((25.60 / 55.0) * (latitude).abs());
    final b = 75 + ((2.050 / 55.0) * (latitude).abs());
    final c = 75 - ((9.210 / 55.0) * (latitude).abs());
    final d = 75 + ((6.140 / 55.0) * (latitude).abs());

    double adjustment() {
      final dyy = Astronomical.daysSinceSolstice(dayOfYear, year, latitude);
      if (dyy < 91) {
        return a + (b - a) / 91.0 * dyy;
      } else if (dyy < 137) {
        return b + (c - b) / 46.0 * (dyy - 91);
      } else if (dyy < 183) {
        return c + (d - c) / 46.0 * (dyy - 137);
      } else if (dyy < 229) {
        return d + (c - d) / 46.0 * (dyy - 183);
      } else if (dyy < 275) {
        return c + (b - c) / 46.0 * (dyy - 229);
      } else {
        return b + (a - b) / 91.0 * (dyy - 275);
      }
    }

    return sunset.addSeconds((adjustment() * 60.0).round());
  }

  static DateTime seasonAdjustedMorningTwilight(
      double latitude, int dayOfYear, int year, DateTime sunrise) {
    final a = 75 + ((28.65 / 55.0) * (latitude).abs());
    final b = 75 + ((19.44 / 55.0) * (latitude).abs());
    final c = 75 + ((32.74 / 55.0) * (latitude).abs());
    final d = 75 + ((48.10 / 55.0) * (latitude).abs());

    double adjustment() {
      final dyy = Astronomical.daysSinceSolstice(dayOfYear, year, latitude);
      if (dyy < 91) {
        return a + (b - a) / 91.0 * dyy;
      } else if (dyy < 137) {
        return b + (c - b) / 46.0 * (dyy - 91);
      } else if (dyy < 183) {
        return c + (d - c) / 46.0 * (dyy - 137);
      } else if (dyy < 229) {
        return d + (c - d) / 46.0 * (dyy - 183);
      } else if (dyy < 275) {
        return c + (b - c) / 46.0 * (dyy - 229);
      } else {
        return b + (a - b) / 91.0 * (dyy - 275);
      }
    }

    return sunrise.addSeconds((adjustment() * -60.0).round());
  }

  static double solarEquationOfTheCenter(julianCentury, meanAnomaly) {
    final T = julianCentury;
    final mrad = degreesToRadians(meanAnomaly);
    final term1 =
        (1.914602 - (0.004817 * T) - (0.000014 * pow(T, 2))) * sin(mrad);
    final term2 = (0.019993 - (0.000101 * T)) * sin(2 * mrad);
    final term3 = 0.000289 * sin(3 * mrad);
    return term1 + term2 + term3;
  }
}
