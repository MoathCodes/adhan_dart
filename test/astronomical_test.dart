import 'package:adhan_dart/src/astronomical.dart';
import 'package:adhan_dart/src/calculation_method.dart';
import 'package:adhan_dart/src/coordinates.dart';
import 'package:adhan_dart/src/extensions.dart';
import 'package:adhan_dart/src/prayer_times.dart';
import 'package:adhan_dart/src/solar_coordinates.dart';
import 'package:adhan_dart/src/solar_time.dart';
import 'package:test/test.dart';

void main() {
  group('Meeus reference values', () {
    test('calculate solar coordinate values', () {
      // values from Astronomical Algorithms page 165
      var jd = Astronomical.julianDay(1992, 10, 13);
      var solar = SolarCoordinates(jd);

      var t = Astronomical.julianCentury(jd);
      var l0 = Astronomical.meanSolarLongitude(t);
      var e0 = Astronomical.meanObliquityOfTheEcliptic(t);
      final eApp = Astronomical.apparentObliquityOfTheEcliptic(t, e0);
      final m = Astronomical.meanSolarAnomaly(t);
      final c = Astronomical.solarEquationOfTheCenter(t, m);
      final lambda = Astronomical.apparentSolarLongitude(t, l0);
      final delta = solar.declination;
      final alpha = unwindAngle(solar.rightAscension!);

      expect(t, closeTo(-0.072183436, 1e-9));
      expect(l0, closeTo(201.8072, 1e-4));
      expect(e0, closeTo(23.44023, 1e-4));
      expect(eApp, closeTo(23.43999, 1e-4));
      expect(m, closeTo(278.99397, 1e-4));
      expect(c, closeTo(-1.89732, 1e-4));
      expect(lambda, closeTo(199.90895, 1e-4));
      expect(delta, closeTo(-7.78507, 1e-4));
      expect(alpha, closeTo(198.38083, 1e-4));

      // values from Astronomical Algorithms page 88
      jd = Astronomical.julianDay(1987, 4, 10);
      solar = SolarCoordinates(jd);
      t = Astronomical.julianCentury(jd);

      final theta0 = Astronomical.meanSiderealTime(t);
      final thetaApp = solar.apparentSiderealTime;
      final omega = Astronomical.ascendingLunarNodeLongitude(t);
      e0 = Astronomical.meanObliquityOfTheEcliptic(t);
      l0 = Astronomical.meanSolarLongitude(t);
      final lp = Astronomical.meanLunarLongitude(t);
      final dPsi = Astronomical.nutationInLongitude(t, l0, lp, omega);
      final dE = Astronomical.nutationInObliquity(t, l0, lp, omega);
      final e = e0 + dE;

      expect(theta0, closeTo(197.693195, 1e-5));
      expect(thetaApp, closeTo(197.6922295833, 1e-3));

      // values from Astronomical Algorithms page 148
      expect(omega, closeTo(11.2531, 1e-3));
      expect(dPsi, closeTo(-0.0010522, 1e-3));
      expect(dE, closeTo(0.0026230556, 1e-4));
      expect(e0, closeTo(23.4409463889, 1e-5));
      expect(e, closeTo(23.4435694444, 1e-4));
    });

    test('calculate the altitude of a celestial body', () {
      const phi = 38 + 55 / 60 + 17.0 / 3600;
      const delta = -6 - 43 / 60 - 11.61 / 3600;
      const h = 64.352133;
      final altitude = Astronomical.altitudeOfCelestialBody(phi, delta, h);
      expect(altitude, closeTo(15.1249, 1e-3));
    });

    test('calculate the transit and hour angle', () {
      // values from Astronomical Algorithms page 103
      const longitude = -71.0833;
      const theta = 177.74208;
      const alpha1 = 40.68021;
      const alpha2 = 41.73129;
      const alpha3 = 42.78204;
      final m0 = Astronomical.approximateTransit(longitude, theta, alpha2);

      expect(m0, closeTo(0.81965, 1e-4));

      final transit =
          Astronomical.correctedTransit(
                m0,
                longitude,
                theta,
                alpha2,
                alpha1,
                alpha3,
              ) /
              24;

      expect(transit, closeTo(0.8198, 1e-4));

      const delta1 = 18.04761;
      const delta2 = 18.44092;
      const delta3 = 18.82742;
      final coordinates = Coordinates(42.3333, longitude);

      final rise =
          Astronomical.correctedHourAngle(
                m0,
                -0.5667,
                coordinates,
                false,
                theta,
                alpha2,
                alpha1,
                alpha3,
                delta2,
                delta1,
                delta3,
              ) /
              24;
      expect(rise, closeTo(0.51766, 1e-4));
    });

    test('interpolate a value given previous and next values', () {
      final interpolatedValue = Astronomical.interpolate(
        0.877366,
        0.884226,
        0.870531,
        4.35 / 24,
      );
      expect(interpolatedValue, closeTo(0.876125, 1e-5));

      final i1 = Astronomical.interpolate(1, -1, 3, 0.6);
      expect(i1, closeTo(2.2, 1e-5));

      final i2 = Astronomical.interpolateAngles(1, -1, 3, 0.6);
      expect(i2, closeTo(2.2, 1e-5));

      final i3 = Astronomical.interpolateAngles(1, 359, 3, 0.6);
      expect(i3, closeTo(2.2, 1e-5));
    });

    test('calculate the Julian day for a given Gregorian date', () {
      expect(Astronomical.julianDay(2010, 1, 2), 2455198.5);
      expect(Astronomical.julianDay(2015, 6, 12), 2457185.5);

      const jdVal = 2457215.67708333;
      expect(Astronomical.julianDay(2015, 7, 12, 4.25), closeTo(jdVal, 1e-5));
      expect(
        Astronomical.julianDay(2015, 7, 12, 8.0),
        closeTo(2457215.833333, 1e-5),
      );
      expect(
        Astronomical.julianDay(1992, 10, 13, 0.0),
        closeTo(2448908.5, 1e-5),
      );

      final j1 = Astronomical.julianDay(2010, 1, 3);
      final j2 = Astronomical.julianDay(2010, 1, 1, 48);
      expect(j1, j2);
    });
  });

  group('International Date Line', () {
    test('approximateTransit near the IDL returns m0 near 0, not near 1', () {
      // For longitude ~177.24°E on Dec 1, 2025, solar transit falls just
      // after UTC midnight. The raw formula produces a tiny negative number
      // that normalizeToScale wraps to ~1. The fix should return near 0.
      const longitude = 177.24;
      final jd = Astronomical.julianDay(2025, 12, 1);
      final solar = SolarCoordinates(jd);
      final m0 = Astronomical.approximateTransit(
        longitude,
        solar.apparentSiderealTime,
        solar.rightAscension!,
      );

      expect(m0, greaterThan(-0.01));
      expect(m0, lessThan(0.1));
    });

    test('solar times stay continuous across a year near the IDL', () {
      final coordinates = Coordinates(
        42.74674252600066,
        177.2401196144623,
      );
      final solarTimes = <SolarTime>[];
      for (var i = 0; i <= 365; i++) {
        final date = DateTime.utc(2025, 11, 1).add(Duration(days: i));
        solarTimes.add(SolarTime(date, coordinates));
      }

      for (var i = 1; i < solarTimes.length; i++) {
        final time = solarTimes[i];
        final previousTime = solarTimes[i - 1];
        expect(
          (time.transit - previousTime.transit).abs(),
          lessThan(1 / 60),
        );
        expect(
          (time.sunrise - previousTime.sunrise).abs(),
          lessThan(2 / 60),
        );
        expect(
          (time.sunset - previousTime.sunset).abs(),
          lessThan(2 / 60),
        );
      }
    });

    test('prayer times on 2025-12-01 have Fajr before sunrise', () {
      final params = CalculationMethod.muslimWorldLeague;
      final date = DateTime.utc(2025, 12, 1);
      final prayerTimes = PrayerTimes(
        date: date,
        coordinates: Coordinates(42.74674252600066, 177.2401196144623),
        calculationMethod: params,
      );

      expect(
        prayerTimes.fajr.isBefore(prayerTimes.sunrise),
        isTrue,
        reason: 'IDL approximateTransit fix should order Fajr before sunrise',
      );
    });
  });
}
