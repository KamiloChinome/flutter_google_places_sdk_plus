package io.google_places_sdk_plus

import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.libraries.places.api.model.Place
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import java.util.Locale

class FlutterGooglePlacesSdkPluginTest {

    private lateinit var plugin: FlutterGooglePlacesSdkPlugin

    @Before
    fun setUp() {
        plugin = FlutterGooglePlacesSdkPlugin()
    }

    // ===== latLngFromMap Tests =====

    @Test
    fun `latLngFromMap returns null for null input`() {
        assertNull(plugin.latLngFromMap(null))
    }

    @Test
    fun `latLngFromMap returns null for empty map`() {
        assertNull(plugin.latLngFromMap(emptyMap()))
    }

    @Test
    fun `latLngFromMap returns null when lat is missing`() {
        assertNull(plugin.latLngFromMap(mapOf("lng" to 34.78)))
    }

    @Test
    fun `latLngFromMap returns null when lng is missing`() {
        assertNull(plugin.latLngFromMap(mapOf("lat" to 32.08)))
    }

    @Test
    fun `latLngFromMap returns LatLng for valid input`() {
        val result = plugin.latLngFromMap(mapOf("lat" to 32.0853, "lng" to 34.7818))
        assertNotNull(result)
        assertEquals(32.0853, result!!.latitude, 0.0001)
        assertEquals(34.7818, result.longitude, 0.0001)
    }

    @Test
    fun `latLngFromMap handles zero coordinates`() {
        val result = plugin.latLngFromMap(mapOf("lat" to 0.0, "lng" to 0.0))
        assertNotNull(result)
        assertEquals(0.0, result!!.latitude, 0.0001)
        assertEquals(0.0, result.longitude, 0.0001)
    }

    @Test
    fun `latLngFromMap handles negative coordinates`() {
        val result = plugin.latLngFromMap(mapOf("lat" to -33.8688, "lng" to -151.2093))
        assertNotNull(result)
        assertEquals(-33.8688, result!!.latitude, 0.0001)
        assertEquals(-151.2093, result.longitude, 0.0001)
    }

    // ===== latLngToMap Tests =====

    @Test
    fun `latLngToMap returns null for null input`() {
        assertNull(plugin.latLngToMap(null))
    }

    @Test
    fun `latLngToMap returns correct map for valid LatLng`() {
        val result = plugin.latLngToMap(LatLng(32.0853, 34.7818)) as? Map<*, *>
        assertNotNull(result)
        assertEquals(32.0853, result!!["lat"] as Double, 0.0001)
        assertEquals(34.7818, result["lng"] as Double, 0.0001)
    }

    @Test
    fun `latLngToMap handles negative coordinates`() {
        val result = plugin.latLngToMap(LatLng(-33.8688, 151.2093)) as? Map<*, *>
        assertNotNull(result)
        assertEquals(-33.8688, result!!["lat"] as Double, 0.0001)
        assertEquals(151.2093, result["lng"] as Double, 0.0001)
    }

    // ===== latLngBoundsFromMap Tests =====

    @Test
    fun `latLngBoundsFromMap returns null for null input`() {
        assertNull(plugin.latLngBoundsFromMap(null))
    }

    @Test
    fun `latLngBoundsFromMap returns null for empty map`() {
        assertNull(plugin.latLngBoundsFromMap(emptyMap()))
    }

    @Test
    fun `latLngBoundsFromMap returns null when southwest is missing`() {
        val input = mapOf<String, Any?>(
            "northeast" to mapOf("lat" to 33.0, "lng" to 35.0)
        )
        assertNull(plugin.latLngBoundsFromMap(input))
    }

    @Test
    fun `latLngBoundsFromMap returns bounds for valid input`() {
        val input = mapOf<String, Any?>(
            "southwest" to mapOf("lat" to 32.0, "lng" to 34.0),
            "northeast" to mapOf("lat" to 33.0, "lng" to 35.0)
        )
        val result = plugin.latLngBoundsFromMap(input)
        assertNotNull(result)
        assertEquals(32.0, result!!.southwest.latitude, 0.0001)
        assertEquals(34.0, result.southwest.longitude, 0.0001)
        assertEquals(33.0, result.northeast.latitude, 0.0001)
        assertEquals(35.0, result.northeast.longitude, 0.0001)
    }

    // ===== latLngBoundsToMap Tests =====

    @Test
    fun `latLngBoundsToMap returns null for null input`() {
        assertNull(plugin.latLngBoundsToMap(null))
    }

    @Test
    fun `latLngBoundsToMap returns correct map for valid bounds`() {
        val bounds = LatLngBounds(LatLng(32.0, 34.0), LatLng(33.0, 35.0))
        val result = plugin.latLngBoundsToMap(bounds)
        assertNotNull(result)
        val sw = result!!["southwest"] as? Map<*, *>
        val ne = result["northeast"] as? Map<*, *>
        assertNotNull(sw)
        assertNotNull(ne)
        assertEquals(32.0, sw!!["lat"] as Double, 0.0001)
        assertEquals(34.0, sw["lng"] as Double, 0.0001)
        assertEquals(33.0, ne!!["lat"] as Double, 0.0001)
        assertEquals(35.0, ne["lng"] as Double, 0.0001)
    }

    // ===== readLocale Tests =====

    @Test
    fun `readLocale returns null for null input`() {
        assertNull(plugin.readLocale(null))
    }

    @Test
    fun `readLocale returns null when language is missing`() {
        assertNull(plugin.readLocale(mapOf("country" to "US")))
    }

    @Test
    fun `readLocale returns locale with language and country`() {
        val result = plugin.readLocale(mapOf("language" to "en", "country" to "US"))
        assertNotNull(result)
        assertEquals("en", result!!.language)
        assertEquals("US", result.country)
    }

    @Test
    fun `readLocale uses default country when not provided`() {
        val result = plugin.readLocale(mapOf("language" to "es"))
        assertNotNull(result)
        assertEquals("es", result!!.language)
        assertEquals(Locale.getDefault().country, result.country)
    }

    // ===== placeFieldFromStr Tests =====

    @Test
    fun `placeFieldFromStr maps Id correctly`() {
        assertEquals(Place.Field.ID, plugin.placeFieldFromStr("Id"))
    }

    @Test
    fun `placeFieldFromStr maps DisplayName correctly`() {
        assertEquals(Place.Field.DISPLAY_NAME, plugin.placeFieldFromStr("DisplayName"))
    }

    @Test
    fun `placeFieldFromStr maps Location correctly`() {
        assertEquals(Place.Field.LOCATION, plugin.placeFieldFromStr("Location"))
    }

    @Test
    fun `placeFieldFromStr maps Rating correctly`() {
        assertEquals(Place.Field.RATING, plugin.placeFieldFromStr("Rating"))
    }

    @Test
    fun `placeFieldFromStr maps FormattedAddress correctly`() {
        assertEquals(Place.Field.FORMATTED_ADDRESS, plugin.placeFieldFromStr("FormattedAddress"))
    }

    @Test
    fun `placeFieldFromStr maps explicit UtcOffset correctly`() {
        assertEquals(Place.Field.UTC_OFFSET, plugin.placeFieldFromStr("UtcOffset"))
    }

    @Test
    fun `placeFieldFromStr maps explicit Photos correctly`() {
        assertEquals(Place.Field.PHOTO_METADATAS, plugin.placeFieldFromStr("Photos"))
    }

    @Test
    fun `placeFieldFromStr maps explicit IconMaskUrl correctly`() {
        assertEquals(Place.Field.ICON_MASK_URL, plugin.placeFieldFromStr("IconMaskUrl"))
    }

    @Test
    fun `placeFieldFromStr maps explicit GoogleMapsUri correctly`() {
        assertEquals(Place.Field.GOOGLE_MAPS_URI, plugin.placeFieldFromStr("GoogleMapsUri"))
    }

    @Test
    fun `placeFieldFromStr maps explicit GoogleMapsLinks correctly`() {
        assertEquals(Place.Field.GOOGLE_MAPS_LINKS, plugin.placeFieldFromStr("GoogleMapsLinks"))
    }

    @Test
    fun `placeFieldFromStr maps explicit EvChargeOptions correctly`() {
        assertEquals(Place.Field.EV_CHARGE_OPTIONS, plugin.placeFieldFromStr("EvChargeOptions"))
    }

    @Test
    fun `placeFieldFromStr maps explicit FormattedAddressAdr correctly`() {
        assertEquals(Place.Field.ADR_FORMAT_ADDRESS, plugin.placeFieldFromStr("FormattedAddressAdr"))
    }

    @Test
    fun `placeFieldFromStr returns null for unknown field`() {
        assertNull(plugin.placeFieldFromStr("UnknownFieldXyz"))
    }

    @Test
    fun `placeFieldFromStr maps BusinessStatus correctly`() {
        assertEquals(Place.Field.BUSINESS_STATUS, plugin.placeFieldFromStr("BusinessStatus"))
    }

    @Test
    fun `placeFieldFromStr maps PriceLevel correctly`() {
        assertEquals(Place.Field.PRICE_LEVEL, plugin.placeFieldFromStr("PriceLevel"))
    }

    @Test
    fun `placeFieldFromStr maps Viewport correctly`() {
        assertEquals(Place.Field.VIEWPORT, plugin.placeFieldFromStr("Viewport"))
    }

    @Test
    fun `placeFieldFromStr maps WebsiteUri correctly`() {
        assertEquals(Place.Field.WEBSITE_URI, plugin.placeFieldFromStr("WebsiteUri"))
    }

    @Test
    fun `placeFieldFromStr maps Reviews correctly`() {
        assertEquals(Place.Field.REVIEWS, plugin.placeFieldFromStr("Reviews"))
    }

    @Test
    fun `placeFieldFromStr maps OpeningHours correctly`() {
        assertEquals(Place.Field.OPENING_HOURS, plugin.placeFieldFromStr("OpeningHours"))
    }

    @Test
    fun `placeFieldFromStr maps AddressComponents correctly`() {
        assertEquals(Place.Field.ADDRESS_COMPONENTS, plugin.placeFieldFromStr("AddressComponents"))
    }

    // ===== priceLevelToString Tests =====

    @Test
    fun `priceLevelToString returns FREE for 0`() {
        assertEquals("PRICE_LEVEL_FREE", plugin.priceLevelToString(0))
    }

    @Test
    fun `priceLevelToString returns INEXPENSIVE for 1`() {
        assertEquals("PRICE_LEVEL_INEXPENSIVE", plugin.priceLevelToString(1))
    }

    @Test
    fun `priceLevelToString returns MODERATE for 2`() {
        assertEquals("PRICE_LEVEL_MODERATE", plugin.priceLevelToString(2))
    }

    @Test
    fun `priceLevelToString returns EXPENSIVE for 3`() {
        assertEquals("PRICE_LEVEL_EXPENSIVE", plugin.priceLevelToString(3))
    }

    @Test
    fun `priceLevelToString returns VERY_EXPENSIVE for 4`() {
        assertEquals("PRICE_LEVEL_VERY_EXPENSIVE", plugin.priceLevelToString(4))
    }

    @Test
    fun `priceLevelToString returns null for unknown value`() {
        assertNull(plugin.priceLevelToString(5))
        assertNull(plugin.priceLevelToString(-1))
    }

    // ===== booleanAttributeToValue Tests =====

    @Test
    fun `booleanAttributeToValue returns true for TRUE`() {
        assertEquals(true, plugin.booleanAttributeToValue(Place.BooleanPlaceAttributeValue.TRUE))
    }

    @Test
    fun `booleanAttributeToValue returns false for FALSE`() {
        assertEquals(false, plugin.booleanAttributeToValue(Place.BooleanPlaceAttributeValue.FALSE))
    }

    @Test
    fun `booleanAttributeToValue returns null for UNKNOWN`() {
        assertNull(plugin.booleanAttributeToValue(Place.BooleanPlaceAttributeValue.UNKNOWN))
    }

    @Test
    fun `booleanAttributeToValue returns null for null input`() {
        assertNull(plugin.booleanAttributeToValue(null))
    }

    // ===== localizedTextToMap Tests =====

    @Test
    fun `localizedTextToMap returns null for null text`() {
        assertNull(plugin.localizedTextToMap(null, "en"))
    }

    @Test
    fun `localizedTextToMap returns map for valid text`() {
        val result = plugin.localizedTextToMap("Hello", "en")
        assertNotNull(result)
        assertEquals("Hello", result!!["text"])
        assertEquals("en", result["languageCode"])
    }

    @Test
    fun `localizedTextToMap handles null languageCode`() {
        val result = plugin.localizedTextToMap("Hello", null)
        assertNotNull(result)
        assertEquals("Hello", result!!["text"])
        assertNull(result["languageCode"])
    }

    // ===== toScreamingSnakeCase Tests =====

    @Test
    fun `toScreamingSnakeCase converts camelCase`() {
        with(plugin) {
            assertEquals("DISPLAY_NAME", "DisplayName".toScreamingSnakeCase())
        }
    }

    @Test
    fun `toScreamingSnakeCase converts single word`() {
        with(plugin) {
            assertEquals("ID", "Id".toScreamingSnakeCase())
        }
    }

    @Test
    fun `toScreamingSnakeCase converts multi-word`() {
        with(plugin) {
            assertEquals("FORMATTED_ADDRESS", "FormattedAddress".toScreamingSnakeCase())
        }
    }

    @Test
    fun `toScreamingSnakeCase converts complex names`() {
        with(plugin) {
            assertEquals("BUSINESS_STATUS", "BusinessStatus".toScreamingSnakeCase())
            assertEquals("USER_RATING_COUNT", "UserRatingCount".toScreamingSnakeCase())
        }
    }

    // ===== plusCodeToMap Tests =====

    @Test
    fun `plusCodeToMap returns null for null input`() {
        assertNull(plugin.plusCodeToMap(null))
    }

    // ===== Roundtrip Tests =====

    @Test
    fun `latLng roundtrip preserves coordinates`() {
        val original = LatLng(48.8566, 2.3522)
        val map = plugin.latLngToMap(original) as? Map<*, *>
        assertNotNull(map)
        @Suppress("UNCHECKED_CAST")
        val restored = plugin.latLngFromMap(map as Map<String, Any?>)
        assertNotNull(restored)
        assertEquals(original.latitude, restored!!.latitude, 0.0001)
        assertEquals(original.longitude, restored.longitude, 0.0001)
    }

    @Test
    fun `latLngBounds roundtrip preserves bounds`() {
        val original = LatLngBounds(LatLng(32.0, 34.0), LatLng(33.0, 35.0))
        val map = plugin.latLngBoundsToMap(original)
        assertNotNull(map)
        val restored = plugin.latLngBoundsFromMap(map)
        assertNotNull(restored)
        assertEquals(original.southwest.latitude, restored!!.southwest.latitude, 0.0001)
        assertEquals(original.southwest.longitude, restored.southwest.longitude, 0.0001)
        assertEquals(original.northeast.latitude, restored.northeast.latitude, 0.0001)
        assertEquals(original.northeast.longitude, restored.northeast.longitude, 0.0001)
    }
}
