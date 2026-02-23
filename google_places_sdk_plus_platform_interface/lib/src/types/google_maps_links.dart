import 'package:freezed_annotation/freezed_annotation.dart';

part 'google_maps_links.freezed.dart';
part 'google_maps_links.g.dart';

/// Links to trigger different Google Maps actions.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#GoogleMapsLinks
@freezed
sealed class GoogleMapsLinks with _$GoogleMapsLinks {
  /// Constructs a [GoogleMapsLinks] object.
  const factory GoogleMapsLinks({
    /// A link to show the directions to the place.
    /// The link only populates the destination location and uses the default travel mode DRIVE.
    String? directionsUri,

    /// A link to show this place.
    String? placeUri,

    /// A link to write a review for this place on Google Maps.
    String? writeAReviewUri,

    /// A link to show reviews of this place on Google Maps.
    String? reviewsUri,

    /// A link to show photos of this place on Google Maps.
    String? photosUri,
  }) = _GoogleMapsLinks;

  /// Parse a [GoogleMapsLinks] from json.
  factory GoogleMapsLinks.fromJson(Map<String, Object?> json) =>
      _$GoogleMapsLinksFromJson(json);
}
