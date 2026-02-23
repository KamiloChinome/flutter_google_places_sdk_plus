import 'package:google_places_sdk_plus_platform_interface/src/types/accessibility_options.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/address_component.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/address_descriptor.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/business_status.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/consumer_alert.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/containing_place.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/ev_charge_amenity_summary.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/ev_charge_options.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/fuel_options.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/generative_summary.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/google_maps_links.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/lat_lng.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/lat_lng_bounds.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/localized_text.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/neighborhood_summary.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/opening_hours.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/parking_options.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/payment_options.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/photo_metadata.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/place_time_zone.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/place_type.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/plus_code.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/postal_address.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/price_level.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/price_range.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/review.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/review_summary.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/sub_destination.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

/// Represents a particular physical place.
///
/// A Place encapsulates information about a physical location, including its name, address, and any other information we might have about it.
///
/// Note: In general, some fields will be inapplicable to certain places, or the information may not exist.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places
@freezed
sealed class Place with _$Place {
  const factory Place({
    // ===== Existing fields (kept as required for backward compat) =====

    /// The unique identifier of a place.
    String? id,

    /// A human-readable address for this place.
    String? address,

    /// The address components for this place's location.
    List<AddressComponent>? addressComponents,

    /// The business status for this place.
    BusinessStatus? businessStatus,

    /// A list of data provider attribution strings.
    List<String>? attributions,

    /// The location of this place.
    LatLng? latLng,

    /// The name of this place (based on the locale of the original request).
    String? name,

    /// The language code of [name].
    String? nameLanguageCode,

    /// The opening hours for this place.
    OpeningHours? openingHours,

    /// The phone number in national format.
    String? phoneNumber,

    /// A list of photos for this place.
    List<PhotoMetadata>? photoMetadatas,

    /// The plus code of this place.
    PlusCode? plusCode,

    /// A rating between 1.0 and 5.0, based on user reviews.
    double? rating,

    /// A list of place types for this place.
    List<PlaceType>? types,

    /// The total number of user ratings for this place.
    int? userRatingsTotal,

    /// The number of minutes this place's current timezone is offset from UTC.
    int? utcOffsetMinutes,

    /// A viewport for displaying this place on a map.
    LatLngBounds? viewport,

    /// The website URI for this place.
    Uri? websiteUri,

    /// A list of reviews for this place.
    List<Review>? reviews,

    // ===== New Places API (New) fields (all optional) =====

    /// The display name of this place as a LocalizedText object.
    LocalizedText? displayName,

    /// The primary type of this place (e.g., "restaurant").
    String? primaryType,

    /// The display name of the primary type, localized to the request language.
    LocalizedText? primaryTypeDisplayName,

    /// A short, human-readable address for this place.
    String? shortFormattedAddress,

    /// The formatted phone number in international format.
    String? internationalPhoneNumber,

    /// The formatted phone number in national format (New API field).
    String? nationalPhoneNumber,

    /// A human-readable string describing the address of this place in
    /// the adr microformat.
    String? adrFormatAddress,

    /// A place's editorial summary.
    LocalizedText? editorialSummary,

    /// Background color for icon_mask in hex format, e.g. #FF9E67.
    String? iconBackgroundColor,

    /// A truncated URL to an icon mask.
    String? iconMaskBaseUri,

    /// The URI for the place's Google Maps page.
    String? googleMapsUri,

    /// Links to trigger different Google Maps actions.
    GoogleMapsLinks? googleMapsLinks,

    /// The place's time zone.
    PlaceTimeZone? timeZone,

    /// The place's postal address.
    PostalAddress? postalAddress,

    /// The place's current opening hours.
    OpeningHours? currentOpeningHours,

    /// The place's secondary opening hours.
    List<OpeningHours>? secondaryOpeningHours,

    /// The place's current secondary opening hours.
    List<OpeningHours>? currentSecondaryOpeningHours,

    // --- Boolean service attributes ---

    /// Whether the place offers curbside pickup.
    bool? curbsidePickup,

    /// Whether the place offers delivery.
    bool? delivery,

    /// Whether the place supports dine-in.
    bool? dineIn,

    /// Whether the place is reservable.
    bool? reservable,

    /// Whether the place serves beer.
    bool? servesBeer,

    /// Whether the place serves breakfast.
    bool? servesBreakfast,

    /// Whether the place serves brunch.
    bool? servesBrunch,

    /// Whether the place serves dinner.
    bool? servesDinner,

    /// Whether the place serves lunch.
    bool? servesLunch,

    /// Whether the place serves vegetarian food.
    bool? servesVegetarianFood,

    /// Whether the place serves wine.
    bool? servesWine,

    /// Whether the place offers takeout.
    bool? takeout,

    /// Whether the place serves cocktails.
    bool? servesCocktails,

    /// Whether the place serves coffee.
    bool? servesCoffee,

    /// Whether the place serves dessert.
    bool? servesDessert,

    /// Whether the place is good for children.
    bool? goodForChildren,

    /// Whether the place allows dogs.
    bool? allowsDogs,

    /// Whether the place has restroom.
    bool? restroom,

    /// Whether the place has a good atmosphere for groups.
    bool? goodForGroups,

    /// Whether the place has good atmosphere for watching sports.
    bool? goodForWatchingSports,

    /// Whether the place has live music.
    bool? liveMusic,

    /// Whether the place has outdoor seating.
    bool? outdoorSeating,

    /// Whether the place has a menu for children.
    bool? menuForChildren,

    // --- Complex option types ---

    /// The place's accessibility options.
    AccessibilityOptions? accessibilityOptions,

    /// The place's payment options.
    PaymentOptions? paymentOptions,

    /// The place's parking options.
    ParkingOptions? parkingOptions,

    /// The place's EV charge options.
    EvChargeOptions? evChargeOptions,

    /// The place's fuel options.
    FuelOptions? fuelOptions,

    /// The place's price range.
    PriceRange? priceRange,

    /// The place's price level.
    PriceLevel? priceLevel,

    // --- Summaries & AI content ---

    /// AI-generated summary of the place.
    GenerativeSummary? generativeSummary,

    /// AI-generated review summary of the place.
    ReviewSummary? reviewSummary,

    /// AI-generated summary of the neighborhood.
    NeighborhoodSummary? neighborhoodSummary,

    /// AI-generated summary of EV charge amenities.
    EvChargeAmenitySummary? evChargeAmenitySummary,

    // --- Relational data ---

    /// Sub-destinations related to the place.
    List<SubDestination>? subDestinations,

    /// Places that contain this place.
    List<ContainingPlace>? containingPlaces,

    /// A relational description of the place's location.
    AddressDescriptor? addressDescriptor,

    /// Consumer alerts placed on this place.
    List<ConsumerAlert>? consumerAlerts,

    /// Whether the place is a pure service-area business
    /// (i.e. has no storefront).
    bool? pureServiceAreaBusiness,
  }) = _Place;

  /// Parse an [Place] from json.
  factory Place.fromJson(Map<String, Object?> json) => _$PlaceFromJson(json);
}
