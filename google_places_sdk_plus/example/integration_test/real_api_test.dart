// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';
import 'package:integration_test/integration_test.dart';

/// Integration tests that make real API calls.
///
/// These tests require a valid Google Places API key passed via:
///   flutter test integration_test/real_api_test.dart --dart-define=API_KEY=<key>
///
/// When no API_KEY is provided, all tests are skipped.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apiKey = String.fromEnvironment('API_KEY');

  group(
    'Real API Integration Tests',
    skip: apiKey.isEmpty ? 'No API_KEY provided' : null,
    () {
      late FlutterGooglePlacesSdk sdk;

      setUp(() {
        sdk = FlutterGooglePlacesSdk(apiKey);
      });

      testWidgets('isInitialized returns true after creation',
          (WidgetTester tester) async {
        final result = await sdk.isInitialized();
        expect(result, isTrue);
      });

      testWidgets('findAutocompletePredictions returns results for known query',
          (WidgetTester tester) async {
        final result = await sdk.findAutocompletePredictions(
          'Eiffel Tower',
          countries: ['FR'],
        );
        expect(result.predictions, isNotEmpty);
        expect(
          result.predictions.any(
            (p) => p.fullText.toLowerCase().contains('eiffel'),
          ),
          isTrue,
        );
      });

      testWidgets('fetchPlace returns details for known place ID',
          (WidgetTester tester) async {
        // Eiffel Tower place ID
        final result = await sdk.fetchPlace(
          'ChIJLU7jZClu5kcR4PcOOO6p3I0',
          fields: [
            PlaceField.Id,
            PlaceField.DisplayName,
            PlaceField.Location,
            PlaceField.FormattedAddress,
          ],
        );
        expect(result.place, isNotNull);
        expect(result.place!.id, 'ChIJLU7jZClu5kcR4PcOOO6p3I0');
        expect(result.place!.name, isNotNull);
        expect(result.place!.latLng, isNotNull);
      });

      testWidgets('searchByText returns results',
          (WidgetTester tester) async {
        final result = await sdk.searchByText(
          'pizza restaurant in Paris',
          fields: [
            PlaceField.Id,
            PlaceField.DisplayName,
            PlaceField.Rating,
          ],
          maxResultCount: 5,
        );
        expect(result.places, isNotEmpty);
        expect(result.places.length, lessThanOrEqualTo(5));
      });

      testWidgets('searchNearby returns results around known location',
          (WidgetTester tester) async {
        final result = await sdk.searchNearby(
          fields: [
            PlaceField.Id,
            PlaceField.DisplayName,
          ],
          locationRestriction: const CircularBounds(
            center: LatLng(lat: 48.8584, lng: 2.2945), // Near Eiffel Tower
            radius: 500,
          ),
          maxResultCount: 5,
        );
        expect(result.places, isNotEmpty);
      });

      testWidgets('findAutocompletePredictions with empty query returns empty',
          (WidgetTester tester) async {
        // Some platforms may throw for empty queries; test graceful handling
        try {
          final result = await sdk.findAutocompletePredictions('');
          // If it doesn't throw, predictions should be empty
          expect(result.predictions, isEmpty);
        } on Exception {
          // Expected — empty query may throw on some platforms
        }
      });
    },
  );
}
