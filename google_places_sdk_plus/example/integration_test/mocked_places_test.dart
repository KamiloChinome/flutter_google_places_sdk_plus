// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';
import 'package:integration_test/integration_test.dart';

/// A mock platform that returns canned data without any real API or
/// MethodChannel calls.  Works on every host (Linux, macOS, Windows …).
class _MockPlatform extends FlutterGooglePlacesSdkPlatform {
  FindAutocompletePredictionsResponse? autocompleteResponse;
  FetchPlaceResponse? fetchPlaceResponse;
  SearchByTextResponse? searchByTextResponse;
  SearchNearbyResponse? searchNearbyResponse;
  bool initialized = false;
  Exception? exceptionToThrow;

  @override
  Future<void> initialize(String apiKey, {Locale? locale}) async {
    initialized = true;
  }

  @override
  Future<bool?> isInitialized() async => initialized;

  @override
  Future<void> updateSettings(String apiKey, {Locale? locale}) async {}

  @override
  Future<FindAutocompletePredictionsResponse> findAutocompletePredictions(
    String query, {
    List<String>? countries,
    List<String> placeTypesFilter = const [],
    bool? newSessionToken,
    LatLng? origin,
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return autocompleteResponse ??
        const FindAutocompletePredictionsResponse([]);
  }

  @override
  Future<FetchPlaceResponse> fetchPlace(
    String placeId, {
    required List<PlaceField> fields,
    bool? newSessionToken,
    String? regionCode,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return fetchPlaceResponse ?? const FetchPlaceResponse(null);
  }

  @override
  Future<FetchPlacePhotoResponse> fetchPlacePhoto(
    PhotoMetadata photoMetadata, {
    int? maxWidth,
    int? maxHeight,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<SearchByTextResponse> searchByText(
    String textQuery, {
    required List<PlaceField> fields,
    String? includedType,
    int? maxResultCount,
    LatLngBounds? locationBias,
    LatLngBounds? locationRestriction,
    double? minRating,
    bool? openNow,
    List<PriceLevel>? priceLevels,
    TextSearchRankPreference? rankPreference,
    String? regionCode,
    bool? strictTypeFiltering,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return searchByTextResponse ?? const SearchByTextResponse([]);
  }

  @override
  Future<SearchNearbyResponse> searchNearby({
    required List<PlaceField> fields,
    required CircularBounds locationRestriction,
    List<String>? includedTypes,
    List<String>? includedPrimaryTypes,
    List<String>? excludedTypes,
    List<String>? excludedPrimaryTypes,
    NearbySearchRankPreference? rankPreference,
    String? regionCode,
    int? maxResultCount,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return searchNearbyResponse ?? const SearchNearbyResponse([]);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FlutterGooglePlacesSdk sdk;
  late _MockPlatform mockPlatform;

  const mockPrediction = AutocompletePrediction(
    placeId: 'ChIJN1t_tDeuEmsRUsoyG83frY4',
    distanceMeters: 12345,
    primaryText: 'Test Place',
    secondaryText: 'Test City',
    fullText: 'Test Place, Test City',
  );

  final mockPlace = Place(
    id: 'ChIJN1t_tDeuEmsRUsoyG83frY4',
    latLng: const LatLng(lat: -33.8688, lng: 151.2093),
    address: '123 Test St, Sydney, Australia',
    addressComponents: const [],
    businessStatus: BusinessStatus.Operational,
    attributions: const [],
    name: 'Sydney Opera House',
    phoneNumber: '+61 2 9250 7111',
    photoMetadatas: const [],
    rating: 4.6,
    userRatingsTotal: 50000,
    utcOffsetMinutes: 600,
    websiteUri: Uri.parse('https://www.sydneyoperahouse.com'),
    reviews: const [],
  );

  setUp(() {
    mockPlatform = _MockPlatform()
      ..autocompleteResponse = const FindAutocompletePredictionsResponse([
        mockPrediction,
      ])
      ..fetchPlaceResponse = FetchPlaceResponse(mockPlace)
      ..searchByTextResponse = SearchByTextResponse([mockPlace])
      ..searchNearbyResponse = SearchNearbyResponse([mockPlace]);

    FlutterGooglePlacesSdk.platform = mockPlatform;
    sdk = FlutterGooglePlacesSdk('test-api-key');
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
      final emptyPlatform = _MockPlatform()
        ..autocompleteResponse = const FindAutocompletePredictionsResponse([]);
      FlutterGooglePlacesSdk.platform = emptyPlatform;

      final newSdk = FlutterGooglePlacesSdk('test-key');
      final result = await newSdk.findAutocompletePredictions('xyzabc123');
      expect(result.predictions, isEmpty);
    });

    testWidgets('fetchPlace handles PlatformException', (
      WidgetTester tester,
    ) async {
      final errorPlatform = _MockPlatform()
        ..exceptionToThrow = PlatformException(
          code: 'API_ERROR_PLACE',
          message: 'Place not found',
        );
      FlutterGooglePlacesSdk.platform = errorPlatform;

      final newSdk = FlutterGooglePlacesSdk('test-key');
      expect(
        () => newSdk.fetchPlace('invalid-id', fields: [PlaceField.Id]),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('searchByText with empty results', (WidgetTester tester) async {
      final emptyPlatform = _MockPlatform()
        ..searchByTextResponse = const SearchByTextResponse([]);
      FlutterGooglePlacesSdk.platform = emptyPlatform;

      final newSdk = FlutterGooglePlacesSdk('test-key');
      final result = await newSdk.searchByText(
        'nonexistent place xyz',
        fields: [PlaceField.Id],
      );
      expect(result.places, isEmpty);
    });
  });
}
