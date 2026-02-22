## 0.3.0

* **Breaking**: Removed `useNewApi` parameter from `initialize()` — always uses Places API (New).
* **Breaking**: Migrated all iOS API calls from Legacy to New Places API:
  * `findAutocompletePredictions` now uses `GMSAutocompleteRequest` + `fetchAutocompleteSuggestions(from:callback:)` instead of legacy `findAutocompletePredictions(fromQuery:filter:sessionToken:callback:)`
  * `fetchPlace` now uses `GMSFetchPlaceRequest` + `fetchPlace(with:callback:)` with `placeProperties` instead of legacy `fetchPlace(fromPlaceID:placeFields:sessionToken:callback:)` with bitmask fields
  * `fetchPlacePhoto` now uses `GMSFetchPhotoRequest` + `fetchPhoto(with:callback:)` with configurable `maxSize` (up to 4800x4800) instead of legacy `loadPlacePhoto(_:callback:)`
* Fix `fetchPlacePhoto` argument parsing to match method channel contract (reads `photoReference` directly instead of from nested `photoMetadata` dict)
* Upgrading `flutter_google_places_sdk_platform_interface` to `0.5.0`
* Implement `updateSettings` method for runtime API key and locale changes
* Implement `searchByText` using `GMSPlaceSearchByTextRequest`
* Implement `searchNearby` using `GMSPlaceSearchNearbyRequest`
* Fix `placeFieldFromStr()` crash — unsupported fields now return empty `GMSPlaceField()` instead of `fatalError`
* Add new field mappings: Reviews, PrimaryType, PrimaryTypeDisplayName, ShortFormattedAddress, AccessibilityOptions
* Serialize all new Place fields in `placeToMap()`: id, displayName, primaryType, primaryTypeDisplayName, shortFormattedAddress, editorialSummary, internationalPhoneNumber, iconBackgroundColor, iconMaskBaseUri, currentOpeningHours, secondaryOpeningHours, reviews, nameLanguageCode, boolean service attributes, and nil placeholders for fields unsupported by iOS SDK
* Implement `reviewToMap()` and `authorAttributionToMap()` serializers
* Add authorAttributions, flagContentUri, and googleMapsUri to `photoMetadataToMap()`
* Update podspec version and metadata
* Add Swift Package Manager (SPM) support via `Package.swift`

## 0.2.2

* Upgrading `flutter_google_places_sdk_platform_interface` to `0.3.4`

## 0.2.0

* Upgrading `flutter_google_places_sdk_platform_interface` to `0.3.1+1`

## 0.1.6+1

* Added missing , fixing 0.1.6

## 0.1.6 (broken)

* Add 'placeTypes' property in 'GMSAutocompletePrediction'

## 0.1.5

* Upgrade to Google Places 8.5.0 and Google Maps 7.1.0 

## 0.1.4

* Update Google Places to 8.3.0

## 0.1.3

* Upgrading `flutter_google_places_sdk_platform_interface` to `0.2.7`
* Updating GooglePlaces version restrictions to minimum 7.1.0
* Updating minimum iOS platform to 13.0
* Updating sdk minimum to 2.17.0

## 0.1.2+4

* Implements latLngBoundsToMap

## 0.1.2+3

* Updating platform interface to 0.2.4+3

## 0.1.2+2

* Using locationBias and locationRestriction

## 0.1.2+1

* Send viewport parameter

## 0.1.2

* Upgraded platform interface to 0.2.4+ and implemented fetchPlacePhoto

## 0.1.1

* Upgraded platform interface to 0.2.3 and implemented

## 0.1.0

* Initial implementation for iOS - extracted
