import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/connector_aggregation.dart';

part 'ev_charge_options.freezed.dart';
part 'ev_charge_options.g.dart';

/// Information of EV charging options.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#EVChargeOptions
@freezed
sealed class EvChargeOptions with _$EvChargeOptions {
  /// Constructs an [EvChargeOptions] object.
  const factory EvChargeOptions({
    /// Number of connectors at this station.
    int? connectorCount,

    /// A list of EV charging connector aggregations that contain connectors
    /// of the same type and same charge rate.
    List<ConnectorAggregation>? connectorAggregation,
  }) = _EvChargeOptions;

  /// Parse an [EvChargeOptions] from json.
  factory EvChargeOptions.fromJson(Map<String, Object?> json) =>
      _$EvChargeOptionsFromJson(json);
}
