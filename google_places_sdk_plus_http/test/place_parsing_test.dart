import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_sdk_plus_http/place_parsing.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart';

void main() {
  group('placeFieldToApiName', () {
    test('maps core fields correctly', () {
      expect(placeFieldToApiName(PlaceField.Id), 'id');
      expect(placeFieldToApiName(PlaceField.DisplayName), 'displayName');
      expect(
        placeFieldToApiName(PlaceField.FormattedAddress),
        'formattedAddress',
      );
      expect(placeFieldToApiName(PlaceField.Location), 'location');
      expect(placeFieldToApiName(PlaceField.Rating), 'rating');
      expect(placeFieldToApiName(PlaceField.Types), 'types');
      expect(placeFieldToApiName(PlaceField.Photos), 'photos');
      expect(placeFieldToApiName(PlaceField.Reviews), 'reviews');
    });

    test('maps opening hours fields correctly', () {
      expect(
        placeFieldToApiName(PlaceField.OpeningHours),
        'regularOpeningHours',
      );
      expect(
        placeFieldToApiName(PlaceField.CurrentOpeningHours),
        'currentOpeningHours',
      );
      expect(
        placeFieldToApiName(PlaceField.SecondaryOpeningHours),
        'regularSecondaryOpeningHours',
      );
      expect(
        placeFieldToApiName(PlaceField.CurrentSecondaryOpeningHours),
        'currentSecondaryOpeningHours',
      );
    });

    test('maps boolean service fields correctly', () {
      expect(placeFieldToApiName(PlaceField.Delivery), 'delivery');
      expect(placeFieldToApiName(PlaceField.DineIn), 'dineIn');
      expect(placeFieldToApiName(PlaceField.Takeout), 'takeout');
      expect(placeFieldToApiName(PlaceField.Reservable), 'reservable');
      expect(placeFieldToApiName(PlaceField.ServesBeer), 'servesBeer');
      expect(placeFieldToApiName(PlaceField.ServesWine), 'servesWine');
      expect(
        placeFieldToApiName(PlaceField.ServesCocktails),
        'servesCocktails',
      );
      expect(placeFieldToApiName(PlaceField.ServesCoffee), 'servesCoffee');
      expect(
        placeFieldToApiName(PlaceField.GoodForChildren),
        'goodForChildren',
      );
      expect(placeFieldToApiName(PlaceField.AllowsDogs), 'allowsDogs');
      expect(placeFieldToApiName(PlaceField.LiveMusic), 'liveMusic');
      expect(placeFieldToApiName(PlaceField.OutdoorSeating), 'outdoorSeating');
    });

    test('maps new API fields correctly', () {
      expect(placeFieldToApiName(PlaceField.PrimaryType), 'primaryType');
      expect(
        placeFieldToApiName(PlaceField.PrimaryTypeDisplayName),
        'primaryTypeDisplayName',
      );
      expect(
        placeFieldToApiName(PlaceField.ShortFormattedAddress),
        'shortFormattedAddress',
      );
      expect(placeFieldToApiName(PlaceField.GoogleMapsUri), 'googleMapsUri');
      expect(
        placeFieldToApiName(PlaceField.GoogleMapsLinks),
        'googleMapsLinks',
      );
      expect(placeFieldToApiName(PlaceField.PaymentOptions), 'paymentOptions');
      expect(placeFieldToApiName(PlaceField.ParkingOptions), 'parkingOptions');
      expect(
        placeFieldToApiName(PlaceField.EvChargeOptions),
        'evChargeOptions',
      );
      expect(placeFieldToApiName(PlaceField.FuelOptions), 'fuelOptions');
      expect(placeFieldToApiName(PlaceField.PriceRange), 'priceRange');
      expect(
        placeFieldToApiName(PlaceField.GenerativeSummary),
        'generativeSummary',
      );
      expect(placeFieldToApiName(PlaceField.ReviewSummary), 'reviewSummary');
      expect(placeFieldToApiName(PlaceField.ConsumerAlerts), 'consumerAlerts');
    });
  });

  group('buildFieldMask', () {
    test('joins fields without prefix', () {
      final result = buildFieldMask([PlaceField.Id, PlaceField.DisplayName]);
      expect(result, 'id,displayName');
    });

    test('adds prefix when provided', () {
      final result = buildFieldMask([
        PlaceField.Id,
        PlaceField.DisplayName,
      ], prefix: 'places');
      expect(result, 'places.id,places.displayName');
    });

    test('deduplicates fields that map to the same API name', () {
      // TimeZone and UtcOffset both map to 'utcOffsetMinutes'
      final result = buildFieldMask([
        PlaceField.TimeZone,
        PlaceField.UtcOffset,
      ]);
      expect(result, 'utcOffsetMinutes');
    });

    test('returns empty string for empty list', () {
      expect(buildFieldMask([]), isEmpty);
    });
  });

  group('parsePlaceFromJson', () {
    test('parses minimal JSON with only id', () {
      final place = parsePlaceFromJson({'id': 'test-place-123'});
      expect(place.id, 'test-place-123');
      expect(place.name, isNull);
      expect(place.latLng, isNull);
    });

    test('parses empty JSON', () {
      final place = parsePlaceFromJson({});
      expect(place.id, isNull);
      expect(place.name, isNull);
      expect(place.address, isNull);
    });

    test('parses displayName with text and languageCode', () {
      final place = parsePlaceFromJson({
        'displayName': {'text': 'Eiffel Tower', 'languageCode': 'en'},
      });
      expect(place.name, 'Eiffel Tower');
      expect(place.nameLanguageCode, 'en');
      expect(place.displayName?.text, 'Eiffel Tower');
      expect(place.displayName?.languageCode, 'en');
    });

    test('parses location coordinates', () {
      final place = parsePlaceFromJson({
        'location': {'latitude': 48.8584, 'longitude': 2.2945},
      });
      expect(place.latLng, isNotNull);
      expect(place.latLng!.lat, 48.8584);
      expect(place.latLng!.lng, 2.2945);
    });

    test('parses formattedAddress', () {
      final place = parsePlaceFromJson({
        'formattedAddress': '5 Avenue Anatole France, 75007 Paris',
      });
      expect(place.address, '5 Avenue Anatole France, 75007 Paris');
    });

    test('parses addressComponents', () {
      final place = parsePlaceFromJson({
        'addressComponents': [
          {
            'longText': 'Paris',
            'shortText': 'Paris',
            'types': ['locality', 'political'],
          },
          {
            'longText': 'France',
            'shortText': 'FR',
            'types': ['country', 'political'],
          },
        ],
      });
      expect(place.addressComponents, hasLength(2));
      expect(place.addressComponents![0].name, 'Paris');
      expect(place.addressComponents![0].shortName, 'Paris');
      expect(place.addressComponents![0].types, ['locality', 'political']);
      expect(place.addressComponents![1].shortName, 'FR');
    });

    test('parses businessStatus', () {
      final operational = parsePlaceFromJson({'businessStatus': 'OPERATIONAL'});
      expect(operational.businessStatus, BusinessStatus.Operational);

      final closedTemp = parsePlaceFromJson({
        'businessStatus': 'CLOSED_TEMPORARILY',
      });
      expect(closedTemp.businessStatus, BusinessStatus.ClosedTemporarily);

      final closedPerm = parsePlaceFromJson({
        'businessStatus': 'CLOSED_PERMANENTLY',
      });
      expect(closedPerm.businessStatus, BusinessStatus.ClosedPermanently);

      final unknown = parsePlaceFromJson({'businessStatus': 'SOMETHING_ELSE'});
      expect(unknown.businessStatus, isNull);
    });

    test('parses rating and userRatingCount', () {
      final place = parsePlaceFromJson({
        'rating': 4.6,
        'userRatingCount': 1234,
      });
      expect(place.rating, 4.6);
      expect(place.userRatingsTotal, 1234);
    });

    test('parses plusCode', () {
      final place = parsePlaceFromJson({
        'plusCode': {
          'globalCode': '8FW4V75V+8Q',
          'compoundCode': 'V75V+8Q Paris, France',
        },
      });
      expect(place.plusCode, isNotNull);
      expect(place.plusCode!.globalCode, '8FW4V75V+8Q');
      expect(place.plusCode!.compoundCode, 'V75V+8Q Paris, France');
    });

    test('parses viewport', () {
      final place = parsePlaceFromJson({
        'viewport': {
          'low': {'latitude': 48.0, 'longitude': 2.0},
          'high': {'latitude': 49.0, 'longitude': 3.0},
        },
      });
      expect(place.viewport, isNotNull);
      expect(place.viewport!.southwest.lat, 48.0);
      expect(place.viewport!.southwest.lng, 2.0);
      expect(place.viewport!.northeast.lat, 49.0);
      expect(place.viewport!.northeast.lng, 3.0);
    });

    test('parses openingHours with periods and weekdayDescriptions', () {
      final place = parsePlaceFromJson({
        'regularOpeningHours': {
          'periods': [
            {
              'open': {'day': 1, 'hour': 9, 'minute': 30},
              'close': {'day': 1, 'hour': 17, 'minute': 0},
            },
          ],
          'weekdayDescriptions': ['Monday: 9:30 AM – 5:00 PM'],
        },
      });
      expect(place.openingHours, isNotNull);
      expect(place.openingHours!.periods, hasLength(1));
      expect(place.openingHours!.periods![0].open!.day, DayOfWeek.Monday);
      expect(place.openingHours!.periods![0].open!.time!.hours, 9);
      expect(place.openingHours!.periods![0].open!.time!.minutes, 30);
      expect(place.openingHours!.periods![0].close!.time!.hours, 17);
      expect(place.openingHours!.weekdayText, ['Monday: 9:30 AM – 5:00 PM']);
    });

    test('parses photos with author attributions', () {
      final place = parsePlaceFromJson({
        'photos': [
          {
            'name': 'places/abc/photos/xyz',
            'widthPx': 1920,
            'heightPx': 1080,
            'authorAttributions': [
              {
                'displayName': 'John Doe',
                'photoUri': 'https://example.com/photo.jpg',
                'uri': 'https://example.com/author',
              },
            ],
            'flagContentUri': 'https://example.com/flag',
            'googleMapsUri': 'https://maps.google.com/photo',
          },
        ],
      });
      expect(place.photoMetadatas, hasLength(1));
      final photo = place.photoMetadatas![0];
      expect(photo.photoReference, 'places/abc/photos/xyz');
      expect(photo.width, 1920);
      expect(photo.height, 1080);
      expect(photo.authorAttributions, hasLength(1));
      expect(photo.authorAttributions![0].name, 'John Doe');
      expect(photo.flagContentUri, 'https://example.com/flag');
      expect(photo.googleMapsUri, 'https://maps.google.com/photo');
    });

    test('parses reviews', () {
      final place = parsePlaceFromJson({
        'reviews': [
          {
            'authorAttribution': {
              'displayName': 'Jane',
              'photoUri': 'https://example.com/jane.jpg',
              'uri': 'https://example.com/jane',
            },
            'rating': 5.0,
            'publishTime': '2024-01-01T00:00:00Z',
            'relativePublishTimeDescription': '1 month ago',
            'originalText': {'text': 'Great!', 'languageCode': 'en'},
            'text': {'text': 'Great place!', 'languageCode': 'en'},
          },
        ],
      });
      expect(place.reviews, hasLength(1));
      expect(place.reviews![0].attribution, 'Jane');
      expect(place.reviews![0].rating, 5.0);
      expect(place.reviews![0].originalText, 'Great!');
      expect(place.reviews![0].text, 'Great place!');
      expect(place.reviews![0].textLanguageCode, 'en');
    });

    test('parses types as PlaceType enums', () {
      final place = parsePlaceFromJson({
        'types': ['restaurant', 'food', 'point_of_interest'],
      });
      expect(place.types, isNotNull);
      expect(place.types!.length, greaterThanOrEqualTo(1));
      expect(place.types!, contains(PlaceType.RESTAURANT));
    });

    test('parses websiteUri', () {
      final place = parsePlaceFromJson({
        'websiteUri': 'https://www.example.com',
      });
      expect(place.websiteUri, isNotNull);
      expect(place.websiteUri.toString(), 'https://www.example.com');
    });

    test('parses boolean service attributes', () {
      final place = parsePlaceFromJson({
        'delivery': true,
        'dineIn': false,
        'takeout': true,
        'reservable': true,
        'servesBeer': false,
        'servesWine': true,
        'servesCocktails': true,
        'servesCoffee': false,
        'servesDessert': true,
        'goodForChildren': true,
        'allowsDogs': false,
        'liveMusic': true,
        'outdoorSeating': true,
        'menuForChildren': false,
        'pureServiceAreaBusiness': false,
      });
      expect(place.delivery, isTrue);
      expect(place.dineIn, isFalse);
      expect(place.takeout, isTrue);
      expect(place.reservable, isTrue);
      expect(place.servesBeer, isFalse);
      expect(place.servesWine, isTrue);
      expect(place.servesCocktails, isTrue);
      expect(place.servesCoffee, isFalse);
      expect(place.servesDessert, isTrue);
      expect(place.goodForChildren, isTrue);
      expect(place.allowsDogs, isFalse);
      expect(place.liveMusic, isTrue);
      expect(place.outdoorSeating, isTrue);
      expect(place.menuForChildren, isFalse);
      expect(place.pureServiceAreaBusiness, isFalse);
    });

    test('parses new API string fields', () {
      final place = parsePlaceFromJson({
        'primaryType': 'restaurant',
        'primaryTypeDisplayName': {'text': 'Restaurant', 'languageCode': 'en'},
        'shortFormattedAddress': 'Paris, France',
        'internationalPhoneNumber': '+33 1 23 45 67 89',
        'nationalPhoneNumber': '01 23 45 67 89',
        'adrFormatAddress': '<span>5 Avenue</span>',
        'editorialSummary': {'text': 'A great place', 'languageCode': 'en'},
        'iconBackgroundColor': '#FF9E67',
        'iconMaskBaseUri': 'https://maps.gstatic.com/icon',
        'googleMapsUri': 'https://maps.google.com/?cid=123',
      });
      expect(place.primaryType, 'restaurant');
      expect(place.primaryTypeDisplayName?.text, 'Restaurant');
      expect(place.shortFormattedAddress, 'Paris, France');
      expect(place.internationalPhoneNumber, '+33 1 23 45 67 89');
      expect(place.nationalPhoneNumber, '01 23 45 67 89');
      expect(place.adrFormatAddress, '<span>5 Avenue</span>');
      expect(place.editorialSummary?.text, 'A great place');
      expect(place.iconBackgroundColor, '#FF9E67');
      expect(place.iconMaskBaseUri, 'https://maps.gstatic.com/icon');
      expect(place.googleMapsUri, 'https://maps.google.com/?cid=123');
    });

    test('parses a complete Place JSON response', () {
      final place = parsePlaceFromJson({
        'id': 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
        'displayName': {'text': 'Eiffel Tower', 'languageCode': 'en'},
        'formattedAddress': '5 Avenue Anatole France, 75007 Paris, France',
        'location': {'latitude': 48.8584, 'longitude': 2.2945},
        'rating': 4.7,
        'userRatingCount': 250000,
        'types': ['tourist_attraction', 'point_of_interest'],
        'businessStatus': 'OPERATIONAL',
        'nationalPhoneNumber': '01 23 45 67 89',
        'utcOffsetMinutes': 60,
        'delivery': false,
        'dineIn': true,
      });
      expect(place.id, 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ');
      expect(place.name, 'Eiffel Tower');
      expect(place.address, '5 Avenue Anatole France, 75007 Paris, France');
      expect(place.latLng!.lat, 48.8584);
      expect(place.rating, 4.7);
      expect(place.userRatingsTotal, 250000);
      expect(place.businessStatus, BusinessStatus.Operational);
      expect(place.phoneNumber, '01 23 45 67 89');
      expect(place.utcOffsetMinutes, 60);
      expect(place.delivery, isFalse);
      expect(place.dineIn, isTrue);
    });
  });
}
