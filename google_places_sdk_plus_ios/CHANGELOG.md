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
