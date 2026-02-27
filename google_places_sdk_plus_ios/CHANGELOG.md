## 0.3.2

* Fix: session token was not cleared after `fetchPlace()`, causing subsequent autocomplete searches to reuse a stale token and break session billing boundaries. The token is now invalidated after every `fetchPlace()` call.

## 0.3.1

* Fix: Corrected Swift generated header import in `FlutterGooglePlacesSdkIosPlugin.m` — was referencing old module name `flutter_google_places_sdk_ios` instead of `google_places_sdk_plus_ios`, causing `'flutter_google_places_sdk_ios-Swift.h' file not found` build error.

## 0.3.0

Initial release of `google_places_sdk_plus_ios`.

* Full Google Places API (New) support — exclusively targets the new API
* Removed `useNewApi` parameter from `initialize()`
* Migrated all iOS API calls from Legacy to New Places API:
  * `findAutocompletePredictions` uses `GMSAutocompleteRequest` + `fetchAutocompleteSuggestions`
  * `fetchPlace` uses `GMSFetchPlaceRequest` + `fetchPlace` with `placeProperties`
  * `fetchPlacePhoto` uses `GMSFetchPhotoRequest` + `fetchPhoto` with configurable `maxSize`
* Implements `searchByText` and `searchNearby`
* Implements `updateSettings` for runtime API key and locale changes
* Serializes all new Place fields including reviews, service attributes, and photo metadata
* Swift Package Manager (SPM) support via `Package.swift`

> Forked from [flutter_google_places_sdk](https://pub.dev/packages/flutter_google_places_sdk) by Matan Shukry.
