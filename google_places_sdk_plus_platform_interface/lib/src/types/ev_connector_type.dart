import 'package:json_annotation/json_annotation.dart';

part 'ev_connector_type.g.dart';

/// The type of an EV charging connector.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#EVConnectorType
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum EvConnectorType {
  @JsonValue('EV_CONNECTOR_TYPE_UNSPECIFIED')
  evConnectorTypeUnspecified,
  @JsonValue('EV_CONNECTOR_TYPE_OTHER')
  evConnectorTypeOther,
  @JsonValue('EV_CONNECTOR_TYPE_J1772')
  evConnectorTypeJ1772,
  @JsonValue('EV_CONNECTOR_TYPE_TYPE_2')
  evConnectorTypeType2,
  @JsonValue('EV_CONNECTOR_TYPE_CHADEMO')
  evConnectorTypeChademo,
  @JsonValue('EV_CONNECTOR_TYPE_CCS_COMBO_1')
  evConnectorTypeCcsCombo1,
  @JsonValue('EV_CONNECTOR_TYPE_CCS_COMBO_2')
  evConnectorTypeCcsCombo2,
  @JsonValue('EV_CONNECTOR_TYPE_TESLA')
  evConnectorTypeTesla,
  @JsonValue('EV_CONNECTOR_TYPE_UNSPECIFIED_GB_T')
  evConnectorTypeUnspecifiedGbT,
  @JsonValue('EV_CONNECTOR_TYPE_UNSPECIFIED_WALL_OUTLET')
  evConnectorTypeUnspecifiedWallOutlet,
  @JsonValue('EV_CONNECTOR_TYPE_NACS')
  evConnectorTypeNacs;

  factory EvConnectorType.fromJson(String name) {
    name = name.toUpperCase();
    for (final pair in _$EvConnectorTypeEnumMap.entries) {
      if (pair.value == name) {
        return pair.key;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}
