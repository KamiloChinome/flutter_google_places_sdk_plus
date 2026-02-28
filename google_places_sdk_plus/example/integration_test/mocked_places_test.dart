// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'plugins.msh.com/google_places_sdk_plus';

  late FlutterGooglePlacesSdk sdk;

  const mockPrediction = <String, dynamic>{
    'placeId': 'ChIJN1t_tDeuEmsRUsoyG83frY4',
    'distanceMeters': 12345,
    'primaryText': 'Test Place',
    'secondaryText': 'Test City',
    'fullText': 'Test Place, Test City',
  };

  const mockPlace = <String, dynamic>{
    'id': 'ChIJN1t_tDeuEmsRUsoyG83frY4',
    'latLng': {'lat': -33.8688, 'lng': 151.2093},
    'address': '123 Test St, Sydney, Australia',
    'addressComponents': <Map<String, dynamic>>[],
    'businessStatus': 'OPERATIONAL',
    'attributions': <String>[],
    'name': 'Sydney Opera House',
    'openingHours': null,
    'phoneNumber': '+61 2 9250 7111',
    'photoMetadatas': <Map<String, dynamic>>[],
    'plusCode': null,
    'priceLevel': null,
    'rating': 4.6,
    'types': <String>['point_of_interest', 'establishment'],
    'userRatingsTotal': 50000,
    'utcOffsetMinutes': 600,
    'viewport': null,
    'websiteUri': 'https://www.sydneyoperahouse.com',
    'reviews': <Map<String, dynamic>>[],
  };

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall call,
        ) async {
          switch (call.method) {
            case 'initialize':
              return null;
            case 'isInitialized':
              return true;
            case 'findAutocompletePredictions':
              return <Map<String, dynamic>>[mockPrediction];
            case 'fetchPlace':
              return mockPlace;
            case 'fetchPlacePhoto':
              return 'https://example.com/photo.jpg';
            case 'searchByText':
              return <Map<String, dynamic>>[mockPlace];
            case 'searchNearby':
              return <Map<String, dynamic>>[mockPlace];
            default:
              return null;
          }
        });
    sdk = FlutterGooglePlacesSdk('test-api-key');
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), null);
  });

  group('Mocked Integration Tests', () {
    testWidgets('initialize and check isInitialized', (
      WidgetTester tester,
    ) async {
      final result = await sdk.isInitialized();
      expect(result, isTrue);
    });

    testWidgets('findAutocompletePredictions returns predictions', (
      WidgetTester tester,
    ) async {
      final result = await sdk.findAutocompletePredictions('Sydney');
      expect(result.predictions, isNotEmpty);
      expect(result.predictions.first.placeId, 'ChIJN1t_tDeuEmsRUsoyG83frY4');
      expect(result.predictions.first.primaryText, 'Test Place');
      expect(result.predictions.first.secondaryText, 'Test City');
      expect(result.predictions.first.fullText, 'Test Place, Test City');
      expect(result.predictions.first.distanceMeters, 12345);
    });

    testWidgets('fetchPlace returns place details', (
      WidgetTester tester,
    ) async {
      final result = await sdk.fetchPlace(
        'ChIJN1t_tDeuEmsRUsoyG83frY4',
        fields: [PlaceField.Id, PlaceField.DisplayName, PlaceField.Location],
      );
      expect(result.place, isNotNull);
      expect(result.place!.id, 'ChIJN1t_tDeuEmsRUsoyG83frY4');
      expect(result.place!.name, 'Sydney Opera House');
      expect(result.place!.latLng, isNotNull);
      expect(result.place!.latLng!.lat, -33.8688);
      expect(result.place!.latLng!.lng, 151.2093);
    });

    testWidgets('searchByText returns places', (WidgetTester tester) async {
      final result = await sdk.searchByText(
        'restaurants',
        fields: [PlaceField.Id, PlaceField.DisplayName],
      );
      expect(result.places, isNotEmpty);
      expect(result.places.first.id, 'ChIJN1t_tDeuEmsRUsoyG83frY4');
    });

    testWidgets('searchNearby returns places', (WidgetTester tester) async {
      final result = await sdk.searchNearby(
        fields: [PlaceField.Id, PlaceField.DisplayName],
        locationRestriction: const CircularBounds(
          center: LatLng(lat: -33.8688, lng: 151.2093),
          radius: 500,
        ),
      );
      expect(result.places, isNotEmpty);
      expect(result.places.first.id, 'ChIJN1t_tDeuEmsRUsoyG83frY4');
    });

    testWidgets('findAutocompletePredictions with all parameters', (
      WidgetTester tester,
    ) async {
      final result = await sdk.findAutocompletePredictions(
        'coffee shop',
        countries: ['US'],
        placeTypesFilter: ['cafe'],
        newSessionToken: true,
        origin: const LatLng(lat: 37.7749, lng: -122.4194),
        locationBias: const LatLngBounds(
          southwest: LatLng(lat: 37.7, lng: -122.5),
          northeast: LatLng(lat: 37.8, lng: -122.3),
        ),
      );
      expect(result.predictions, isNotEmpty);
    });

    testWidgets('fetchPlace with newSessionToken', (WidgetTester tester) async {
      final result = await sdk.fetchPlace(
        'test-place-id',
        fields: [PlaceField.Id],
        newSessionToken: true,
      );
      expect(result.place, isNotNull);
    });
  });

  group('Edge case tests', () {
    testWidgets('findAutocompletePredictions with empty results', (
      WidgetTester tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall call,
          ) async {
            switch (call.method) {
              case 'initialize':
                return null;
              case 'findAutocompletePredictions':
                return <Map<String, dynamic>>[];
              default:
                return null;
            }
          });

      final newSdk = FlutterGooglePlacesSdk('test-key');
      final result = await newSdk.findAutocompletePredictions('xyzabc123');
      expect(result.predictions, isEmpty);
    });

    testWidgets('fetchPlace handles PlatformException', (
      WidgetTester tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall call,
          ) async {
            switch (call.method) {
              case 'initialize':
                return null;
              case 'fetchPlace':
                throw PlatformException(
                  code: 'API_ERROR_PLACE',
                  message: 'Place not found',
                );
              default:
                return null;
            }
          });

      final newSdk = FlutterGooglePlacesSdk('test-key');
      expect(
        () => newSdk.fetchPlace('invalid-id', fields: [PlaceField.Id]),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('searchByText with empty results', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall call,
          ) async {
            switch (call.method) {
              case 'initialize':
                return null;
              case 'searchByText':
                return <Map<String, dynamic>>[];
              default:
                return null;
            }
          });

      final newSdk = FlutterGooglePlacesSdk('test-key');
      final result = await newSdk.searchByText(
        'nonexistent place xyz',
        fields: [PlaceField.Id],
      );
      expect(result.places, isEmpty);
    });
  });
}
