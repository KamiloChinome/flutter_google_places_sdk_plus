## 0.5.2

* Fix: iOS build failure — `'flutter_google_places_sdk_ios-Swift.h' file not found`. Updated `google_places_sdk_plus_ios` to `0.3.1`.

## 0.5.1

* Improved README with fork context, full feature list, and additional usage examples.

## 0.5.0

Initial release of `google_places_sdk_plus`.

* Full Google Places API (New) support — exclusively targets the new API
* Removed deprecated `useNewApi` parameter from constructor and `updateSettings()`
* All Place fields from the new API (~45 fields) including reviews, editorial summaries, service attributes, EV charge options, and more
* Autocomplete predictions, place details, place photos, text search, and nearby search
* Multi-platform support: Android, iOS, Web, Linux, macOS, Windows (via federated plugins)

> Forked from [flutter_google_places_sdk](https://pub.dev/packages/flutter_google_places_sdk) by Matan Shukry.
