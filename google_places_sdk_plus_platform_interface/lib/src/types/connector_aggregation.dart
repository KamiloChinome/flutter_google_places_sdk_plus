import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/ev_connector_type.dart';

part 'connector_aggregation.freezed.dart';
part 'connector_aggregation.g.dart';

/// EV charging connector aggregation that contains connectors of the same type
/// and same charge rate.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#ConnectorAggregation
@freezed
sealed class ConnectorAggregation with _$ConnectorAggregation {
  /// Constructs a [ConnectorAggregation] object.
  const factory ConnectorAggregation({
    /// The connector type of this aggregation.
    EvConnectorType? type,

    /// The static max charging rate in kw of each connector in the aggregation.
    double? maxChargeRateKw,

    /// Number of connectors in this aggregation.
    int? count,

    /// The timestamp when the connector availability information in this
    /// aggregation was last updated. Uses RFC 3339.
    String? availabilityLastUpdateTime,

    /// Number of connectors in this aggregation that are currently available.
    int? availableCount,

    /// Number of connectors in this aggregation that are currently out of service.
    int? outOfServiceCount,
  }) = _ConnectorAggregation;

  /// Parse a [ConnectorAggregation] from json.
  factory ConnectorAggregation.fromJson(Map<String, Object?> json) =>
      _$ConnectorAggregationFromJson(json);
}
