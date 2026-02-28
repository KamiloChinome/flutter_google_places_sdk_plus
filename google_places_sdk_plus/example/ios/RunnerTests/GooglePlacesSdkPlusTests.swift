import XCTest
import CoreLocation
@testable import google_places_sdk_plus_ios
import GooglePlaces

class GooglePlacesSdkPlusTests: XCTestCase {

    var plugin: SwiftFlutterGooglePlacesSdkIosPlugin!

    override func setUp() {
        super.setUp()
        plugin = SwiftFlutterGooglePlacesSdkIosPlugin()
    }

    override func tearDown() {
        plugin = nil
        super.tearDown()
    }

    // MARK: - UIColor.toHexString Tests

    func testUIColorRedToHexString() {
        let color = UIColor.red
        XCTAssertEqual(color.toHexString(), "#FF0000")
    }

    func testUIColorWhiteToHexString() {
        let color = UIColor.white
        XCTAssertEqual(color.toHexString(), "#FFFFFF")
    }

    func testUIColorBlackToHexString() {
        let color = UIColor.black
        XCTAssertEqual(color.toHexString(), "#000000")
    }

    func testUIColorBlueToHexString() {
        let color = UIColor.blue
        XCTAssertEqual(color.toHexString(), "#0000FF")
    }

    func testUIColorGreenToHexString() {
        let color = UIColor.green
        XCTAssertEqual(color.toHexString(), "#00FF00")
    }

    func testUIColorCustomToHexString() {
        let color = UIColor(red: 0.5, green: 0.25, blue: 0.75, alpha: 1.0)
        let hex = color.toHexString()
        XCTAssertEqual(hex, "#7F3FBF")
    }

    // MARK: - GMSBooleanPlaceAttribute.toBoolOrNil Tests

    func testBooleanAttributeTrueReturnsBool() {
        XCTAssertEqual(GMSBooleanPlaceAttribute.true.toBoolOrNil(), true)
    }

    func testBooleanAttributeFalseReturnsBool() {
        XCTAssertEqual(GMSBooleanPlaceAttribute.false.toBoolOrNil(), false)
    }

    func testBooleanAttributeUnknownReturnsNil() {
        XCTAssertNil(GMSBooleanPlaceAttribute.unknown.toBoolOrNil())
    }

    // MARK: - latLngFromMap Tests

    func testLatLngFromMapReturnsNilForNilInput() {
        XCTAssertNil(plugin.latLngFromMap(argument: nil))
    }

    func testLatLngFromMapReturnsNilForEmptyMap() {
        let input: Dictionary<String, Any?> = [:]
        XCTAssertNil(plugin.latLngFromMap(argument: input))
    }

    func testLatLngFromMapReturnsNilWhenLatMissing() {
        let input: Dictionary<String, Any?> = ["lng": 34.78]
        XCTAssertNil(plugin.latLngFromMap(argument: input))
    }

    func testLatLngFromMapReturnsNilWhenLngMissing() {
        let input: Dictionary<String, Any?> = ["lat": 32.08]
        XCTAssertNil(plugin.latLngFromMap(argument: input))
    }

    func testLatLngFromMapReturnsLocationForValidInput() {
        let input: Dictionary<String, Any?> = ["lat": 32.0853, "lng": 34.7818]
        let result = plugin.latLngFromMap(argument: input)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.coordinate.latitude, 32.0853, accuracy: 0.0001)
        XCTAssertEqual(result!.coordinate.longitude, 34.7818, accuracy: 0.0001)
    }

    func testLatLngFromMapHandlesNegativeCoordinates() {
        let input: Dictionary<String, Any?> = ["lat": -33.8688, "lng": -151.2093]
        let result = plugin.latLngFromMap(argument: input)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.coordinate.latitude, -33.8688, accuracy: 0.0001)
        XCTAssertEqual(result!.coordinate.longitude, -151.2093, accuracy: 0.0001)
    }

    func testLatLngFromMapHandlesZeroCoordinates() {
        let input: Dictionary<String, Any?> = ["lat": 0.0, "lng": 0.0]
        let result = plugin.latLngFromMap(argument: input)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.coordinate.latitude, 0.0, accuracy: 0.0001)
        XCTAssertEqual(result!.coordinate.longitude, 0.0, accuracy: 0.0001)
    }

    // MARK: - latLngToMap Tests

    func testLatLngToMapReturnsNilForNilInput() {
        let result = plugin.latLngToMap(coordinate: nil)
        XCTAssertNil(result)
    }

    func testLatLngToMapReturnsCorrectMapForValidCoordinate() {
        let coordinate = CLLocationCoordinate2D(latitude: 32.0853, longitude: 34.7818)
        let result = plugin.latLngToMap(coordinate: coordinate) as? Dictionary<String, Double>
        XCTAssertNotNil(result)
        XCTAssertEqual(result!["lat"]!, 32.0853, accuracy: 0.0001)
        XCTAssertEqual(result!["lng"]!, 34.7818, accuracy: 0.0001)
    }

    // MARK: - localizedTextToMap Tests

    func testLocalizedTextToMapReturnsNilForNilText() {
        let result = plugin.localizedTextToMap(text: nil, languageCode: "en")
        XCTAssertNil(result)
    }

    func testLocalizedTextToMapReturnsMapForValidText() {
        let result = plugin.localizedTextToMap(text: "Hello", languageCode: "en")
        XCTAssertNotNil(result)
        XCTAssertEqual(result!["text"] as? String, "Hello")
        XCTAssertEqual(result!["languageCode"] as? String, "en")
    }

    func testLocalizedTextToMapHandlesNilLanguageCode() {
        let result = plugin.localizedTextToMap(text: "Test", languageCode: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!["text"] as? String, "Test")
        XCTAssertNil(result!["languageCode"] as? String)
    }

    // MARK: - priceLevelToString Tests

    func testPriceLevelFree() {
        XCTAssertEqual(plugin.priceLevelToString(priceLevel: .free), "PRICE_LEVEL_FREE")
    }

    func testPriceLevelCheap() {
        XCTAssertEqual(plugin.priceLevelToString(priceLevel: .cheap), "PRICE_LEVEL_INEXPENSIVE")
    }

    func testPriceLevelMedium() {
        XCTAssertEqual(plugin.priceLevelToString(priceLevel: .medium), "PRICE_LEVEL_MODERATE")
    }

    func testPriceLevelHigh() {
        XCTAssertEqual(plugin.priceLevelToString(priceLevel: .high), "PRICE_LEVEL_EXPENSIVE")
    }

    func testPriceLevelExpensive() {
        XCTAssertEqual(plugin.priceLevelToString(priceLevel: .expensive), "PRICE_LEVEL_VERY_EXPENSIVE")
    }

    // MARK: - businessStatusToStr Tests

    func testBusinessStatusOperational() {
        XCTAssertEqual(plugin.businessStatusToStr(it: .operational), "OPERATIONAL")
    }

    func testBusinessStatusClosedTemporarily() {
        XCTAssertEqual(plugin.businessStatusToStr(it: .closedTemporarily), "CLOSED_TEMPORARILY")
    }

    func testBusinessStatusClosedPermanently() {
        XCTAssertEqual(plugin.businessStatusToStr(it: .closedPermanently), "CLOSED_PERMANENTLY")
    }

    // MARK: - dayOfWeekToStr Tests

    func testDayOfWeekSunday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .sunday), "SUNDAY")
    }

    func testDayOfWeekMonday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .monday), "MONDAY")
    }

    func testDayOfWeekTuesday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .tuesday), "TUESDAY")
    }

    func testDayOfWeekWednesday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .wednesday), "WEDNESDAY")
    }

    func testDayOfWeekThursday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .thursday), "THURSDAY")
    }

    func testDayOfWeekFriday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .friday), "FRIDAY")
    }

    func testDayOfWeekSaturday() {
        XCTAssertEqual(plugin.dayOfWeekToStr(it: .saturday), "SATURDAY")
    }

    // MARK: - placeFieldFromStr Tests

    func testPlaceFieldFromStrId() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Id"), GMSPlaceField.placeID)
    }

    func testPlaceFieldFromStrDisplayName() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "DisplayName"), GMSPlaceField.name)
    }

    func testPlaceFieldFromStrLocation() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Location"), GMSPlaceField.coordinate)
    }

    func testPlaceFieldFromStrRating() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Rating"), GMSPlaceField.rating)
    }

    func testPlaceFieldFromStrFormattedAddress() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "FormattedAddress"), GMSPlaceField.formattedAddress)
    }

    func testPlaceFieldFromStrPhotos() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Photos"), GMSPlaceField.photos)
    }

    func testPlaceFieldFromStrPriceLevel() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "PriceLevel"), GMSPlaceField.priceLevel)
    }

    func testPlaceFieldFromStrTypes() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Types"), GMSPlaceField.types)
    }

    func testPlaceFieldFromStrWebsiteUri() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "WebsiteUri"), GMSPlaceField.website)
    }

    func testPlaceFieldFromStrOpeningHours() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "OpeningHours"), GMSPlaceField.openingHours)
    }

    func testPlaceFieldFromStrDelivery() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Delivery"), GMSPlaceField.delivery)
    }

    func testPlaceFieldFromStrDineIn() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "DineIn"), GMSPlaceField.dineIn)
    }

    func testPlaceFieldFromStrTakeout() {
        XCTAssertEqual(plugin.placeFieldFromStr(it: "Takeout"), GMSPlaceField.takeout)
    }

    // MARK: - LatLng Roundtrip

    func testLatLngRoundtripPreservesCoordinates() {
        let originalCoord = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        let map = plugin.latLngToMap(coordinate: originalCoord) as? Dictionary<String, Any?>
        XCTAssertNotNil(map)
        let restored = plugin.latLngFromMap(argument: map)
        XCTAssertNotNil(restored)
        XCTAssertEqual(originalCoord.latitude, restored!.coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(originalCoord.longitude, restored!.coordinate.longitude, accuracy: 0.0001)
    }
}
