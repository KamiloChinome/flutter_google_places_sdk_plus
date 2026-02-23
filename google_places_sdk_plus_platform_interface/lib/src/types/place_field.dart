import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_field.g.dart';

/// Used to specify which place data types to return.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum PlaceField {
  // ===== Existing fields =====
  FormattedAddress,
  AddressComponents,
  BusinessStatus,
  Id,
  Location,
  DisplayName,
  OpeningHours,
  NationalPhoneNumber,
  InternationalPhoneNumber,
  Photos,
  PlusCode,
  PriceLevel,
  Rating,
  Types,
  UserRatingCount,
  UtcOffset,
  Viewport,
  WebsiteUri,

  /// Places (new) API
  CurbsidePickup,
  CurrentOpeningHours,
  Delivery,
  DineIn,
  EditorialSummary,
  IconBackgroundColor,
  IconMaskUrl,
  Reservable,
  Reviews,
  SecondaryOpeningHours,
  ServesBeer,
  ServesBreakfast,
  ServesBrunch,
  ServesDinner,
  ServesLunch,
  ServesVegetarianFood,
  ServesWine,
  Takeout,
  AccessibilityOptions,

  // ===== New Places API (New) fields =====
  PrimaryType,
  PrimaryTypeDisplayName,
  ShortFormattedAddress,
  AdrFormatAddress,
  GoogleMapsUri,
  GoogleMapsLinks,
  TimeZone,
  PostalAddress,
  CurrentSecondaryOpeningHours,
  PaymentOptions,
  ParkingOptions,
  EvChargeOptions,
  FuelOptions,
  PriceRange,
  SubDestinations,
  ContainingPlaces,
  AddressDescriptor,
  GenerativeSummary,
  ReviewSummary,
  NeighborhoodSummary,
  EvChargeAmenitySummary,
  ConsumerAlerts,

  // Boolean service attributes (new)
  ServesCocktails,
  ServesCoffee,
  ServesDessert,
  GoodForChildren,
  AllowsDogs,
  Restroom,
  GoodForGroups,
  GoodForWatchingSports,
  LiveMusic,
  OutdoorSeating,
  MenuForChildren,
  PureServiceAreaBusiness;

  factory PlaceField.fromJson(String name) {
    name = name.toLowerCase();
    for (final value in values) {
      if (value.name.toLowerCase() == name) {
        return value;
      }
    }
    throw ArgumentError.value(name, 'name', 'No enum value with that name');
  }
}

extension PlaceFieldValue on PlaceField {
  String get value => _$PlaceFieldEnumMap[this]!;
}
