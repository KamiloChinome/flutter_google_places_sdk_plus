import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/spatial_relationship.dart';

part 'landmark.freezed.dart';
part 'landmark.g.dart';

/// Basic landmark information and the landmark's relationship with the
/// target location.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Landmark
@freezed
sealed class Landmark with _$Landmark {
  /// Constructs a [Landmark] object.
  const factory Landmark({
    /// The resource name of the landmark.
    String? name,

    /// The Place ID of the underlying establishment serving as the landmark.
    String? placeId,

    /// The display name of the landmark.
    LocalizedText? displayName,

    /// The types of the landmark.
    List<String>? types,

    /// Defines the spatial relationship between the target location and the landmark.
    SpatialRelationship? spatialRelationship,

    /// The straight-line distance, in meters, between the center point of
    /// the target and the center point of the landmark.
    double? straightLineDistanceMeters,

    /// The travel distance, in meters, along the road network from the
    /// target to the landmark, if known.
    double? travelDistanceMeters,
  }) = _Landmark;

  /// Parse a [Landmark] from json.
  factory Landmark.fromJson(Map<String, Object?> json) =>
      _$LandmarkFromJson(json);
}
