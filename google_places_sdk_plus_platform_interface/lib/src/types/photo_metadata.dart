import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/author_attribution.dart';

part 'photo_metadata.freezed.dart';
part 'photo_metadata.g.dart';

/// The metadata corresponding to a single photo associated with a place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Photo
@freezed
sealed class PhotoMetadata with _$PhotoMetadata {
  const factory PhotoMetadata({
    /// Non-empty String used to identify the underlying photo.
    String? photoReference,

    /// The maximum width in which this photo is available.
    int? width,

    /// The maximum height in which this photo is available.
    int? height,

    /// The attributions that must be shown to the user if this photo is displayed.
    String? attributions,

    /// The author attributions for this photo.
    ///
    /// Available in the Places API (New).
    List<AuthorAttribution>? authorAttributions,

    /// A link where users can flag a problem with the photo.
    String? flagContentUri,

    /// A link to show the photo on Google Maps.
    String? googleMapsUri,
  }) = _PhotoMetadata;

  /// Parse an [PhotoMetadata] from json.
  factory PhotoMetadata.fromJson(Map<String, Object?> json) =>
      _$PhotoMetadataFromJson(json);
}
