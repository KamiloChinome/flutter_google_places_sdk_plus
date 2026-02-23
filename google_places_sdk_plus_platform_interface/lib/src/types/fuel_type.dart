import 'package:json_annotation/json_annotation.dart';

part 'fuel_type.g.dart';

/// The type of fuel.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#FuelType
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum FuelType {
  @JsonValue('FUEL_TYPE_UNSPECIFIED')
  fuelTypeUnspecified,
  @JsonValue('DIESEL')
  diesel,
  @JsonValue('DIESEL_PLUS')
  dieselPlus,
  @JsonValue('REGULAR_UNLEADED')
  regularUnleaded,
  @JsonValue('MIDGRADE')
  midgrade,
  @JsonValue('PREMIUM')
  premium,
  @JsonValue('SP91')
  sp91,
  @JsonValue('SP91_E10')
  sp91E10,
  @JsonValue('SP92')
  sp92,
  @JsonValue('SP95')
  sp95,
  @JsonValue('SP95_E10')
  sp95E10,
  @JsonValue('SP98')
  sp98,
  @JsonValue('SP99')
  sp99,
  @JsonValue('SP100')
  sp100,
  @JsonValue('LPG')
  lpg,
  @JsonValue('E80')
  e80,
  @JsonValue('E85')
  e85,
  @JsonValue('E100')
  e100,
  @JsonValue('METHANE')
  methane,
  @JsonValue('BIO_DIESEL')
  bioDiesel,
  @JsonValue('TRUCK_DIESEL')
  truckDiesel;

  factory FuelType.fromJson(String name) {
    name = name.toUpperCase();
    for (final pair in _$FuelTypeEnumMap.entries) {
      if (pair.value == name) {
        return pair.key;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}
