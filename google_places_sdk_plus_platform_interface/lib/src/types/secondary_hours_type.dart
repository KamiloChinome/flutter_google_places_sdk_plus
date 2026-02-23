import 'package:json_annotation/json_annotation.dart';

part 'secondary_hours_type.g.dart';

/// A type used to identify the type of secondary hours.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#SecondaryHoursType
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum SecondaryHoursType {
  @JsonValue('SECONDARY_HOURS_TYPE_UNSPECIFIED')
  secondaryHoursTypeUnspecified,
  @JsonValue('DRIVE_THROUGH')
  driveThrough,
  @JsonValue('HAPPY_HOUR')
  happyHour,
  @JsonValue('DELIVERY')
  delivery,
  @JsonValue('TAKEOUT')
  takeout,
  @JsonValue('KITCHEN')
  kitchen,
  @JsonValue('BREAKFAST')
  breakfast,
  @JsonValue('LUNCH')
  lunch,
  @JsonValue('DINNER')
  dinner,
  @JsonValue('BRUNCH')
  brunch,
  @JsonValue('PICKUP')
  pickup,
  @JsonValue('ACCESS')
  access,
  @JsonValue('SENIOR_HOURS')
  seniorHours,
  @JsonValue('ONLINE_SERVICE_HOURS')
  onlineServiceHours;

  factory SecondaryHoursType.fromJson(String name) {
    name = name.toUpperCase();
    for (final pair in _$SecondaryHoursTypeEnumMap.entries) {
      if (pair.value == name) {
        return pair.key;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}
