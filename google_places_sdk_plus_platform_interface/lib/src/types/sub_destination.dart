import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_destination.freezed.dart';
part 'sub_destination.g.dart';

/// A sub-destination related to the place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#SubDestination
@freezed
sealed class SubDestination with _$SubDestination {
  /// Constructs a [SubDestination] object.
  const factory SubDestination({
    /// The resource name of the sub-destination.
    String? name,

    /// The place id of the sub-destination.
    String? id,
  }) = _SubDestination;

  /// Parse a [SubDestination] from json.
  factory SubDestination.fromJson(Map<String, Object?> json) =>
      _$SubDestinationFromJson(json);
}
