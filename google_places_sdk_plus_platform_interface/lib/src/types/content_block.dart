import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_block.freezed.dart';
part 'content_block.g.dart';

/// A block of content that can be served individually.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#ContentBlock
@freezed
sealed class ContentBlock with _$ContentBlock {
  /// Constructs a [ContentBlock] object.
  const factory ContentBlock({
    /// Content related to the topic.
    LocalizedText? content,

    /// The list of resource names of the referenced places.
    /// This name can be used in other APIs that accept Place resource names.
    List<String>? referencedPlaces,
  }) = _ContentBlock;

  /// Parse a [ContentBlock] from json.
  factory ContentBlock.fromJson(Map<String, Object?> json) =>
      _$ContentBlockFromJson(json);
}
