import 'package:freezed_annotation/freezed_annotation.dart';

part 'parking_options.freezed.dart';
part 'parking_options.g.dart';

/// Options of parking provided by the place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#ParkingOptions
@freezed
sealed class ParkingOptions with _$ParkingOptions {
  /// Constructs a [ParkingOptions] object.
  const factory ParkingOptions({
    /// Place offers free parking lots.
    bool? freeParkingLot,

    /// Place offers paid parking lots.
    bool? paidParkingLot,

    /// Place offers free street parking.
    bool? freeStreetParking,

    /// Place offers paid street parking.
    bool? paidStreetParking,

    /// Place offers valet parking.
    bool? valetParking,

    /// Place offers free garage parking.
    bool? freeGarageParking,

    /// Place offers paid garage parking.
    bool? paidGarageParking,
  }) = _ParkingOptions;

  /// Parse a [ParkingOptions] from json.
  factory ParkingOptions.fromJson(Map<String, Object?> json) =>
      _$ParkingOptionsFromJson(json);
}
