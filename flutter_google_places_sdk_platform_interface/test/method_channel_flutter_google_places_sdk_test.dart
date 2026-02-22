import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_google_places_sdk_platform_interface/flutter_google_places_sdk_platform_interface.dart';
import 'package:flutter_google_places_sdk_platform_interface/method_channel_flutter_google_places_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FlutterGooglePlacesSdkMethodChannel', () {
    const channel = MethodChannel('plugins.msh.com/flutter_google_places_sdk');
    final List<MethodCall> log = <MethodCall>[];
    final List<Future<dynamic>? Function(MethodCall call)> handlers = [];
    late FlutterGooglePlacesSdkMethodChannel places;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            for (final callback in handlers) {
              final result = callback(methodCall);
              if (result != null) {
                return result;
              }
            }
            return null;
          });
      places = FlutterGooglePlacesSdkMethodChannel();
    });

    tearDown(() {
      log.clear();
      handlers.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('initialize', () async {
      const testKey = 'my-key';
      await places.initialize(
        testKey,
        locale: const Locale('en'),
        useNewApi: true,
      );
      expect(log, <Matcher>[
        isMethodCall(
          'initialize',
          arguments: <String, Object>{
            'apiKey': testKey,
            'locale': {'country': null, 'language': 'en'},
            'useNewApi': true,
          },
        ),
      ]);
    });

    test('deinitialize', () async {
      await places.deinitialize();
      expect(log, <Matcher>[isMethodCall('deinitialize', arguments: null)]);
    });

    test('isInitialized', () async {
      await places.isInitialized();
      expect(log, <Matcher>[isMethodCall('isInitialized', arguments: null)]);
    });

    test('updateSettings', () async {
      const testKey = 'updated-key';
      const locale = Locale('fr', 'FR');
      await places.updateSettings(testKey, locale: locale, useNewApi: true);
      expect(log, <Matcher>[
        isMethodCall(
          'updateSettings',
          arguments: <String, Object>{
            'apiKey': testKey,
            'locale': {'country': 'FR', 'language': 'fr'},
            'useNewApi': true,
          },
        ),
      ]);
    });

    test('findAutocompletePredictions', () async {
      const testQuery = 'my-test-query';
      const testCountries = ['c1', 'c2'];
      const newSessionToken = true;
      // Realistic coordinates (Jerusalem)
      const origin = LatLng(lat: 31.7683, lng: 35.2137);
      const locationBias = LatLngBounds(
        southwest: LatLng(lat: 31.7, lng: 35.1),
        northeast: LatLng(lat: 31.9, lng: 35.3),
      );
      const locationRestriction = LatLngBounds(
        southwest: LatLng(lat: 31.5, lng: 34.9),
        northeast: LatLng(lat: 32.0, lng: 35.5),
      );
      await places.findAutocompletePredictions(
        testQuery,
        countries: testCountries,
        placeTypesFilter: ['(cities)'],
        newSessionToken: newSessionToken,
        origin: origin,
        locationBias: locationBias,
        locationRestriction: locationRestriction,
      );
      expect(log, <Matcher>[
        isMethodCall(
          'findAutocompletePredictions',
          arguments: <String, Object>{
            'query': testQuery,
            'countries': testCountries,
            'typesFilter': ['(cities)'],
            'newSessionToken': newSessionToken,
            'origin': origin.toJson(),
            'locationBias': locationBias.toJson(),
            'locationRestriction': locationRestriction.toJson(),
          },
        ),
      ]);
    });

    test('findAutocompletePredictions throws on empty query', () {
      expect(
        () => places.findAutocompletePredictions(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fetchPlace', () async {
      const placeId = 'my-test-place-id';
      const testFields = [PlaceField.Location, PlaceField.FormattedAddress];
      const newSessionToken = true;
      await places.fetchPlace(
        placeId,
        fields: testFields,
        newSessionToken: newSessionToken,
        regionCode: 'us',
      );
      expect(log, <Matcher>[
        isMethodCall(
          'fetchPlace',
          arguments: <String, Object>{
            'placeId': placeId,
            'fields': testFields.map((e) => e.name).toList(growable: false),
            'newSessionToken': newSessionToken,
            'regionCode': 'us',
          },
        ),
      ]);
    });

    test('fetchPlacePhoto', () async {
      const photoRef = 'http://google.com/photo/ref/1';
      const photoMetadata = PhotoMetadata(
        photoReference: photoRef,
        width: 100,
        height: 100,
        attributions: 'attr',
      );
      const maxWidth = 50;

      Future<Uint8List> createImage() async {
        final paint = Paint();
        final recorder = PictureRecorder();
        final Canvas canvas = Canvas(recorder);
        canvas.drawPaint(paint);

        final picture = recorder.endRecording();
        final image = await picture.toImage(100, 100);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        final buffer = byteData!.buffer;
        return buffer.asUint8List();
      }

      handlers.add((methodCall) {
        if (methodCall.method == 'fetchPlacePhoto') {
          return createImage();
        }
        return null;
      });

      await places.fetchPlacePhoto(
        photoMetadata,
        maxWidth: maxWidth,
        maxHeight: null,
      );

      // Filter only fetchPlacePhoto calls (handler also adds to log)
      final photoCalls = log
          .where((c) => c.method == 'fetchPlacePhoto')
          .toList();
      expect(photoCalls, hasLength(greaterThanOrEqualTo(1)));
      final call = photoCalls.first;
      expect(call.arguments['photoReference'], photoRef);
      expect(call.arguments['maxWidth'], maxWidth);
      expect(call.arguments['maxHeight'], isNull);
    });

    test('fetchPlacePhoto returns imageUrl for string response', () async {
      const photoMetadata = PhotoMetadata(
        photoReference: 'places/abc/photos/xyz',
        width: 800,
        height: 600,
        attributions: 'author',
      );

      handlers.add((methodCall) {
        if (methodCall.method == 'fetchPlacePhoto') {
          return Future.value('https://example.com/photo.jpg');
        }
        return null;
      });

      final result = await places.fetchPlacePhoto(photoMetadata);
      expect(result, isA<FetchPlacePhotoResponseImageUrl>());
    });

    test('searchByText', () async {
      const testQuery = 'my-test-query';
      // Realistic coordinates (Paris)
      const locationBias = LatLngBounds(
        southwest: LatLng(lat: 48.8, lng: 2.2),
        northeast: LatLng(lat: 48.9, lng: 2.4),
      );
      const locationRestriction = LatLngBounds(
        southwest: LatLng(lat: 48.7, lng: 2.0),
        northeast: LatLng(lat: 49.0, lng: 2.6),
      );
      await places.searchByText(
        testQuery,
        fields: [PlaceField.Id, PlaceField.DisplayName],
        openNow: true,
        regionCode: 'eu',
        rankPreference: TextSearchRankPreference.Distance,
        minRating: 1.0,
        maxResultCount: 9,
        locationBias: locationBias,
        locationRestriction: locationRestriction,
        priceLevels: [
          PriceLevel.priceLevelInexpensive,
          PriceLevel.priceLevelModerate,
          PriceLevel.priceLevelExpensive,
        ],
        strictTypeFiltering: false,
        includedType: 'test',
      );
      expect(log, <Matcher>[
        isMethodCall(
          'searchByText',
          arguments: <String, Object>{
            'textQuery': testQuery,
            'fields': ['ID', 'DISPLAY_NAME'],
            'includedType': 'test',
            'maxResultCount': 9,
            'locationBias': locationBias.toJson(),
            'locationRestriction': locationRestriction.toJson(),
            'minRating': 1.0,
            'openNow': true,
            'priceLevels': [
              'priceLevelInexpensive',
              'priceLevelModerate',
              'priceLevelExpensive',
            ],
            'rankPreference': 'DISTANCE',
            'regionCode': 'eu',
            'strictTypeFiltering': false,
          },
        ),
      ]);
    });

    test('searchByText throws on empty query', () {
      expect(
        () => places.searchByText('', fields: [PlaceField.Id]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('searchNearby', () async {
      const types = ['test1', 'test2'];
      // Realistic coordinates (New York)
      const locationRestriction = CircularBounds(
        center: LatLng(lat: 40.7128, lng: -74.0060),
        radius: 1000,
      );
      await places.searchNearby(
        fields: [PlaceField.Id, PlaceField.DisplayName],
        locationRestriction: locationRestriction,
        includedTypes: types,
        includedPrimaryTypes: types,
        excludedTypes: types,
        excludedPrimaryTypes: types,
        rankPreference: NearbySearchRankPreference.Popularity,
        maxResultCount: 3,
        regionCode: 'us',
      );

      expect(log, <Matcher>[
        isMethodCall(
          'searchNearby',
          arguments: <String, Object>{
            'fields': ['ID', 'DISPLAY_NAME'],
            'locationRestriction': locationRestriction.toJson(),
            'includedTypes': types,
            'includedPrimaryTypes': types,
            'excludedTypes': types,
            'excludedPrimaryTypes': types,
            'rankPreference': 'POPULARITY',
            'regionCode': 'us',
            'maxResultCount': 3,
          },
        ),
      ]);
    });

    test('searchNearby with minimal parameters', () async {
      const locationRestriction = CircularBounds(
        center: LatLng(lat: 40.7128, lng: -74.0060),
        radius: 500,
      );
      await places.searchNearby(
        fields: [PlaceField.Id],
        locationRestriction: locationRestriction,
      );

      expect(log, hasLength(1));
      final call = log[0];
      expect(call.method, 'searchNearby');
      expect(call.arguments['includedTypes'], isNull);
      expect(call.arguments['excludedTypes'], isNull);
      expect(call.arguments['rankPreference'], isNull);
      expect(call.arguments['maxResultCount'], isNull);
    });
  });
}

class FlutterGooglePlacesSdkPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterGooglePlacesSdkPlatform {}

class ImplementsFlutterGooglePlacesSdkPlatform extends Mock
    implements FlutterGooglePlacesSdkPlatform {}

class ExtendsFlutterGooglePlacesSdkPlatform
    extends FlutterGooglePlacesSdkPlatform {}
