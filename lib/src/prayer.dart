/// Enum for each prayer
/// * five obligatory prayers
///   - fajr
///   - dhuhr
///   - asr
///   - maghrib
///   - isha
/// * three additional values
///   - sunrise
///   - ishaBefore (isha prayer of the day before)
///   - fajrAfter (fajr prayer of the next day)
enum Prayer {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  ishaBefore,
  fajrAfter;

  /// Gets all obligatory prayers in order
  static List<Prayer> get obligatoryPrayers => [
        Prayer.fajr,
        Prayer.dhuhr,
        Prayer.asr,
        Prayer.maghrib,
        Prayer.isha,
      ];

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
