# google_places_sdk_plus_web

[![pub package](https://img.shields.io/pub/v/google_places_sdk_plus_web.svg)](https://pub.dev/packages/google_places_sdk_plus_web)

The web implementation of [`google_places_sdk_plus`](https://pub.dev/packages/google_places_sdk_plus).

Uses the [Maps JavaScript API](https://developers.google.com/maps/documentation/javascript/places).

## Usage

This package is endorsed and automatically included when you depend on `google_places_sdk_plus`. You do not need to add it to your `pubspec.yaml` directly.

## Restrictions

### fetchPlacePhoto

`fetchPlacePhoto` does not use the `maxWidth`/`maxHeight` parameters since they are not available in the `getUrl` method.

### updateSettings

The `updateSettings` method will only update the language. The API key cannot be changed at runtime.
