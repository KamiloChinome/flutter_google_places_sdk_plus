import 'package:json_annotation/json_annotation.dart';

part 'containment.g.dart';

/// Defines the spatial containment relationship between the target location and the area.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Containment
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum Containment {
  @JsonValue('CONTAINMENT_UNSPECIFIED')
  containmentUnspecified,
  @JsonValue('WITHIN')
  within,
  @JsonValue('OUTSKIRTS')
  outskirts,
  @JsonValue('NEAR')
  near;

  factory Containment.fromJson(String name) {
    name = name.toUpperCase();
    for (final pair in _$ContainmentEnumMap.entries) {
      if (pair.value == name) {
        return pair.key;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}
