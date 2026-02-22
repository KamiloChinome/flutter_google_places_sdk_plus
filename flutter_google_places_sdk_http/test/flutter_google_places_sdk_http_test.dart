import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk_http/flutter_google_places_sdk_http.dart';
import 'package:flutter_google_places_sdk_platform_interface/flutter_google_places_sdk_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kApiKey = 'test-api-key';
  const kLocale = Locale('en', 'US');

  /// Creates a [MockClient] that returns [body] with [statusCode].
  MockClient mockClient(
    String body, {
    int statusCode = 200,
    void Function(http.Request)? onRequest,
  }) {
    return MockClient((request) async {
      onRequest?.call(request as http.Request);
      return http.Response(body, statusCode);
    });
  }

  group('FlutterGooglePlacesSdkHttpPlugin', () {
    group('lifecycle', () {
      test('isInitialized returns false before initialize', () async {
        final plugin = FlutterGooglePlacesSdkHttpPlugin();
        expect(await plugin.isInitialized(), isFalse);
      });

      test('isInitialized returns true after initialize', () async {
        final plugin = FlutterGooglePlacesSdkHttpPlugin();
        await plugin.initialize(kApiKey);
        expect(await plugin.isInitialized(), isTrue);
      });

      test('isInitialized returns false after deinitialize', () async {
        final plugin = FlutterGooglePlacesSdkHttpPlugin();
        await plugin.initialize(kApiKey);
        await plugin.deinitialize();
        expect(await plugin.isInitialized(), isFalse);
      });

      test('updateSettings updates apiKey and locale', () async {
        final plugin = FlutterGooglePlacesSdkHttpPlugin();
        await plugin.initialize(kApiKey);
        await plugin.updateSettings('new-key', locale: const Locale('fr'));
        expect(await plugin.isInitialized(), isTrue);
      });
    });

    group('findAutocompletePredictions', () {
      test('sends correct request and parses response', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({
            'predictions': [
              {
                'description': 'Paris, France',
                'matched_substrings': [
                  {'length': 5, 'offset': 0},
                ],
                'structured_formatting': {
                  'main_text': 'Paris',
                  'main_text_matched_substrings': [
                    {'length': 5, 'offset': 0},
                  ],
                  'secondary_text': 'France',
                },
                'terms': [
                  {'offset': 0, 'value': 'Paris'},
                  {'offset': 7, 'value': 'France'},
                ],
                'place_id': 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
                'distance_meters': 100,
                'types': ['locality'],
              },
            ],
            'status': 'OK',
            'error_message': null,
            'info_messages': null,
          }),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey, locale: kLocale);

        final response = await plugin.findAutocompletePredictions(
          'Paris',
          countries: ['FR'],
          placeTypesFilter: ['locality'],
        );

        // Verify request
        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.headers['X-Goog-Api-Key'], kApiKey);
        expect(capturedRequest!.headers['Content-Type'], 'application/json');

        final requestBody = jsonDecode(capturedRequest!.body);
        expect(requestBody['input'], 'Paris');
        expect(requestBody['languageCode'], 'en');
        expect(requestBody['includedPrimaryTypes'], ['locality']);

        // Verify response
        expect(response.predictions, hasLength(1));
        expect(response.predictions[0].placeId, 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ');
        expect(response.predictions[0].primaryText, 'Paris');
        expect(response.predictions[0].secondaryText, 'France');
        expect(response.predictions[0].fullText, 'Paris, France');
        expect(response.predictions[0].distanceMeters, 100);
      });

      test('returns empty predictions for ZERO_RESULTS', () async {
        final client = mockClient(
          jsonEncode({
            'predictions': <dynamic>[],
            'status': 'ZERO_RESULTS',
            'error_message': null,
            'info_messages': null,
          }),
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        final response = await plugin.findAutocompletePredictions('xyzabc');
        expect(response.predictions, isEmpty);
      });

      test('throws on error status', () async {
        final client = mockClient(
          jsonEncode({
            'predictions': <dynamic>[],
            'status': 'REQUEST_DENIED',
            'error_message': 'API key invalid',
            'info_messages': null,
          }),
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        expect(
          () => plugin.findAutocompletePredictions('test'),
          throwsA(anything),
        );
      });

      test('does not include languageCode when locale is null', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({
            'predictions': <dynamic>[],
            'status': 'ZERO_RESULTS',
            'error_message': null,
            'info_messages': null,
          }),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey); // no locale

        await plugin.findAutocompletePredictions('test');

        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        expect(body.containsKey('languageCode'), isFalse);
      });
    });

    group('fetchPlace', () {
      test('sends correct request and parses response', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({
            'id': 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
            'displayName': {'text': 'Eiffel Tower', 'languageCode': 'en'},
            'formattedAddress': '5 Avenue Anatole France, Paris',
            'location': {'latitude': 48.8584, 'longitude': 2.2945},
          }),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey, locale: kLocale);

        final response = await plugin.fetchPlace(
          'ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
          fields: [
            PlaceField.Id,
            PlaceField.DisplayName,
            PlaceField.FormattedAddress,
            PlaceField.Location,
          ],
        );

        // Verify request
        expect(capturedRequest!.method, 'GET');
        expect(
          capturedRequest!.url.path,
          '/v1/places/ChIJD7fiBh9u5kcRYJSMaMOCCwQ',
        );
        expect(capturedRequest!.headers['X-Goog-Api-Key'], kApiKey);
        expect(capturedRequest!.headers['X-Goog-FieldMask'], contains('id'));
        expect(
          capturedRequest!.headers['X-Goog-FieldMask'],
          contains('displayName'),
        );
        expect(capturedRequest!.url.queryParameters['languageCode'], 'en');

        // Verify response
        final place = response.place;
        expect(place, isNotNull);
        expect(place!.id, 'ChIJD7fiBh9u5kcRYJSMaMOCCwQ');
        expect(place.name, 'Eiffel Tower');
        expect(place.latLng!.lat, 48.8584);
      });

      test('includes regionCode in query parameters', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({'id': 'test'}),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        await plugin.fetchPlace(
          'test-id',
          fields: [PlaceField.Id],
          regionCode: 'FR',
        );

        expect(capturedRequest!.url.queryParameters['regionCode'], 'FR');
      });

      test('throws on HTTP error', () async {
        final client = mockClient('{"error": "Not found"}', statusCode: 404);

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        expect(
          () => plugin.fetchPlace('bad-id', fields: [PlaceField.Id]),
          throwsA(isA<String>()),
        );
      });
    });

    group('fetchPlacePhoto', () {
      test('sends correct request and returns image URL', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({'photoUri': 'https://lh3.googleusercontent.com/photo'}),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        const photoMetadata = PhotoMetadata(
          photoReference: 'places/abc/photos/xyz',
          width: 1920,
          height: 1080,
          attributions: '',
        );

        final response = await plugin.fetchPlacePhoto(
          photoMetadata,
          maxWidth: 400,
          maxHeight: 300,
        );

        // Verify request
        expect(capturedRequest!.method, 'GET');
        expect(capturedRequest!.url.path, '/v1/places/abc/photos/xyz/media');
        expect(capturedRequest!.url.queryParameters['key'], kApiKey);
        expect(capturedRequest!.url.queryParameters['maxWidthPx'], '400');
        expect(capturedRequest!.url.queryParameters['maxHeightPx'], '300');
        expect(
          capturedRequest!.url.queryParameters['skipHttpRedirect'],
          'true',
        );

        // Verify response
        expect(response, isA<FetchPlacePhotoResponseImageUrl>());
        final imageUrl = response as FetchPlacePhotoResponseImageUrl;
        expect(imageUrl.imageUrl, 'https://lh3.googleusercontent.com/photo');
      });

      test('throws on missing photoUri in response', () async {
        final client = mockClient(jsonEncode({}));

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        const photoMetadata = PhotoMetadata(
          photoReference: 'places/abc/photos/xyz',
          width: 100,
          height: 100,
          attributions: '',
        );

        expect(
          () => plugin.fetchPlacePhoto(photoMetadata),
          throwsA(contains('No photoUri')),
        );
      });

      test('throws on HTTP error', () async {
        final client = mockClient('Server error', statusCode: 500);

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        const photoMetadata = PhotoMetadata(
          photoReference: 'places/abc/photos/xyz',
          width: 100,
          height: 100,
          attributions: '',
        );

        expect(
          () => plugin.fetchPlacePhoto(photoMetadata),
          throwsA(contains('Failed to fetch photo')),
        );
      });
    });

    group('searchByText', () {
      test('sends correct request and parses response', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({
            'places': [
              {
                'id': 'place-1',
                'displayName': {'text': 'Restaurant A', 'languageCode': 'en'},
              },
              {
                'id': 'place-2',
                'displayName': {'text': 'Restaurant B', 'languageCode': 'en'},
              },
            ],
          }),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey, locale: kLocale);

        final response = await plugin.searchByText(
          'restaurants in Paris',
          fields: [PlaceField.Id, PlaceField.DisplayName],
          includedType: 'restaurant',
          maxResultCount: 5,
          minRating: 4.0,
          openNow: true,
          rankPreference: TextSearchRankPreference.Distance,
          regionCode: 'FR',
          strictTypeFiltering: true,
          priceLevels: [
            PriceLevel.priceLevelModerate,
            PriceLevel.priceLevelExpensive,
          ],
        );

        // Verify request
        expect(capturedRequest!.method, 'POST');
        expect(capturedRequest!.url.path, '/v1/places:searchText');
        expect(
          capturedRequest!.headers['X-Goog-FieldMask'],
          contains('places.id'),
        );

        final body = jsonDecode(capturedRequest!.body);
        expect(body['textQuery'], 'restaurants in Paris');
        expect(body['includedType'], 'restaurant');
        expect(body['maxResultCount'], 5);
        expect(body['minRating'], 4.0);
        expect(body['openNow'], isTrue);
        expect(body['rankPreference'], 'DISTANCE');
        expect(body['regionCode'], 'FR');
        expect(body['strictTypeFiltering'], isTrue);
        expect(body['priceLevels'], contains('PRICE_LEVEL_MODERATE'));
        expect(body['priceLevels'], contains('PRICE_LEVEL_EXPENSIVE'));
        expect(body['languageCode'], 'en');

        // Verify response
        expect(response.places, hasLength(2));
        expect(response.places[0].id, 'place-1');
        expect(response.places[0].name, 'Restaurant A');
        expect(response.places[1].id, 'place-2');
      });

      test('handles empty places list', () async {
        final client = mockClient(jsonEncode(<String, dynamic>{}));

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        final response = await plugin.searchByText(
          'nonexistent query',
          fields: [PlaceField.Id],
        );
        expect(response.places, isEmpty);
      });

      test('includes locationBias when provided', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode(<String, dynamic>{}),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        const bounds = LatLngBounds(
          southwest: LatLng(lat: 48.0, lng: 2.0),
          northeast: LatLng(lat: 49.0, lng: 3.0),
        );

        await plugin.searchByText(
          'test',
          fields: [PlaceField.Id],
          locationBias: bounds,
        );

        final body = jsonDecode(capturedRequest!.body);
        expect(body['locationBias']['rectangle']['low']['latitude'], 48.0);
        expect(body['locationBias']['rectangle']['high']['longitude'], 3.0);
      });
    });

    group('searchNearby', () {
      test('sends correct request and parses response', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode({
            'places': [
              {
                'id': 'nearby-1',
                'displayName': {'text': 'Cafe X', 'languageCode': 'en'},
              },
            ],
          }),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey, locale: kLocale);

        const restriction = CircularBounds(
          center: LatLng(lat: 48.8584, lng: 2.2945),
          radius: 500,
        );

        final response = await plugin.searchNearby(
          fields: [PlaceField.Id, PlaceField.DisplayName],
          locationRestriction: restriction,
          includedTypes: ['cafe'],
          excludedTypes: ['bar'],
          includedPrimaryTypes: ['cafe'],
          excludedPrimaryTypes: ['bar'],
          rankPreference: NearbySearchRankPreference.Distance,
          regionCode: 'FR',
          maxResultCount: 10,
        );

        // Verify request
        expect(capturedRequest!.method, 'POST');
        expect(capturedRequest!.url.path, '/v1/places:searchNearby');
        expect(
          capturedRequest!.headers['X-Goog-FieldMask'],
          contains('places.id'),
        );

        final body = jsonDecode(capturedRequest!.body);
        final circle = body['locationRestriction']['circle'];
        expect(circle['center']['latitude'], 48.8584);
        expect(circle['center']['longitude'], 2.2945);
        expect(circle['radius'], 500);
        expect(body['includedTypes'], ['cafe']);
        expect(body['excludedTypes'], ['bar']);
        expect(body['rankPreference'], 'DISTANCE');
        expect(body['regionCode'], 'FR');
        expect(body['maxResultCount'], 10);
        expect(body['languageCode'], 'en');

        // Verify response
        expect(response.places, hasLength(1));
        expect(response.places[0].id, 'nearby-1');
        expect(response.places[0].name, 'Cafe X');
      });

      test('omits optional lists when null', () async {
        http.Request? capturedRequest;

        final client = mockClient(
          jsonEncode(<String, dynamic>{}),
          onRequest: (req) => capturedRequest = req,
        );

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        const restriction = CircularBounds(
          center: LatLng(lat: 0, lng: 0),
          radius: 100,
        );

        await plugin.searchNearby(
          fields: [PlaceField.Id],
          locationRestriction: restriction,
        );

        final body = jsonDecode(capturedRequest!.body);
        expect(body.containsKey('includedTypes'), isFalse);
        expect(body.containsKey('excludedTypes'), isFalse);
        expect(body.containsKey('rankPreference'), isFalse);
      });
    });

    group('error handling', () {
      test('POST throws on non-2xx status', () async {
        final client = mockClient('{"error": "Bad request"}', statusCode: 400);

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        expect(
          () => plugin.searchByText('test', fields: [PlaceField.Id]),
          throwsA(isA<String>()),
        );
      });

      test('POST throws on 500 server error', () async {
        final client = mockClient('Internal Server Error', statusCode: 500);

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        expect(
          () => plugin.searchByText('test', fields: [PlaceField.Id]),
          throwsA(isA<String>()),
        );
      });

      test('GET throws on non-2xx status', () async {
        final client = mockClient('{"error": "Forbidden"}', statusCode: 403);

        final plugin = FlutterGooglePlacesSdkHttpPlugin(httpClient: client);
        await plugin.initialize(kApiKey);

        expect(
          () => plugin.fetchPlace('test', fields: [PlaceField.Id]),
          throwsA(isA<String>()),
        );
      });
    });
  });
}
