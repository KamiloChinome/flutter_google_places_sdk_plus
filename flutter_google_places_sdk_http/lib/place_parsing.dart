import 'package:flutter_google_places_sdk_platform_interface/flutter_google_places_sdk_platform_interface.dart'
    as inter;

/// Maps a [inter.PlaceField] to the Places API v2 REST field name.
///
/// These field names are used in the `X-Goog-FieldMask` header.
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places
String placeFieldToApiName(inter.PlaceField field) {
  return switch (field) {
    inter.PlaceField.Id => 'id',
    inter.PlaceField.DisplayName => 'displayName',
    inter.PlaceField.FormattedAddress => 'formattedAddress',
    inter.PlaceField.AdrFormatAddress => 'adrFormatAddress',
    inter.PlaceField.AddressComponents => 'addressComponents',
    inter.PlaceField.BusinessStatus => 'businessStatus',
    inter.PlaceField.Location => 'location',
    inter.PlaceField.OpeningHours => 'regularOpeningHours',
    inter.PlaceField.CurrentOpeningHours => 'currentOpeningHours',
    inter.PlaceField.SecondaryOpeningHours => 'regularSecondaryOpeningHours',
    inter.PlaceField.CurrentSecondaryOpeningHours =>
      'currentSecondaryOpeningHours',
    inter.PlaceField.NationalPhoneNumber => 'nationalPhoneNumber',
    inter.PlaceField.InternationalPhoneNumber => 'internationalPhoneNumber',
    inter.PlaceField.Photos => 'photos',
    inter.PlaceField.PlusCode => 'plusCode',
    inter.PlaceField.PriceLevel => 'priceLevel',
    inter.PlaceField.Rating => 'rating',
    inter.PlaceField.Types => 'types',
    inter.PlaceField.UserRatingCount => 'userRatingCount',
    inter.PlaceField.UtcOffset => 'utcOffsetMinutes',
    inter.PlaceField.Viewport => 'viewport',
    inter.PlaceField.WebsiteUri => 'websiteUri',
    inter.PlaceField.Reviews => 'reviews',
    inter.PlaceField.CurbsidePickup => 'curbsidePickup',
    inter.PlaceField.Delivery => 'delivery',
    inter.PlaceField.DineIn => 'dineIn',
    inter.PlaceField.EditorialSummary => 'editorialSummary',
    inter.PlaceField.IconBackgroundColor => 'iconBackgroundColor',
    inter.PlaceField.IconMaskUrl => 'iconMaskBaseUri',
    inter.PlaceField.Reservable => 'reservable',
    inter.PlaceField.ServesBeer => 'servesBeer',
    inter.PlaceField.ServesBreakfast => 'servesBreakfast',
    inter.PlaceField.ServesBrunch => 'servesBrunch',
    inter.PlaceField.ServesDinner => 'servesDinner',
    inter.PlaceField.ServesLunch => 'servesLunch',
    inter.PlaceField.ServesVegetarianFood => 'servesVegetarianFood',
    inter.PlaceField.ServesWine => 'servesWine',
    inter.PlaceField.Takeout => 'takeout',
    inter.PlaceField.AccessibilityOptions => 'accessibilityOptions',
    inter.PlaceField.PrimaryType => 'primaryType',
    inter.PlaceField.PrimaryTypeDisplayName => 'primaryTypeDisplayName',
    inter.PlaceField.ShortFormattedAddress => 'shortFormattedAddress',
    inter.PlaceField.GoogleMapsUri => 'googleMapsUri',
    inter.PlaceField.GoogleMapsLinks => 'googleMapsLinks',
    inter.PlaceField.TimeZone => 'utcOffsetMinutes',
    inter.PlaceField.PostalAddress => 'addressComponents',
    inter.PlaceField.PaymentOptions => 'paymentOptions',
    inter.PlaceField.ParkingOptions => 'parkingOptions',
    inter.PlaceField.EvChargeOptions => 'evChargeOptions',
    inter.PlaceField.FuelOptions => 'fuelOptions',
    inter.PlaceField.PriceRange => 'priceRange',
    inter.PlaceField.SubDestinations => 'subDestinations',
    inter.PlaceField.ContainingPlaces => 'containingPlaces',
    inter.PlaceField.AddressDescriptor => 'addressDescriptor',
    inter.PlaceField.GenerativeSummary => 'generativeSummary',
    inter.PlaceField.ReviewSummary => 'reviewSummary',
    inter.PlaceField.NeighborhoodSummary => 'neighborhoodSummary',
    inter.PlaceField.EvChargeAmenitySummary => 'evChargeAmenitySummary',
    inter.PlaceField.ConsumerAlerts => 'consumerAlerts',
    inter.PlaceField.ServesCocktails => 'servesCocktails',
    inter.PlaceField.ServesCoffee => 'servesCoffee',
    inter.PlaceField.ServesDessert => 'servesDessert',
    inter.PlaceField.GoodForChildren => 'goodForChildren',
    inter.PlaceField.AllowsDogs => 'allowsDogs',
    inter.PlaceField.Restroom => 'restroom',
    inter.PlaceField.GoodForGroups => 'goodForGroups',
    inter.PlaceField.GoodForWatchingSports => 'goodForWatchingSports',
    inter.PlaceField.LiveMusic => 'liveMusic',
    inter.PlaceField.OutdoorSeating => 'outdoorSeating',
    inter.PlaceField.MenuForChildren => 'menuForChildren',
    inter.PlaceField.PureServiceAreaBusiness => 'pureServiceAreaBusiness',
  };
}

/// Builds the `X-Goog-FieldMask` header value for a list of [inter.PlaceField]s.
///
/// When [prefix] is provided (e.g. `"places"` for search endpoints), each
/// field will be prefixed accordingly: `places.id`, `places.displayName`, etc.
String buildFieldMask(List<inter.PlaceField> fields, {String? prefix}) {
  final fieldNames = fields.map(placeFieldToApiName).toSet();
  if (prefix != null) {
    return fieldNames.map((f) => '$prefix.$f').join(',');
  }
  return fieldNames.join(',');
}

/// Parses a Places API v2 JSON response into a platform interface [inter.Place].
///
/// The JSON structure follows:
/// https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Place
inter.Place parsePlaceFromJson(Map<String, Object?> json) {
  return inter.Place(
    id: json['id'] as String?,
    address: json['formattedAddress'] as String?,
    addressComponents: _parseAddressComponents(json['addressComponents']),
    businessStatus: _parseBusinessStatus(json['businessStatus'] as String?),
    attributions: _parseAttributions(json['attributions']),
    latLng: _parseLatLng(json['location'] as Map<String, Object?>?),
    name: _parseDisplayNameText(json['displayName']),
    nameLanguageCode: _parseDisplayNameLanguage(json['displayName']),
    openingHours: _parseOpeningHours(
      json['regularOpeningHours'] as Map<String, Object?>?,
    ),
    phoneNumber: json['nationalPhoneNumber'] as String?,
    photoMetadatas: _parsePhotos(json['photos']),
    plusCode: _parsePlusCode(json['plusCode'] as Map<String, Object?>?),
    priceLevel: _parsePriceLevel(json['priceLevel'] as String?),
    rating: (json['rating'] as num?)?.toDouble(),
    types: _parseTypes(json['types']),
    userRatingsTotal: (json['userRatingCount'] as num?)?.toInt(),
    utcOffsetMinutes: (json['utcOffsetMinutes'] as num?)?.toInt(),
    viewport: _parseViewport(json['viewport'] as Map<String, Object?>?),
    websiteUri: json['websiteUri'] != null
        ? Uri.tryParse(json['websiteUri'] as String)
        : null,
    reviews: _parseReviews(json['reviews']),
    // New API fields
    displayName: _parseLocalizedText(
      json['displayName'] as Map<String, Object?>?,
    ),
    primaryType: json['primaryType'] as String?,
    primaryTypeDisplayName: _parseLocalizedText(
      json['primaryTypeDisplayName'] as Map<String, Object?>?,
    ),
    shortFormattedAddress: json['shortFormattedAddress'] as String?,
    internationalPhoneNumber: json['internationalPhoneNumber'] as String?,
    nationalPhoneNumber: json['nationalPhoneNumber'] as String?,
    adrFormatAddress: json['adrFormatAddress'] as String?,
    editorialSummary: _parseLocalizedText(
      json['editorialSummary'] as Map<String, Object?>?,
    ),
    iconBackgroundColor: json['iconBackgroundColor'] as String?,
    iconMaskBaseUri: json['iconMaskBaseUri'] as String?,
    googleMapsUri: json['googleMapsUri'] as String?,
    currentOpeningHours: _parseOpeningHours(
      json['currentOpeningHours'] as Map<String, Object?>?,
    ),
    // Boolean service attributes
    curbsidePickup: json['curbsidePickup'] as bool?,
    delivery: json['delivery'] as bool?,
    dineIn: json['dineIn'] as bool?,
    reservable: json['reservable'] as bool?,
    servesBeer: json['servesBeer'] as bool?,
    servesBreakfast: json['servesBreakfast'] as bool?,
    servesBrunch: json['servesBrunch'] as bool?,
    servesDinner: json['servesDinner'] as bool?,
    servesLunch: json['servesLunch'] as bool?,
    servesVegetarianFood: json['servesVegetarianFood'] as bool?,
    servesWine: json['servesWine'] as bool?,
    takeout: json['takeout'] as bool?,
    servesCocktails: json['servesCocktails'] as bool?,
    servesCoffee: json['servesCoffee'] as bool?,
    servesDessert: json['servesDessert'] as bool?,
    goodForChildren: json['goodForChildren'] as bool?,
    allowsDogs: json['allowsDogs'] as bool?,
    restroom: json['restroom'] as bool?,
    goodForGroups: json['goodForGroups'] as bool?,
    goodForWatchingSports: json['goodForWatchingSports'] as bool?,
    liveMusic: json['liveMusic'] as bool?,
    outdoorSeating: json['outdoorSeating'] as bool?,
    menuForChildren: json['menuForChildren'] as bool?,
    pureServiceAreaBusiness: json['pureServiceAreaBusiness'] as bool?,
  );
}

// ===== Private parsing helpers =====

List<inter.AddressComponent>? _parseAddressComponents(Object? data) {
  if (data == null) return null;
  final list = data as List;
  return list
      .map((item) {
        final map = item as Map<String, Object?>;
        return inter.AddressComponent(
          name: map['longText'] as String? ?? '',
          shortName: map['shortText'] as String? ?? '',
          types:
              (map['types'] as List?)?.map((e) => e as String).toList() ??
              const [],
        );
      })
      .toList(growable: false);
}

inter.BusinessStatus? _parseBusinessStatus(String? status) {
  if (status == null) return null;
  return switch (status.toUpperCase()) {
    'OPERATIONAL' => inter.BusinessStatus.Operational,
    'CLOSED_TEMPORARILY' => inter.BusinessStatus.ClosedTemporarily,
    'CLOSED_PERMANENTLY' => inter.BusinessStatus.ClosedPermanently,
    _ => null,
  };
}

List<String>? _parseAttributions(Object? data) {
  if (data == null) return null;
  return (data as List).map((e) => e as String).toList(growable: false);
}

inter.LatLng? _parseLatLng(Map<String, Object?>? location) {
  if (location == null) return null;
  return inter.LatLng(
    lat: (location['latitude'] as num).toDouble(),
    lng: (location['longitude'] as num).toDouble(),
  );
}

String? _parseDisplayNameText(Object? displayName) {
  if (displayName == null) return null;
  return (displayName as Map<String, Object?>)['text'] as String?;
}

String? _parseDisplayNameLanguage(Object? displayName) {
  if (displayName == null) return null;
  return (displayName as Map<String, Object?>)['languageCode'] as String?;
}

inter.OpeningHours? _parseOpeningHours(Map<String, Object?>? data) {
  if (data == null) return null;
  final periods =
      (data['periods'] as List?)
          ?.map((p) {
            final period = p as Map<String, Object?>;
            return inter.Period(
              open: _parseTimeOfWeek(period['open'] as Map<String, Object?>?)!,
              close: _parseTimeOfWeek(period['close'] as Map<String, Object?>?),
            );
          })
          .toList(growable: false) ??
      const [];
  final weekdayText =
      (data['weekdayDescriptions'] as List?)
          ?.map((e) => e as String)
          .toList(growable: false) ??
      const [];
  return inter.OpeningHours(periods: periods, weekdayText: weekdayText);
}

inter.TimeOfWeek? _parseTimeOfWeek(Map<String, Object?>? data) {
  if (data == null) return null;
  final day = (data['day'] as num).toInt();
  final hour = (data['hour'] as num?)?.toInt() ?? 0;
  final minute = (data['minute'] as num?)?.toInt() ?? 0;
  return inter.TimeOfWeek(
    day: inter.DayOfWeek.values[day],
    time: inter.PlaceLocalTime(hours: hour, minutes: minute),
  );
}

List<inter.PhotoMetadata>? _parsePhotos(Object? data) {
  if (data == null) return null;
  final list = data as List;
  return list
      .map((item) {
        final map = item as Map<String, Object?>;
        final authorAttributions = (map['authorAttributions'] as List?)
            ?.map((a) {
              final attr = a as Map<String, Object?>;
              return inter.AuthorAttribution(
                name: attr['displayName'] as String? ?? '',
                photoUri: attr['photoUri'] as String? ?? '',
                uri: attr['uri'] as String? ?? '',
              );
            })
            .toList(growable: false);
        return inter.PhotoMetadata(
          photoReference: map['name'] as String? ?? '',
          width: (map['widthPx'] as num?)?.toInt() ?? 0,
          height: (map['heightPx'] as num?)?.toInt() ?? 0,
          attributions: authorAttributions?.map((a) => a.uri).join(', ') ?? '',
          authorAttributions: authorAttributions,
          flagContentUri: map['flagContentUri'] as String?,
          googleMapsUri: map['googleMapsUri'] as String?,
        );
      })
      .toList(growable: false);
}

inter.PlusCode? _parsePlusCode(Map<String, Object?>? data) {
  if (data == null) return null;
  return inter.PlusCode(
    compoundCode: data['compoundCode'] as String? ?? '',
    globalCode: data['globalCode'] as String? ?? '',
  );
}

inter.PriceLevel? _parsePriceLevel(String? priceLevel) {
  if (priceLevel == null) return null;
  try {
    return inter.PriceLevel.fromJson(priceLevel);
  } catch (_) {
    return null;
  }
}

List<inter.PlaceType>? _parseTypes(Object? data) {
  if (data == null) return null;
  final list = data as List;
  return list
      .map((e) => (e as String).toUpperCase().toPlaceType())
      .where((t) => t != null)
      .cast<inter.PlaceType>()
      .toList(growable: false);
}

inter.LatLngBounds? _parseViewport(Map<String, Object?>? data) {
  if (data == null) return null;
  final low = data['low'] as Map<String, Object?>?;
  final high = data['high'] as Map<String, Object?>?;
  if (low == null || high == null) return null;
  return inter.LatLngBounds(
    southwest: inter.LatLng(
      lat: (low['latitude'] as num).toDouble(),
      lng: (low['longitude'] as num).toDouble(),
    ),
    northeast: inter.LatLng(
      lat: (high['latitude'] as num).toDouble(),
      lng: (high['longitude'] as num).toDouble(),
    ),
  );
}

List<inter.Review>? _parseReviews(Object? data) {
  if (data == null) return null;
  final list = data as List;
  return list
      .map((item) {
        final map = item as Map<String, Object?>;
        final authorAttr = map['authorAttribution'] as Map<String, Object?>?;
        return inter.Review(
          attribution: authorAttr?['displayName'] as String? ?? '',
          authorAttribution: inter.AuthorAttribution(
            name: authorAttr?['displayName'] as String? ?? '',
            photoUri: authorAttr?['photoUri'] as String? ?? '',
            uri: authorAttr?['uri'] as String? ?? '',
          ),
          rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
          publishTime: map['publishTime'] as String? ?? '',
          relativePublishTimeDescription:
              map['relativePublishTimeDescription'] as String? ?? '',
          originalText: _parseLocalizedTextString(
            map['originalText'] as Map<String, Object?>?,
          ),
          originalTextLanguageCode: _parseLocalizedTextLanguage(
            map['originalText'] as Map<String, Object?>?,
          ),
          text: _parseLocalizedTextString(map['text'] as Map<String, Object?>?),
          textLanguageCode: _parseLocalizedTextLanguage(
            map['text'] as Map<String, Object?>?,
          ),
        );
      })
      .toList(growable: false);
}

inter.LocalizedText? _parseLocalizedText(Map<String, Object?>? data) {
  if (data == null) return null;
  return inter.LocalizedText(
    text: data['text'] as String? ?? '',
    languageCode: data['languageCode'] as String?,
  );
}

String? _parseLocalizedTextString(Map<String, Object?>? data) {
  if (data == null) return null;
  return data['text'] as String?;
}

String? _parseLocalizedTextLanguage(Map<String, Object?>? data) {
  if (data == null) return null;
  return data['languageCode'] as String?;
}
