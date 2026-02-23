import 'package:google_places_sdk_plus_platform_interface/src/types/fuel_type.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_price.freezed.dart';
part 'fuel_price.g.dart';

/// Fuel price information for a given type.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#FuelPrice
@freezed
sealed class FuelPrice with _$FuelPrice {
  /// Constructs a [FuelPrice] object.
  const factory FuelPrice({
    /// The type of fuel.
    FuelType? type,

    /// The price of the fuel.
    Money? price,

    /// The time the fuel price was last updated.
    /// A timestamp in RFC3339 UTC "Zulu" format.
    String? updateTime,
  }) = _FuelPrice;

  /// Parse a [FuelPrice] from json.
  factory FuelPrice.fromJson(Map<String, Object?> json) =>
      _$FuelPriceFromJson(json);
}
