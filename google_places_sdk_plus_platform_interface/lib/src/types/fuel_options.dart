import 'package:google_places_sdk_plus_platform_interface/src/types/fuel_price.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_options.freezed.dart';
part 'fuel_options.g.dart';

/// The most recent information about fuel options in a gas station.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#FuelOptions
@freezed
sealed class FuelOptions with _$FuelOptions {
  /// Constructs a [FuelOptions] object.
  const factory FuelOptions({
    /// The last known fuel price for each type of fuel this station has.
    /// There is one entry per fuel type this station has. Order is not important.
    List<FuelPrice>? fuelPrices,
  }) = _FuelOptions;

  /// Parse a [FuelOptions] from json.
  factory FuelOptions.fromJson(Map<String, Object?> json) =>
      _$FuelOptionsFromJson(json);
}
