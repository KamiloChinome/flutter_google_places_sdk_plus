import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_time_zone.freezed.dart';
part 'place_time_zone.g.dart';

/// Represents the time zone of a place.
///
/// Note: Named PlaceTimeZone to avoid collision with dart:core TimeZone.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places (timeZone field)
@freezed
sealed class PlaceTimeZone with _$PlaceTimeZone {
  /// Constructs a [PlaceTimeZone] object.
  const factory PlaceTimeZone({
    /// IANA Time Zone Database time zone, e.g. "America/New_York".
    String? id,

    /// Optional. IANA Time Zone Database version number,
    /// e.g. "2019a".
    String? version,
  }) = _PlaceTimeZone;

  /// Parse a [PlaceTimeZone] from json.
  factory PlaceTimeZone.fromJson(Map<String, Object?> json) =>
      _$PlaceTimeZoneFromJson(json);
}
