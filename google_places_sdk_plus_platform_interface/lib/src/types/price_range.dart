import 'package:google_places_sdk_plus_platform_interface/src/types/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_range.freezed.dart';
part 'price_range.g.dart';

/// The price range associated with a Place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#PriceRange
@freezed
sealed class PriceRange with _$PriceRange {
  /// Constructs a [PriceRange] object.
  const factory PriceRange({
    /// The low end of the price range (inclusive).
    /// Price should be at or above this amount.
    Money? startPrice,

    /// The high end of the price range (exclusive).
    /// Price should be lower than this amount.
    Money? endPrice,
  }) = _PriceRange;

  /// Parse a [PriceRange] from json.
  factory PriceRange.fromJson(Map<String, Object?> json) =>
      _$PriceRangeFromJson(json);
}
