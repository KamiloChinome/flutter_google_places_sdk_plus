## 0.4.0

Initial release of `google_places_sdk_plus_android`.

* Full Google Places API (New) support — exclusively targets the new API
* Removed `useNewApi` parameter from `initialize()` and `updateSettings()`
* Serializes all new Places API (New) fields: primaryType, primaryTypeDisplayName, shortFormattedAddress, editorialSummary, googleMapsUri, googleMapsLinks, timeZone, postalAddress, currentOpeningHours, secondaryOpeningHours, and all boolean service attributes
* Serializes complex types: paymentOptions, parkingOptions, evChargeOptions, fuelOptions, accessibilityOptions, priceRange
* Serializes AI/generative summaries: generativeSummary, reviewSummary, neighborhoodSummary, evChargeAmenitySummary
* Serializes relational data: subDestinations, containingPlaces, addressDescriptor, consumerAlerts
* authorAttributions, flagContentUri, and googleMapsUri in photo metadata
* Photo metadata cached on the Android side

> Forked from [flutter_google_places_sdk](https://pub.dev/packages/flutter_google_places_sdk) by Matan Shukry.
