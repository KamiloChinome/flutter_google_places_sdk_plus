import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/area.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/landmark.dart';

part 'address_descriptor.freezed.dart';
part 'address_descriptor.g.dart';

/// A relational description of a location. Includes a ranked set of nearby
/// landmarks and precise containing areas and their relationship to the
/// target location.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#AddressDescriptor
@freezed
sealed class AddressDescriptor with _$AddressDescriptor {
  /// Constructs an [AddressDescriptor] object.
  const factory AddressDescriptor({
    /// A ranked list of nearby landmarks. The most recognizable and
    /// nearby landmarks are ranked first.
    List<Landmark>? landmarks,

    /// A ranked list of containing or adjacent areas. The most
    /// recognizable and precise areas are ranked first.
    List<Area>? areas,
  }) = _AddressDescriptor;

  /// Parse an [AddressDescriptor] from json.
  factory AddressDescriptor.fromJson(Map<String, Object?> json) =>
      _$AddressDescriptorFromJson(json);
}
