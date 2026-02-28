import 'package:json_annotation/json_annotation.dart';

part 'price_level.g.dart';

/// Price level of the place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#PriceLevel
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum PriceLevel {
  @JsonValue('PRICE_LEVEL_UNSPECIFIED')
  priceLevelUnspecified,
  @JsonValue('PRICE_LEVEL_FREE')
  priceLevelFree,
  @JsonValue('PRICE_LEVEL_INEXPENSIVE')
  priceLevelInexpensive,
  @JsonValue('PRICE_LEVEL_MODERATE')
  priceLevelModerate,
  @JsonValue('PRICE_LEVEL_EXPENSIVE')
  priceLevelExpensive,
  @JsonValue('PRICE_LEVEL_VERY_EXPENSIVE')
  priceLevelVeryExpensive;

  factory PriceLevel.fromJson(dynamic value) {
    if (value is int) {
      // Legacy: older iOS plugin versions (< 0.3.3) sent priceLevel as an int.
      // Both platforms now send string values (e.g. "PRICE_LEVEL_MODERATE").
      // Keeping int support for backward compatibility.
      if (value >= 0 && value < PriceLevel.values.length) {
        return PriceLevel.values[value];
      }
      return PriceLevel.priceLevelUnspecified;
    }
    final name = (value as String).toUpperCase();
    for (final pair in _$PriceLevelEnumMap.entries) {
      if (pair.value == name) {
        return pair.key;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}
