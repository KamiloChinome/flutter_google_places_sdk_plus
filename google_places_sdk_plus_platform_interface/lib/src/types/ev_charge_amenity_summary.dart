import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/content_block.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';

part 'ev_charge_amenity_summary.freezed.dart';
part 'ev_charge_amenity_summary.g.dart';

/// AI-generated summary of amenities available at an EV charging station.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#EvChargeAmenitySummary
@freezed
sealed class EvChargeAmenitySummary with _$EvChargeAmenitySummary {
  /// Constructs an [EvChargeAmenitySummary] object.
  const factory EvChargeAmenitySummary({
    /// An overview of the amenities available at the charging station.
    ContentBlock? overview,

    /// Information about a nearby coffee shop.
    ContentBlock? coffee,

    /// Information about a nearby restaurant.
    ContentBlock? restaurant,

    /// Information about a nearby store.
    ContentBlock? store,

    /// A link where the user can flag a problem with the summary.
    String? flagContentUri,

    /// A disclaimer for the AI-generated content.
    LocalizedText? disclosureText,
  }) = _EvChargeAmenitySummary;

  /// Parse an [EvChargeAmenitySummary] from json.
  factory EvChargeAmenitySummary.fromJson(Map<String, Object?> json) =>
      _$EvChargeAmenitySummaryFromJson(json);
}
