# google_places_sdk_plus

[![pub package](https://img.shields.io/pub/v/google_places_sdk_plus.svg)](https://pub.dev/packages/google_places_sdk_plus)

A Flutter plugin for the [Google Places API (New)](https://developers.google.com/maps/documentation/places/web-service/op-overview) using native SDKs on each platform.

Originally forked from [`flutter_google_places_sdk`](https://github.com/matanshukry/flutter_google_places_sdk). This package extends the original with full Places API (New) coverage, migrates away from deprecated endpoints, and is independently maintained.

## Features

- Full Places API (New) support (~45 Place fields, 30+ place types)
- Autocomplete predictions
- Place details
- Place photos
- Search by text
- Search nearby
- Native SDK on Android and iOS, REST/HTTP on desktop, Maps JS API on web
- All platforms: Android, iOS, Web, Linux, macOS, Windows

## Installation

```yaml
dependencies:
  google_places_sdk_plus: ^0.5.0
```

## Quick Start

```dart
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';

// Initialize
final places = FlutterGooglePlacesSdk('YOUR_API_KEY');

// Autocomplete
final predictions = await places.findAutocompletePredictions('pizza');

// Place Details
final place = await places.fetchPlace(
  predictions.predictions.first.placeId,
  fields: [PlaceField.DisplayName, PlaceField.Location],
);

// Search by text
final results = await places.searchByText(
  'restaurants near Central Park',
  fields: [PlaceField.DisplayName, PlaceField.Rating],
);

// Search nearby
final nearby = await places.searchNearby(
  locationRestriction: CircularBounds(
    center: LatLng(lat: 40.7128, lng: -74.0060),
    radius: 500,
  ),
  fields: [PlaceField.DisplayName, PlaceField.PriceLevel],
);
```

## Web Usage

When using web support, enable the Maps JavaScript API in Google Cloud:

https://developers.google.com/maps/documentation/javascript/get-api-key

**Limitations:**
- Location restriction is not supported on web. See [Google issue tracker](https://issuetracker.google.com/issues/36219203).

## Why native SDKs?

Other plugins use HTTP web requests rather than the native SDK. Google allows you to restrict your API key to specific Android/iOS applications, but that only works with the native SDK. When using HTTP requests, your API key cannot be properly restricted.

This plugin uses native SDKs on mobile platforms for better security, and falls back to HTTP/REST on desktop platforms.

## Package Structure

This is a federated plugin. The app-facing package (`google_places_sdk_plus`) depends on the following packages:

| Package | Description |
|---------|-------------|
| [`google_places_sdk_plus_platform_interface`](https://pub.dev/packages/google_places_sdk_plus_platform_interface) | Shared types, models, and platform interface |
| [`google_places_sdk_plus_android`](https://pub.dev/packages/google_places_sdk_plus_android) | Android implementation (Kotlin, native Places SDK) |
| [`google_places_sdk_plus_ios`](https://pub.dev/packages/google_places_sdk_plus_ios) | iOS implementation (Swift, native Places SDK) |
| [`google_places_sdk_plus_web`](https://pub.dev/packages/google_places_sdk_plus_web) | Web implementation (Maps JavaScript API) |
| [`google_places_sdk_plus_http`](https://pub.dev/packages/google_places_sdk_plus_http) | HTTP/REST implementation (used by desktop) |
| [`google_places_sdk_plus_linux`](https://pub.dev/packages/google_places_sdk_plus_linux) | Linux (delegates to HTTP) |
| [`google_places_sdk_plus_macos`](https://pub.dev/packages/google_places_sdk_plus_macos) | macOS (delegates to HTTP) |
| [`google_places_sdk_plus_windows`](https://pub.dev/packages/google_places_sdk_plus_windows) | Windows (delegates to HTTP) |

## License

BSD-3-Clause. Original copyright (c) 2023 Matan Shukry. See [LICENSE](LICENSE) for details.
