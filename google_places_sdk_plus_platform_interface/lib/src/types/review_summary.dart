import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_summary.freezed.dart';
part 'review_summary.g.dart';

/// AI-generated summary of the place using user reviews.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#ReviewSummary
@freezed
sealed class ReviewSummary with _$ReviewSummary {
  /// Constructs a [ReviewSummary] object.
  const factory ReviewSummary({
    /// The summary of user reviews.
    LocalizedText? text,

    /// A link where users can flag a problem with the summary.
    String? flagContentUri,

    /// The AI disclosure message "Summarized with Gemini" (and its localized variants).
    LocalizedText? disclosureText,

    /// A link to show reviews of this place on Google Maps.
    String? reviewsUri,
  }) = _ReviewSummary;

  /// Parse a [ReviewSummary] from json.
  factory ReviewSummary.fromJson(Map<String, Object?> json) =>
      _$ReviewSummaryFromJson(json);
}
