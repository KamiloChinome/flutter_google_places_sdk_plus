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
      // iOS SDK sends priceLevel as an int (raw enum value)
      // 0 = unspecified, 1 = free, 2 = inexpensive, 3 = moderate, 4 = expensive, 5 = very expensive
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
