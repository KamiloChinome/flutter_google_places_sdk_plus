# google_places_sdk_plus

[![pub package](https://img.shields.io/pub/v/google_places_sdk_plus.svg)](https://pub.dev/packages/google_places_sdk_plus)

A Flutter plugin for the [Google Places API (New)](https://developers.google.com/maps/documentation/places/web-service/op-overview) using native SDKs on each platform.

## Features

- Autocomplete predictions
- Place details (~45 fields)
- Place photos
- Search by text
- Search nearby
- All platforms: Android, iOS, Web, Linux, macOS, Windows

## Usage

Add `google_places_sdk_plus` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  google_places_sdk_plus: ^0.5.0
```

## Quick Start

```dart
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';

final places = FlutterGooglePlacesSdk('YOUR_API_KEY');

final predictions = await places.findAutocompletePredictions('pizza');
print('Result: $predictions');
```

## Web Usage

When using web support, enable the Maps JavaScript API in Google Cloud:

https://developers.google.com/maps/documentation/javascript/get-api-key

**Limitations:**
- Location restriction is not supported on web. See [Google issue tracker](https://issuetracker.google.com/issues/36219203).

## Why native SDKs?

Other plugins use HTTP web requests rather than the native SDK. Google allows you to restrict your API key to specific Android/iOS applications, but that only works with the native SDK. When using HTTP requests, your API key cannot be properly restricted.

This plugin uses native SDKs on mobile platforms for better security, and falls back to HTTP/REST on desktop platforms.
