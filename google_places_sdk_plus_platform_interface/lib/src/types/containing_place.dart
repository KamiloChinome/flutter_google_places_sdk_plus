import 'package:freezed_annotation/freezed_annotation.dart';

part 'containing_place.freezed.dart';
part 'containing_place.g.dart';

/// A place in which the current place is located.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#ContainingPlace
@freezed
sealed class ContainingPlace with _$ContainingPlace {
  /// Constructs a [ContainingPlace] object.
  const factory ContainingPlace({
    /// The resource name of the place in which this place is located.
    String? name,

    /// The place id of the place in which this place is located.
    String? id,
  }) = _ContainingPlace;

  /// Parse a [ContainingPlace] from json.
  factory ContainingPlace.fromJson(Map<String, Object?> json) =>
      _$ContainingPlaceFromJson(json);
}
