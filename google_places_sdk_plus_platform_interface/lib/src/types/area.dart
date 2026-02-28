import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/containment.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';

part 'area.freezed.dart';
part 'area.g.dart';

/// Area information and the area's relationship with the target location.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Area
@freezed
sealed class Area with _$Area {
  /// Constructs an [Area] object.
  const factory Area({
    /// The resource name of the area.
    String? name,

    /// The Place ID of the area.
    String? placeId,

    /// The display name of the area.
    LocalizedText? displayName,

    /// Defines the spatial relationship between the target location and the area.
    Containment? containment,
  }) = _Area;

  /// Parse an [Area] from json.
  factory Area.fromJson(Map<String, Object?> json) => _$AreaFromJson(json);
}
