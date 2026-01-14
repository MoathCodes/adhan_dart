// import 'dart:math';

/// Utility class for converting decimal hours to time components (hours, minutes, seconds)
/// and creating DateTime objects from those components.
class TimeComponents {
  final int hours;
  final int minutes;
  final int seconds;

  TimeComponents(double number)
      : hours = number.floor(),
        minutes = ((number - number.floor()) * 60).floor(),
        seconds = ((number -
                    (number.floor() +
                        ((number - number.floor()) * 60).floor() / 60)) *
                60 *
                60)
            .floor();

  DateTime utcDate(year, month, date) {
    return DateTime.utc(year, month, date, hours, minutes, seconds);
  }
}
