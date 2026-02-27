package io.google_places_sdk_plus

import android.content.Context
import android.util.Log
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.AccessibilityOptions
import com.google.android.libraries.places.api.model.AddressComponent
import com.google.android.libraries.places.api.model.AuthorAttribution
import com.google.android.libraries.places.api.model.AutocompletePrediction
import com.google.android.libraries.places.api.model.AutocompleteSessionToken
import com.google.android.libraries.places.api.model.CircularBounds
import com.google.android.libraries.places.api.model.ConnectorAggregation
import com.google.android.libraries.places.api.model.ContentBlock
import com.google.android.libraries.places.api.model.EVChargeOptions
import com.google.android.libraries.places.api.model.FuelOptions
import com.google.android.libraries.places.api.model.FuelPrice
import com.google.android.libraries.places.api.model.LocalTime
import com.google.android.libraries.places.api.model.Money
import com.google.android.libraries.places.api.model.OpeningHours
import com.google.android.libraries.places.api.model.ParkingOptions
import com.google.android.libraries.places.api.model.PaymentOptions
import com.google.android.libraries.places.api.model.Period
import com.google.android.libraries.places.api.model.PhotoMetadata
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.model.PlusCode
import com.google.android.libraries.places.api.model.RectangularBounds
import com.google.android.libraries.places.api.model.Review
import com.google.android.libraries.places.api.model.SubDestination
import com.google.android.libraries.places.api.model.TimeOfWeek
import com.google.android.libraries.places.api.net.FetchPlaceRequest
import com.google.android.libraries.places.api.net.FetchResolvedPhotoUriRequest
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsResponse
import com.google.android.libraries.places.api.net.PlacesClient
import com.google.android.libraries.places.api.net.SearchByTextRequest
import com.google.android.libraries.places.api.net.SearchNearbyRequest
import com.google.common.base.CaseFormat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.Locale

/** FlutterGooglePlacesSdkPlugin */
class FlutterGooglePlacesSdkPlugin : FlutterPlugin, MethodCallHandler {
    private var client: PlacesClient? = null
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    private var photosCache = mutableMapOf<String, PhotoMetadata>()
    private var runningUid = 1

    private var lastSessionToken: AutocompleteSessionToken? = null
    private var initializedApiKey: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    private fun onAttachedToEngine(applicationContext: Context, binaryMessenger: BinaryMessenger) {
        this.applicationContext = applicationContext

        channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_INITIALIZE -> {
                val apiKey = call.argument<String>("apiKey")
                val localeMap = call.argument<Map<String, Any>>("locale")
                val locale = readLocale(localeMap)
                initialize(apiKey, locale)
                result.success(null)
            }

            METHOD_UPDATE_SETTINGS -> {
                val apiKey = call.argument<String>("apiKey")
                val localeMap = call.argument<Map<String, Any>>("locale")
                val locale = readLocale(localeMap)
                updateSettings(apiKey, locale)
                result.success(null)
            }

            METHOD_DEINITIALIZE -> {
                client = null
                initializedApiKey = null
                Places.deinitialize()
                result.success(null)
            }

            METHOD_IS_INITIALIZE -> {
                result.success(Places.isInitialized())
            }

            METHOD_FIND_AUTOCOMPLETE_PREDICTIONS -> {
                val query = call.argument<String>("query")
                val countries = call.argument<List<String>>("countries") ?: emptyList()
                val placeTypesFilter = call.argument<List<String>>("typesFilter") ?: emptyList()
                val newSessionToken = call.argument<Boolean>("newSessionToken")

                val origin = latLngFromMap(call.argument<Map<String, Any?>>("origin"))
                val locationBias =
                    rectangularBoundsFromMap(call.argument<Map<String, Any?>>("locationBias"))
                val locationRestriction =
                    rectangularBoundsFromMap(call.argument<Map<String, Any?>>("locationRestriction"))
                val sessionToken = getSessionToken(newSessionToken == true)
                val request = FindAutocompletePredictionsRequest.builder()
                    .setQuery(query)
                    .setLocationBias(locationBias)
                    .setLocationRestriction(locationRestriction)
                    .setCountries(countries)
                    .setTypesFilter(placeTypesFilter)
                    .setSessionToken(sessionToken)
                    .setOrigin(origin)
                    .build()
                client!!.findAutocompletePredictions(request).addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        lastSessionToken = request.sessionToken
                        val resultList = responseToList(task.result)
                        print("findAutoCompletePredictions Result: $resultList")
                        result.success(resultList)
                    } else {
                        val exception = task.exception
                        print("findAutoCompletePredictions Exception: $exception")
                        result.error(
                            "API_ERROR_AUTOCOMPLETE", exception?.message ?: "Unknown exception",
                            mapOf("type" to (exception?.javaClass?.toString() ?: "null"))
                        )
                    }
                }
            }

            METHOD_FETCH_PLACE -> {
                val placeId = call.argument<String>("placeId")!!
                val fields = call.argument<List<String>>("fields")?.mapNotNull { placeFieldFromStr(it) }
                    ?: emptyList()
                val regionCode = call.argument<String>("regionCode")
                val newSessionToken = call.argument<Boolean>("newSessionToken")
                val request = FetchPlaceRequest.builder(placeId, fields)
                    .setSessionToken(getSessionToken(newSessionToken == true))
                    .setRegionCode(regionCode)
                    .build()
                client!!.fetchPlace(request).addOnCompleteListener { task ->
                    // End session after fetchPlace (billing optimization).
                    // The next autocomplete call will create a new session token.
                    lastSessionToken = null

                    if (task.isSuccessful) {
                        val place = placeToMap(task.result?.place)
                        print("FetchPlace Result: $place")
                        result.success(place)
                    } else {
                        val exception = task.exception
                        print("FetchPlace Exception: $exception")
                        result.error(
                            "API_ERROR_PLACE", exception?.message ?: "Unknown exception",
                            mapOf("type" to (exception?.javaClass?.toString() ?: "null"))
                        )
                    }
                }
            }

            METHOD_FETCH_PLACE_PHOTO -> {
                val photoReference = call.argument<String>("photoReference")
                val photoMetadata = photosCache[photoReference]!!
                val maxWidth = call.argument<Int>("maxWidth")
                val maxHeight = call.argument<Int>("maxHeight")

                val request = FetchResolvedPhotoUriRequest.builder(photoMetadata)
                    .setMaxWidth(maxWidth)
                    .setMaxHeight(maxHeight)
                    .build()
                client!!.fetchResolvedPhotoUri(request).addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        val photoUri = task.result?.uri?.toString()
                        print("fetchPlacePhoto Result: $photoUri")
                        result.success(photoUri)
                    } else {
                        val exception = task.exception
                        print("fetchPlacePhoto Exception: $exception")
                        result.error(
                            "API_ERROR_PHOTO", exception?.message ?: "Unknown exception",
                            mapOf("type" to (exception?.javaClass?.toString() ?: "null"))
                        )
                    }
                }
            }

            METHOD_SEARCH_BY_TEXT -> {
                val textQuery = call.argument<String>("textQuery")!!
                val includedType = call.argument<String>("includedType")
                val maxResultCount = call.argument<Int>("maxResultCount")
                val minRating = call.argument<Double>("minRating")
                val openNow = call.argument<Boolean>("openNow") ?: false
                val priceLevels = call.argument<List<Int>>("priceLevels")
                    ?: emptyList()
                val regionCode = call.argument<String>("regionCode")
                val rankPreference = call.argument<String>("rankPreference")
                    ?.let(SearchByTextRequest.RankPreference::valueOf)
                    ?: SearchByTextRequest.RankPreference.RELEVANCE
                val strictTypeFiltering = call.argument<Boolean>("strictTypeFiltering") ?: false
                val locationBias =
                    rectangularBoundsFromMap(call.argument<Map<String, Any?>>("locationBias"))
                val locationRestriction =
                    rectangularBoundsFromMap(call.argument<Map<String, Any?>>("locationRestriction"))
                val fields = call.argument<List<String>>("fields")?.mapNotNull { placeFieldFromStr(it) }
                    ?: emptyList()
                val requestBuilder = SearchByTextRequest.builder(textQuery, fields)
                    .setIncludedType(includedType)
                    .setLocationBias(locationBias)
                    .setLocationRestriction(locationRestriction)
                    .setMaxResultCount(maxResultCount)
                    .setMinRating(minRating)
                    .setOpenNow(openNow)
                    .setPriceLevels(priceLevels)
                    .setRankPreference(rankPreference)
                    .setStrictTypeFiltering(strictTypeFiltering)
                if (regionCode != null) {
                    requestBuilder.setRegionCode(regionCode)
                }
                val request = requestBuilder.build()
                client!!.searchByText(request).addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        val places = task.result?.places?.map { placeToMap(it) }
                        print("searchByText Result: $places")
                        result.success(places)
                    } else {
                        val exception = task.exception
                        print("searchByText Exception: $exception")
                        result.error(
                            "API_ERROR_SEARCH_BY_TEXT", exception?.message ?: "Unknown exception",
                            mapOf("type" to (exception?.javaClass?.toString() ?: "null"))
                        )
                    }
                }
            }

            METHOD_NEARBY_SEARCH -> {
                val fields = call.argument<List<String>>("fields")?.mapNotNull { placeFieldFromStr(it) }
                    ?: emptyList()
                val locationRestriction =
                    circularBoundsFromMap(call.argument<Map<String, Any?>>("locationRestriction"))
                val excludedPrimaryTypes = call.argument<List<String>>("excludedPrimaryTypes")
                    ?: emptyList()
                val excludedTypes = call.argument<List<String>>("excludedTypes")
                    ?: emptyList()
                val includedPrimaryTypes = call.argument<List<String>>("includedPrimaryTypes")
                    ?: emptyList()
                val includedTypes = call.argument<List<String>>("includedTypes")
                    ?: emptyList()
                val rankPreference = SearchNearbyRequest.RankPreference.valueOf(
                    call.argument<String>("rankPreference")
                        ?: SearchNearbyRequest.RankPreference.POPULARITY.name
                )
                val regionCode = call.argument<String>("regionCode")
                val maxResultCount = call.argument<Int>("maxResultCount")
                val request = SearchNearbyRequest.builder(locationRestriction!!, fields)
                    .setExcludedPrimaryTypes(excludedPrimaryTypes)
                    .setExcludedTypes(excludedTypes)
                    .setIncludedPrimaryTypes(includedPrimaryTypes)
                    .setIncludedTypes(includedTypes)
                    .setRankPreference(rankPreference)
                    .setRegionCode(regionCode)
                    .setMaxResultCount(maxResultCount)
                    .build()
                client!!.searchNearby(request).addOnCompleteListener { task ->
                    if (task.isSuccessful) {
                        val places = task.result?.places?.map { placeToMap(it) }
                        print("searchNearby Result: $places")
                        result.success(places)
                    } else {
                        val exception = task.exception
                        print("searchNearby Exception: $exception")
                        result.error(
                            "API_ERROR_NEARBY_SEARCH", exception?.message ?: "Unknown exception",
                            mapOf("type" to (exception?.javaClass?.toString() ?: "null"))
                        )
                    }
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun rectangularBoundsFromMap(argument: Map<String, Any?>?): RectangularBounds? {
        if (argument == null) {
            return null
        }

        val latLngBounds = latLngBoundsFromMap(argument) ?: return null
        return RectangularBounds.newInstance(latLngBounds)
    }

    @Suppress("UNCHECKED_CAST")
    private fun circularBoundsFromMap(argument: Map<String, Any?>?): CircularBounds? {
        if (argument == null) {
            return null
        }

        val center = latLngFromMap(argument["center"] as? Map<String, Any?>) ?: return null
        val radius = argument["radius"] as? Double ?: 0.0

        return CircularBounds.newInstance(center, radius)
    }

    @Suppress("UNCHECKED_CAST")
    private fun latLngBoundsFromMap(argument: Map<String, Any?>?): LatLngBounds? {
        if (argument == null) {
            return null
        }

        val southWest = latLngFromMap(argument["southwest"] as? Map<String, Any?>) ?: return null
        val northEast = latLngFromMap(argument["northeast"] as? Map<String, Any?>) ?: return null

        return LatLngBounds(southWest, northEast)
    }

    private fun getSessionToken(force: Boolean): AutocompleteSessionToken {
        val localToken = lastSessionToken
        if (force || localToken == null) {
            return AutocompleteSessionToken.newInstance()
        }
        return localToken
    }

    private fun latLngFromMap(argument: Map<String, Any?>?): LatLng? {
        if (argument == null) {
            return null
        }

        val lat = argument["lat"] as Double?
        val lng = argument["lng"] as Double?
        if (lat == null || lng == null) {
            return null
        }

        return LatLng(lat, lng)
    }

    private fun placeFieldFromStr(it: String): Place.Field? {
        try {
            return when (it) {
                // Explicit mappings for fields where Dart name != Android SDK enum name
                "FormattedAddressAdr" -> Place.Field.ADR_FORMAT_ADDRESS
                "UtcOffset" -> Place.Field.UTC_OFFSET
                "Photos" -> Place.Field.PHOTO_METADATAS
                "IconMaskUrl" -> Place.Field.ICON_MASK_URL
                "GoogleMapsUri" -> Place.Field.GOOGLE_MAPS_URI
                "GoogleMapsLinks" -> Place.Field.GOOGLE_MAPS_LINKS
                "EvChargeOptions" -> Place.Field.EV_CHARGE_OPTIONS
                "EvChargeAmenitySummary" -> Place.Field.EV_CHARGE_AMENITY_SUMMARY
                else -> Place.Field.valueOf(it.toScreamingSnakeCase())
            }
        } catch (_: IllegalArgumentException) {
            Log.w(TAG, "Unsupported placeField on Android, ignoring: $it")
            return null
        }
    }

    private fun String.toScreamingSnakeCase(): String {
        return CaseFormat.UPPER_CAMEL.to(CaseFormat.UPPER_UNDERSCORE, this)
    }

    private fun responseToList(result: FindAutocompletePredictionsResponse?): List<Map<String, Any?>>? {
        if (result == null) {
            return null
        }

        return result.autocompletePredictions.map { item -> predictionToMap(item) }
    }

    private fun placeToMap(place: Place?): Map<String, Any?> {
        if (place == null) {
            return emptyMap()
        }

        return mapOf<String, Any?>(
            // ===== Legacy fields =====
            "id" to place.id,
            "address" to place.formattedAddress,
            "addressComponents" to place.addressComponents?.asList()
                ?.map { addressComponentToMap(it) },
            "businessStatus" to place.businessStatus?.name,
            "attributions" to place.attributions,
            "latLng" to latLngToMap(place.location),
            "name" to place.displayName,
            "nameLanguageCode" to place.displayNameLanguageCode,
            "openingHours" to openingHoursToMap(place.openingHours),
            "phoneNumber" to place.nationalPhoneNumber,
            "photoMetadatas" to place.photoMetadatas?.map { photoMetadataToMap(it) },
            "plusCode" to plusCodeToMap(place.plusCode),
            "priceLevel" to place.priceLevel?.let { priceLevelToString(it) },
            "rating" to place.rating,
            "types" to place.placeTypes,
            "userRatingsTotal" to place.userRatingCount,
            "utcOffsetMinutes" to place.utcOffsetMinutes,
            "viewport" to latLngBoundsToMap(place.viewport),
            "websiteUri" to place.websiteUri?.toString(),
            "reviews" to place.reviews?.map { reviewToMap(it) },

            // ===== New Places API (New) fields =====
            // Text / LocalizedText fields
            "displayName" to localizedTextToMap(place.displayName, place.displayNameLanguageCode),
            "primaryType" to place.primaryType,
            "primaryTypeDisplayName" to localizedTextToMap(place.primaryTypeDisplayName, place.primaryTypeDisplayNameLanguageCode),
            "shortFormattedAddress" to place.shortFormattedAddress,
            "internationalPhoneNumber" to place.internationalPhoneNumber,
            "nationalPhoneNumber" to place.nationalPhoneNumber,
            "adrFormatAddress" to place.adrFormatAddress,
            "editorialSummary" to localizedTextToMap(place.editorialSummary, place.editorialSummaryLanguageCode),
            "iconBackgroundColor" to place.iconBackgroundColor?.let {
                String.format("#%06X", 0xFFFFFF and it)
            },
            "iconMaskBaseUri" to place.iconMaskUrl,
            "googleMapsUri" to place.googleMapsUri?.toString(),
            "googleMapsLinks" to googleMapsLinksToMap(place),

            // Temporal fields
            "timeZone" to null,
            "currentOpeningHours" to openingHoursToMap(place.currentOpeningHours),
            "secondaryOpeningHours" to place.secondaryOpeningHours?.map { openingHoursToMap(it) },
            "currentSecondaryOpeningHours" to place.currentSecondaryOpeningHours?.map { openingHoursToMap(it) },

            // Boolean service attributes
            "curbsidePickup" to booleanAttributeToValue(place.curbsidePickup),
            "delivery" to booleanAttributeToValue(place.delivery),
            "dineIn" to booleanAttributeToValue(place.dineIn),
            "reservable" to booleanAttributeToValue(place.reservable),
            "servesBeer" to booleanAttributeToValue(place.servesBeer),
            "servesBreakfast" to booleanAttributeToValue(place.servesBreakfast),
            "servesBrunch" to booleanAttributeToValue(place.servesBrunch),
            "servesDinner" to booleanAttributeToValue(place.servesDinner),
            "servesLunch" to booleanAttributeToValue(place.servesLunch),
            "servesVegetarianFood" to booleanAttributeToValue(place.servesVegetarianFood),
            "servesWine" to booleanAttributeToValue(place.servesWine),
            "takeout" to booleanAttributeToValue(place.takeout),
            "servesCocktails" to booleanAttributeToValue(place.servesCocktails),
            "servesCoffee" to booleanAttributeToValue(place.servesCoffee),
            "servesDessert" to booleanAttributeToValue(place.servesDessert),
            "goodForChildren" to booleanAttributeToValue(place.goodForChildren),
            "allowsDogs" to booleanAttributeToValue(place.allowsDogs),
            "restroom" to booleanAttributeToValue(place.restroom),
            "goodForGroups" to booleanAttributeToValue(place.goodForGroups),
            "goodForWatchingSports" to booleanAttributeToValue(place.goodForWatchingSports),
            "liveMusic" to booleanAttributeToValue(place.liveMusic),
            "outdoorSeating" to booleanAttributeToValue(place.outdoorSeating),
            "menuForChildren" to booleanAttributeToValue(place.menuForChildren),
            "pureServiceAreaBusiness" to booleanAttributeToValue(place.pureServiceAreaBusiness),

            // Complex option types
            "accessibilityOptions" to accessibilityOptionsToMap(place.accessibilityOptions),
            "paymentOptions" to paymentOptionsToMap(place.paymentOptions),
            "parkingOptions" to parkingOptionsToMap(place.parkingOptions),
            "evChargeOptions" to evChargeOptionsToMap(place.evChargeOptions),
            "fuelOptions" to fuelOptionsToMap(place.fuelOptions),
            "priceRange" to null,

            // Summaries & AI content
            "generativeSummary" to generativeSummaryToMap(place),
            "reviewSummary" to reviewSummaryToMap(place),
            "neighborhoodSummary" to neighborhoodSummaryToMap(place),
            "evChargeAmenitySummary" to evChargeAmenitySummaryToMap(place),

            // Relational data
            "postalAddress" to null,
            "subDestinations" to place.subDestinations?.map { subDestinationToMap(it) },
            "containingPlaces" to null,
            "addressDescriptor" to null,
            "consumerAlerts" to place.consumerAlert?.let { listOf(consumerAlertToMap(it)) }
        )
    }

    private fun openingHoursToMap(openingHours: OpeningHours?): Map<String, Any?>? {
        if (openingHours == null) {
            return null
        }

        return mapOf(
            "periods" to (openingHours.periods?.map { periodToMap(it) } ?: emptyList<Map<String, Any?>>()),
            "weekdayText" to (openingHours.weekdayText ?: emptyList<String>())
        )
    }

    private fun periodToMap(period: Period): Map<String, Any?> {
        return mapOf(
            "open" to timeOfWeekToMap(period.open),
            "close" to timeOfWeekToMap(period.close)
        )
    }

    private fun timeOfWeekToMap(timeOfWeek: TimeOfWeek?): Map<String, Any?>? {
        if (timeOfWeek == null) {
            return null
        }

        return mapOf(
            "day" to timeOfWeek.day.name,
            "time" to placeLocalTimeToMap(timeOfWeek.time)
        )
    }

    private fun placeLocalTimeToMap(time: LocalTime): Map<String, Any?> {
        return mapOf(
            "hours" to time.hours,
            "minutes" to time.minutes
        )
    }

    private fun reviewToMap(review: Review): Map<String, Any?> {
        return mapOf(
            "attribution" to (review.attribution ?: ""),
            "authorAttribution" to authorAttributionToMap(review.authorAttribution),
            "originalText" to review.originalText,
            "originalTextLanguageCode" to review.originalTextLanguageCode,
            "rating" to review.rating,
            "publishTime" to (review.publishTime ?: ""),
            "relativePublishTimeDescription" to (review.relativePublishTimeDescription ?: ""),
            "text" to review.text,
            "textLanguageCode" to review.textLanguageCode
        )
    }

    private fun photoMetadataToMap(photoMetadata: PhotoMetadata): Map<String, Any?> {
        val photoReference = getPhotoReference()
        photosCache[photoReference] = photoMetadata
        return mapOf(
            "width" to photoMetadata.width,
            "height" to photoMetadata.height,
            "attributions" to (photoMetadata.attributions ?: ""),
            "photoReference" to photoReference,
            "authorAttributions" to photoMetadata.authorAttributions.asList().map { authorAttributionToMap(it) },
            "flagContentUri" to null,
            "googleMapsUri" to null
        )
    }

    private fun authorAttributionToMap(authorAttribution: AuthorAttribution): Map<String, String?> {
        return mapOf<String, String?>(
            "name" to (authorAttribution.name ?: ""),
            "photoUri" to (authorAttribution.photoUri ?: ""),
            "uri" to (authorAttribution.uri ?: "")
        )
    }

    private fun getPhotoReference(): String {
        val num = runningUid++
        return "id_$num"
    }

    // ===== Helper to convert BooleanPlaceAttributeValue to Boolean? =====

    private fun booleanAttributeToValue(attr: Place.BooleanPlaceAttributeValue?): Boolean? {
        return when (attr) {
            Place.BooleanPlaceAttributeValue.TRUE -> true
            Place.BooleanPlaceAttributeValue.FALSE -> false
            else -> null
        }
    }

    // ===== New serializer helpers =====

    private fun localizedTextToMap(text: String?, languageCode: String?): Map<String, Any?>? {
        if (text == null) return null
        return mapOf(
            "text" to text,
            "languageCode" to languageCode
        )
    }

    private fun priceLevelToString(priceLevel: Int): String? {
        return when (priceLevel) {
            0 -> "PRICE_LEVEL_FREE"
            1 -> "PRICE_LEVEL_INEXPENSIVE"
            2 -> "PRICE_LEVEL_MODERATE"
            3 -> "PRICE_LEVEL_EXPENSIVE"
            4 -> "PRICE_LEVEL_VERY_EXPENSIVE"
            else -> null
        }
    }

    private fun accessibilityOptionsToMap(options: AccessibilityOptions?): Map<String, Any?>? {
        if (options == null) return null
        return mapOf(
            "wheelchairAccessibleParking" to booleanAttributeToValue(options.wheelchairAccessibleParking),
            "wheelchairAccessibleEntrance" to booleanAttributeToValue(options.wheelchairAccessibleEntrance),
            "wheelchairAccessibleRestroom" to booleanAttributeToValue(options.wheelchairAccessibleRestroom),
            "wheelchairAccessibleSeating" to booleanAttributeToValue(options.wheelchairAccessibleSeating)
        )
    }

    private fun paymentOptionsToMap(options: PaymentOptions?): Map<String, Any?>? {
        if (options == null) return null
        return mapOf(
            "acceptsCreditCards" to booleanAttributeToValue(options.acceptsCreditCards),
            "acceptsDebitCards" to booleanAttributeToValue(options.acceptsDebitCards),
            "acceptsCashOnly" to booleanAttributeToValue(options.acceptsCashOnly),
            "acceptsNfc" to booleanAttributeToValue(options.acceptsNfc)
        )
    }

    private fun parkingOptionsToMap(options: ParkingOptions?): Map<String, Any?>? {
        if (options == null) return null
        return mapOf(
            "freeParkingLot" to booleanAttributeToValue(options.freeParkingLot),
            "paidParkingLot" to booleanAttributeToValue(options.paidParkingLot),
            "freeStreetParking" to booleanAttributeToValue(options.freeStreetParking),
            "paidStreetParking" to booleanAttributeToValue(options.paidStreetParking),
            "valetParking" to booleanAttributeToValue(options.valetParking),
            "freeGarageParking" to booleanAttributeToValue(options.freeGarageParking),
            "paidGarageParking" to booleanAttributeToValue(options.paidGarageParking)
        )
    }

    private fun evChargeOptionsToMap(options: EVChargeOptions?): Map<String, Any?>? {
        if (options == null) return null
        return mapOf(
            "connectorCount" to options.connectorCount,
            "connectorAggregation" to options.connectorAggregations?.map { connectorAggregationToMap(it) }
        )
    }

    private fun connectorAggregationToMap(agg: ConnectorAggregation): Map<String, Any?> {
        return mapOf(
            "type" to agg.type?.name,
            "maxChargeRateKw" to agg.maxChargeRateKw,
            "count" to agg.count,
            "availabilityLastUpdateTime" to agg.availabilityLastUpdateTime?.toString(),
            "availableCount" to agg.availableCount,
            "outOfServiceCount" to agg.outOfServiceCount
        )
    }

    private fun fuelOptionsToMap(options: FuelOptions?): Map<String, Any?>? {
        if (options == null) return null
        return mapOf(
            "fuelPrices" to options.fuelPrices?.map { fuelPriceToMap(it) }
        )
    }

    private fun fuelPriceToMap(fuelPrice: FuelPrice): Map<String, Any?> {
        return mapOf(
            "type" to fuelPrice.type?.name,
            "price" to fuelPrice.price?.let { moneyToMap(it) },
            "updateTime" to fuelPrice.updateTime?.toString()
        )
    }

    private fun moneyToMap(money: Money): Map<String, Any?> {
        return mapOf(
            "currencyCode" to (money.currencyCode ?: ""),
            "units" to money.units?.toString(),
            "nanos" to money.nanos
        )
    }

    private fun priceRangeToMap(priceRange: Any?): Map<String, Any?>? {
        // Place.PriceRange does not exist in Places SDK 5.1.1
        return null
    }

    private fun googleMapsLinksToMap(place: Place): Map<String, Any?>? {
        val links = place.googleMapsLinks ?: return null
        return mapOf(
            "directionsUri" to links.directionsUri?.toString(),
            "placeUri" to links.placeUri?.toString(),
            "writeAReviewUri" to links.writeAReviewUri?.toString(),
            "reviewsUri" to links.reviewsUri?.toString(),
            "photosUri" to links.photosUri?.toString()
        )
    }

    private fun generativeSummaryToMap(place: Place): Map<String, Any?>? {
        val summary = place.generativeSummary ?: return null
        return mapOf(
            "overview" to localizedTextToMap(summary.overview, summary.overviewLanguageCode),
            "overviewFlagContentUri" to summary.flagContentUri?.toString(),
            "disclosureText" to localizedTextToMap(summary.disclosureText, summary.disclosureTextLanguageCode)
        )
    }

    private fun reviewSummaryToMap(place: Place): Map<String, Any?>? {
        val summary = place.reviewSummary ?: return null
        return mapOf(
            "text" to localizedTextToMap(summary.text, summary.textLanguageCode),
            "flagContentUri" to summary.flagContentUri?.toString(),
            "disclosureText" to localizedTextToMap(summary.disclosureText, summary.disclosureTextLanguageCode),
            "reviewsUri" to summary.reviewsUri?.toString()
        )
    }

    private fun neighborhoodSummaryToMap(place: Place): Map<String, Any?>? {
        val summary = place.neighborhoodSummary ?: return null
        return mapOf(
            "overview" to contentBlockToMap(summary.overview),
            "description" to contentBlockToMap(summary.description),
            "flagContentUri" to summary.flagContentUri?.toString(),
            "disclosureText" to localizedTextToMap(summary.disclosureText, summary.disclosureTextLanguageCode)
        )
    }

    private fun evChargeAmenitySummaryToMap(place: Place): Map<String, Any?>? {
        val summary = place.evChargeAmenitySummary ?: return null
        return mapOf(
            "overview" to contentBlockToMap(summary.overview),
            "coffee" to contentBlockToMap(summary.coffee),
            "restaurant" to contentBlockToMap(summary.restaurant),
            "store" to contentBlockToMap(summary.store),
            "flagContentUri" to summary.flagContentUri?.toString(),
            "disclosureText" to localizedTextToMap(summary.disclosureText, summary.disclosureTextLanguageCode)
        )
    }

    private fun contentBlockToMap(block: ContentBlock?): Map<String, Any?>? {
        if (block == null) return null
        return mapOf(
            "content" to localizedTextToMap(block.content, block.contentLanguageCode),
            "referencedPlaces" to block.referencedPlaceIds
        )
    }

    private fun postalAddressToMap(address: Any?): Map<String, Any?>? {
        // Place.PostalAddress does not exist in Places SDK 5.1.1
        return null
    }

    private fun subDestinationToMap(sub: SubDestination): Map<String, Any?> {
        return mapOf(
            "name" to sub.name,
            "id" to sub.id
        )
    }

    private fun containingPlaceToMap(cp: Any): Map<String, Any?> {
        // Place.ContainingPlace does not exist in Places SDK 5.1.1
        return emptyMap()
    }

    private fun addressDescriptorToMap(descriptor: Any?): Map<String, Any?>? {
        // Place.AddressDescriptor does not exist in Places SDK 5.1.1
        return null
    }

    private fun landmarkToMap(landmark: Any): Map<String, Any?> {
        // Place.Landmark does not exist in Places SDK 5.1.1
        return emptyMap()
    }

    private fun areaToMap(area: Any): Map<String, Any?> {
        // Place.Area does not exist in Places SDK 5.1.1
        return emptyMap()
    }

    private fun consumerAlertToMap(alert: com.google.android.libraries.places.api.model.ConsumerAlert): Map<String, Any?> {
        return mapOf(
            "overview" to alert.overview,
            "details" to alert.details?.let {
                mapOf(
                    "description" to it.description,
                    "link" to mapOf(
                        "uri" to it.aboutLinkUri?.toString(),
                        "languageCode" to null
                    )
                )
            },
            "languageCode" to alert.languageCode
        )
    }

    private fun plusCodeToMap(plusCode: PlusCode?): Map<String, Any?>? {
        if (plusCode == null) {
            return null
        }

        return mapOf(
            "compoundCode" to (plusCode.compoundCode ?: ""),
            "globalCode" to (plusCode.globalCode ?: "")
        )
    }

    private fun latLngBoundsToMap(viewport: LatLngBounds?): Map<String, Any?>? {
        if (viewport == null) {
            return null
        }

        return mapOf(
            "southwest" to latLngToMap(viewport.southwest),
            "northeast" to latLngToMap(viewport.northeast)
        )
    }

    private fun addressComponentToMap(addressComponent: AddressComponent): Map<String, Any?> {
        return mapOf(
            "name" to (addressComponent.name ?: ""),
            "shortName" to (addressComponent.shortName ?: ""),
            "types" to (addressComponent.types ?: emptyList<String>())
        )
    }

    private fun latLngToMap(latLng: LatLng?): Any? {
        if (latLng == null) {
            return null
        }

        return mapOf(
            "lat" to latLng.latitude,
            "lng" to latLng.longitude
        )
    }

    private fun predictionToMap(result: AutocompletePrediction): Map<String, Any?> {
        return mapOf(
            "placeId" to result.placeId,
            "distanceMeters" to result.distanceMeters,
            "primaryText" to result.getPrimaryText(null).toString(),
            "secondaryText" to result.getSecondaryText(null).toString(),
            "fullText" to result.getFullText(null).toString(),
        )
    }

    private fun readLocale(localeMap: Map<String, Any>?): Locale? {
        if (localeMap == null) {
            return null
        }

        val language = localeMap["language"] as? String ?: return null
        var country = localeMap["country"] as? String
        if (country == null) {
            country = Locale.getDefault().country
        }
        return Locale(language, country)
    }

    private fun initialize(apiKey: String?, locale: Locale?) {
        // Only reinitialize if not initialized or API key changed
        if (!Places.isInitialized() || initializedApiKey != apiKey) {
            if (Places.isInitialized()) {
                Places.deinitialize()
            }
            // SDK 5.0+ only supports the new Places API
            Places.initializeWithNewPlacesApiEnabled(applicationContext, apiKey ?: "", locale)
            initializedApiKey = apiKey
        }
        // Reuse existing client if possible, only create new one if null
        if (client == null) {
            client = Places.createClient(applicationContext)
        }
    }

    private fun updateSettings(apiKey: String?, locale: Locale?) {
        // Only reinitialize if API key changed
        if (initializedApiKey != apiKey) {
            if (Places.isInitialized()) {
                Places.deinitialize()
            }
            // SDK 5.0+ only supports the new Places API
            Places.initializeWithNewPlacesApiEnabled(applicationContext, apiKey ?: "", locale)
            initializedApiKey = apiKey
            // Need new client after reinitialization
            client = Places.createClient(applicationContext)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "FlutterGooglePlacesSdk"
        private const val METHOD_INITIALIZE = "initialize"
        private const val METHOD_UPDATE_SETTINGS = "updateSettings"
        private const val METHOD_DEINITIALIZE = "deinitialize"
        private const val METHOD_IS_INITIALIZE = "isInitialized"
        private const val METHOD_FIND_AUTOCOMPLETE_PREDICTIONS = "findAutocompletePredictions"
        private const val METHOD_FETCH_PLACE = "fetchPlace"
        private const val METHOD_FETCH_PLACE_PHOTO = "fetchPlacePhoto"
        private const val METHOD_SEARCH_BY_TEXT = "searchByText"
        private const val METHOD_NEARBY_SEARCH = "searchNearby"

        const val CHANNEL_NAME = "plugins.msh.com/google_places_sdk_plus"
    }
}
