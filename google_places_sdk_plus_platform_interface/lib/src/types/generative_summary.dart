import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';

part 'generative_summary.freezed.dart';
part 'generative_summary.g.dart';

/// AI-generated summary of the place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#GenerativeSummary
@freezed
sealed class GenerativeSummary with _$GenerativeSummary {
  /// Constructs a [GenerativeSummary] object.
  const factory GenerativeSummary({
    /// The overview of the place.
    LocalizedText? overview,

    /// A link where users can flag a problem with the overview summary.
    String? overviewFlagContentUri,

    /// The AI disclosure message "Summarized with Gemini" (and its localized variants).
    LocalizedText? disclosureText,
  }) = _GenerativeSummary;

  /// Parse a [GenerativeSummary] from json.
  factory GenerativeSummary.fromJson(Map<String, Object?> json) =>
      _$GenerativeSummaryFromJson(json);
}
