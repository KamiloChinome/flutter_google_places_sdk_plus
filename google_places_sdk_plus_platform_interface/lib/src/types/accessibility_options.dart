import 'package:freezed_annotation/freezed_annotation.dart';

part 'accessibility_options.freezed.dart';
part 'accessibility_options.g.dart';

/// Information about the accessibility options a place offers.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#AccessibilityOptions
@freezed
sealed class AccessibilityOptions with _$AccessibilityOptions {
  /// Constructs an [AccessibilityOptions] object.
  const factory AccessibilityOptions({
    /// Place offers wheelchair accessible parking.
    bool? wheelchairAccessibleParking,

    /// Place has wheelchair accessible entrance.
    bool? wheelchairAccessibleEntrance,

    /// Place has wheelchair accessible restroom.
    bool? wheelchairAccessibleRestroom,

    /// Place has wheelchair accessible seating.
    bool? wheelchairAccessibleSeating,
  }) = _AccessibilityOptions;

  /// Parse an [AccessibilityOptions] from json.
  factory AccessibilityOptions.fromJson(Map<String, Object?> json) =>
      _$AccessibilityOptionsFromJson(json);
}
