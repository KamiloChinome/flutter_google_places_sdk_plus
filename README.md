# google_places_sdk_plus

A Flutter plugin for the [Google Places API (New)](https://developers.google.com/maps/documentation/places/web-service/op-overview) using native SDKs on each platform.

Originally forked from [`flutter_google_places_sdk`](https://github.com/matanshukry/flutter_google_places_sdk) by Matan Shukry (BSD-3-Clause). This package extends the original with full Places API (New) coverage, migrates away from deprecated endpoints, and is independently maintained.

## Features

- Full Places API (New) support (~45 Place fields, 30+ types)
- Autocomplete, Place Details, Place Photos
- Search by Text, Search Nearby
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
```

## Repository Structure

| Package | Description |
|---------|-------------|
| [`google_places_sdk_plus`](google_places_sdk_plus/) | App-facing package |
| [`google_places_sdk_plus_platform_interface`](google_places_sdk_plus_platform_interface/) | Shared types, models, and platform interface |
| [`google_places_sdk_plus_android`](google_places_sdk_plus_android/) | Android implementation (Kotlin, native Places SDK) |
| [`google_places_sdk_plus_ios`](google_places_sdk_plus_ios/) | iOS implementation (Swift, native Places SDK) |
| [`google_places_sdk_plus_web`](google_places_sdk_plus_web/) | Web implementation (Maps JavaScript API) |
| [`google_places_sdk_plus_http`](google_places_sdk_plus_http/) | HTTP/REST implementation (used by desktop) |
| [`google_places_sdk_plus_linux`](google_places_sdk_plus_linux/) | Linux (delegates to HTTP) |
| [`google_places_sdk_plus_macos`](google_places_sdk_plus_macos/) | macOS (delegates to HTTP) |
| [`google_places_sdk_plus_windows`](google_places_sdk_plus_windows/) | Windows (delegates to HTTP) |

## Development

### Prerequisites

This project uses [FVM](https://fvm.app/) to pin the Flutter SDK version.

```bash
dart pub global activate fvm
fvm install
```

### Code Generation

After cloning, generate code before building:

```bash
cd google_places_sdk_plus_platform_interface
fvm dart run build_runner build --delete-conflicting-outputs

cd ../google_places_sdk_plus_http
fvm dart run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
cd google_places_sdk_plus
fvm flutter test
```

### Running the Example App

```bash
cd google_places_sdk_plus/example
fvm flutter pub get
fvm flutter run
```

## License

BSD-3-Clause. Original copyright (c) 2023 Matan Shukry. See [LICENSE](google_places_sdk_plus/LICENSE) for details.
