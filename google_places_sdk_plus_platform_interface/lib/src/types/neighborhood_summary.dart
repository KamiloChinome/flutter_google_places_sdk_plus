import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/content_block.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';

part 'neighborhood_summary.freezed.dart';
part 'neighborhood_summary.g.dart';

/// AI-generated summary of the neighborhood where the place is located.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#NeighborhoodSummary
@freezed
sealed class NeighborhoodSummary with _$NeighborhoodSummary {
  /// Constructs a [NeighborhoodSummary] object.
  const factory NeighborhoodSummary({
    /// An experimental AI-generated overview of the neighborhood.
    ContentBlock? overview,

    /// A detailed description of the neighborhood.
    ContentBlock? description,

    /// A link where the user can flag a problem with the summary.
    String? flagContentUri,

    /// A disclaimer for the AI-generated content.
    LocalizedText? disclosureText,
  }) = _NeighborhoodSummary;

  /// Parse a [NeighborhoodSummary] from json.
  factory NeighborhoodSummary.fromJson(Map<String, Object?> json) =>
      _$NeighborhoodSummaryFromJson(json);
}
