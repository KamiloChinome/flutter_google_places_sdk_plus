import 'package:json_annotation/json_annotation.dart';

part 'spatial_relationship.g.dart';

/// Defines the spatial relationship between the target location and the landmark.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#SpatialRelationship
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum SpatialRelationship {
  @JsonValue('NEAR')
  near,
  @JsonValue('WITHIN')
  within,
  @JsonValue('BESIDE')
  beside,
  @JsonValue('ACROSS_THE_ROAD')
  acrossTheRoad,
  @JsonValue('DOWN_THE_ROAD')
  downTheRoad,
  @JsonValue('AROUND_THE_CORNER')
  aroundTheCorner,
  @JsonValue('BEHIND')
  behind;

  factory SpatialRelationship.fromJson(String name) {
    name = name.toUpperCase();
    for (final pair in _$SpatialRelationshipEnumMap.entries) {
      if (pair.value == name) {
        return pair.key;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}
