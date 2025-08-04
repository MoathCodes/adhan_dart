/// A data class used to hold latitude and longitude values
/// to use in different methods/classes
///
/// ```dart
/// final cords = Coordinates(-39.1, 12.09)
/// ```
class Coordinates {
  final double latitude;
  final double longitude;

  const Coordinates(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90,
            'Latitude must be between -90 and 90 degrees'),
        assert(longitude >= -180 && longitude <= 180,
            'Longitude must be between -180 and 180 degrees');

  /// Create coordinates with validation
  factory Coordinates.validated(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError(
          'Latitude must be between -90 and 90 degrees, got: $latitude');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError(
          'Longitude must be between -180 and 180 degrees, got: $longitude');
    }
    return Coordinates(latitude, longitude);
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  /// Check if coordinates are valid
  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  /// Creates a copy of this Coordinates with the given fields replaced with new values
  Coordinates copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Coordinates(
      latitude ?? this.latitude,
      longitude ?? this.longitude,
    );
  }

  @override
  String toString() =>
      'Coordinates(latitude: $latitude, longitude: $longitude)';
}
