import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart'
    as inter;
import 'package:http/http.dart' as http;

import 'place_parsing.dart';
import 'types/types.dart';

/// Http implementation plugin for flutter google places sdk
class FlutterGooglePlacesSdkHttpPlugin
    extends inter.FlutterGooglePlacesSdkPlatform {
  /// Creates a new [FlutterGooglePlacesSdkHttpPlugin].
  ///
  /// An optional [httpClient] can be provided for testing or custom
  /// configurations. If not provided, a default [http.Client] is used.
  FlutterGooglePlacesSdkHttpPlugin({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const _kApiHostV2 = 'https://places.googleapis.com';
  static const _kApiPlacesV2 = '${_kApiHostV2}/v1/places:autocomplete';
  static const _kApiPlaceDetailsV2 = '${_kApiHostV2}/v1/places';

  final http.Client _httpClient;

  String? _apiKey;
  Locale? _locale;

  String? _lastSessionToken;

  @override
  Future<void> deinitialize() async {
    _apiKey = null;
    _locale = null;
  }

  @override
  Future<void> initialize(String apiKey, {Locale? locale}) async {
    _apiKey = apiKey;
    _locale = locale;
  }

  @override
  Future<bool?> isInitialized() async => _apiKey != null;

  @override
  Future<void> updateSettings(String apiKey, {Locale? locale}) async {
    _apiKey = apiKey;
    if (locale != null) {
      _locale = locale;
    }
  }

  @override
  Future<inter.FindAutocompletePredictionsResponse> findAutocompletePredictions(
    String query, {
    List<String>? countries,
    List<String> placeTypesFilter = const [],
    bool? newSessionToken,
    inter.LatLng? origin,
    inter.LatLngBounds? locationBias,
    inter.LatLngBounds? locationRestriction,
  }) async {
    final sessionToken = (newSessionToken ?? false) ? null : _lastSessionToken;

    final PlacesAutocompleteResponse response = await _findAutocompleteNewApi(
      query,
      countries,
      placeTypesFilter,
      sessionToken,
      origin,
      locationBias,
      locationRestriction,
    );

    if (response.status != PlacesAutocompleteStatus.OK &&
        response.status != PlacesAutocompleteStatus.ZERO_RESULTS) {
      throw response;
    }

    final predictions = response.predictions
        .map((e) => e.toInterface())
        .toList(growable: false);
    return inter.FindAutocompletePredictionsResponse(predictions);
  }

  Future<PlacesAutocompleteResponse> _findAutocompleteNewApi(
    String query,
    List<String>? countries,
    List<String> placeTypesFilter,
    String? sessionToken,
    inter.LatLng? origin,
    inter.LatLngBounds? locationBias,
    inter.LatLngBounds? locationRestriction,
  ) {
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey!,
    };
    final body = _buildAutocompleteBody(
      query,
      countries,
      placeTypesFilter,
      sessionToken,
      origin,
      locationBias,
      locationRestriction,
    );
    final bodyJson = jsonEncode(body);

    return _doPost(
      _kApiPlacesV2,
      bodyJson,
      (json) => PlacesAutocompleteResponse.fromJson(json),
      headers: headers,
    );
  }

  Map<String, dynamic> _buildAutocompleteBody(
    String query,
    List<String>? countries,
    List<String> placeTypesFilter,
    String? sessionToken,
    inter.LatLng? origin,
    inter.LatLngBounds? locationBias,
    inter.LatLngBounds? locationRestriction,
  ) {
    final data = <String, dynamic>{'input': query};

    // -- Language (from _locale)
    final langCode = _locale?.languageCode;
    if (langCode != null) {
      data['languageCode'] = langCode;
    }

    // -- Place Type
    if (placeTypesFilter.isNotEmpty) {
      data['includedPrimaryTypes'] = placeTypesFilter;
    }

    // -- Session Token
    if (sessionToken != null) {
      data['sessionToken'] = sessionToken;
    }

    // -- Origin
    if (origin != null) {
      data['origin'] = {'latitude': origin.lat, 'longitude': origin.lng};
    }

    // -- Location Bias/Restrictions
    if (locationBias != null && locationRestriction != null) {
      log(
        'Only locationBias OR locationRestriction are supported - not both. Using locationRestriction',
        name: 'google_places_sdk_plus_http',
      );
    }

    return data;
  }

  @override
  Future<inter.FetchPlaceResponse> fetchPlace(
    String placeId, {
    required List<inter.PlaceField> fields,
    bool? newSessionToken,
    String? regionCode,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey!,
      'X-Goog-FieldMask': buildFieldMask(fields),
    };

    final langCode = _locale?.languageCode;
    final uri = Uri.parse('$_kApiPlaceDetailsV2/$placeId').replace(
      queryParameters: {
        if (langCode != null) 'languageCode': langCode,
        if (regionCode != null) 'regionCode': regionCode,
        if (_lastSessionToken != null) 'sessionToken': _lastSessionToken!,
      },
    );

    // End session after fetchPlace (billing optimization).
    if (newSessionToken == true || _lastSessionToken != null) {
      _lastSessionToken = null;
    }

    final json = await _doGet(uri.toString(), headers: headers);
    final place = parsePlaceFromJson(json);
    return inter.FetchPlaceResponse(place);
  }

  @override
  Future<inter.FetchPlacePhotoResponse> fetchPlacePhoto(
    inter.PhotoMetadata photoMetadata, {
    int? maxWidth,
    int? maxHeight,
  }) async {
    // The photoReference from Places API v2 is the resource name,
    // e.g. "places/{placeId}/photos/{photoName}"
    final photoName = photoMetadata.photoReference;

    final queryParams = <String, String>{
      'key': _apiKey!,
      if (maxWidth != null) 'maxWidthPx': maxWidth.toString(),
      if (maxHeight != null) 'maxHeightPx': maxHeight.toString(),
      'skipHttpRedirect': 'true',
    };

    final uri = Uri.parse(
      '$_kApiHostV2/v1/$photoName/media',
    ).replace(queryParameters: queryParams);

    final response = await _httpClient.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw 'Failed to fetch photo. Status: ${response.statusCode}, body: ${response.body}';
    }

    final jsonBody =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
    final photoUri = jsonBody['photoUri'] as String?;
    if (photoUri == null) {
      throw 'No photoUri in response: $jsonBody';
    }

    return inter.FetchPlacePhotoResponse.imageUrl(photoUri);
  }

  @override
  Future<inter.SearchByTextResponse> searchByText(
    String textQuery, {
    required List<inter.PlaceField> fields,
    String? includedType,
    int? maxResultCount,
    inter.LatLngBounds? locationBias,
    inter.LatLngBounds? locationRestriction,
    double? minRating,
    bool? openNow,
    List<inter.PriceLevel>? priceLevels,
    inter.TextSearchRankPreference? rankPreference,
    String? regionCode,
    bool? strictTypeFiltering,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey!,
      'X-Goog-FieldMask': buildFieldMask(fields, prefix: 'places'),
    };

    final body = _buildSearchByTextBody(
      textQuery: textQuery,
      includedType: includedType,
      maxResultCount: maxResultCount,
      locationBias: locationBias,
      locationRestriction: locationRestriction,
      minRating: minRating,
      openNow: openNow,
      priceLevels: priceLevels,
      rankPreference: rankPreference,
      regionCode: regionCode,
      strictTypeFiltering: strictTypeFiltering,
    );

    final url = '$_kApiHostV2/v1/places:searchText';
    final json = await _doPost(
      url,
      jsonEncode(body),
      (json) => json,
      headers: headers,
    );

    final places = _parsePlacesList(json);
    return inter.SearchByTextResponse(places);
  }

  Map<String, dynamic> _buildSearchByTextBody({
    required String textQuery,
    String? includedType,
    int? maxResultCount,
    inter.LatLngBounds? locationBias,
    inter.LatLngBounds? locationRestriction,
    double? minRating,
    bool? openNow,
    List<inter.PriceLevel>? priceLevels,
    inter.TextSearchRankPreference? rankPreference,
    String? regionCode,
    bool? strictTypeFiltering,
  }) {
    final data = <String, dynamic>{'textQuery': textQuery};

    final langCode = _locale?.languageCode;
    if (langCode != null) {
      data['languageCode'] = langCode;
    }

    if (includedType != null) data['includedType'] = includedType;
    if (maxResultCount != null) data['maxResultCount'] = maxResultCount;
    if (minRating != null) data['minRating'] = minRating;
    if (openNow != null) data['openNow'] = openNow;
    if (strictTypeFiltering != null) {
      data['strictTypeFiltering'] = strictTypeFiltering;
    }
    if (regionCode != null) data['regionCode'] = regionCode;

    if (rankPreference != null) {
      data['rankPreference'] = rankPreference.value;
    }

    if (priceLevels != null && priceLevels.isNotEmpty) {
      data['priceLevels'] = priceLevels.map(_priceLevelToApiString).toList();
    }

    if (locationBias != null) {
      data['locationBias'] = {'rectangle': _boundsToJson(locationBias)};
    }
    if (locationRestriction != null) {
      data['locationRestriction'] = {
        'rectangle': _boundsToJson(locationRestriction),
      };
    }

    return data;
  }

  Map<String, dynamic> _boundsToJson(inter.LatLngBounds bounds) {
    return {
      'low': {
        'latitude': bounds.southwest.lat,
        'longitude': bounds.southwest.lng,
      },
      'high': {
        'latitude': bounds.northeast.lat,
        'longitude': bounds.northeast.lng,
      },
    };
  }

  String _priceLevelToApiString(inter.PriceLevel level) {
    return switch (level) {
      inter.PriceLevel.priceLevelFree => 'PRICE_LEVEL_FREE',
      inter.PriceLevel.priceLevelInexpensive => 'PRICE_LEVEL_INEXPENSIVE',
      inter.PriceLevel.priceLevelModerate => 'PRICE_LEVEL_MODERATE',
      inter.PriceLevel.priceLevelExpensive => 'PRICE_LEVEL_EXPENSIVE',
      inter.PriceLevel.priceLevelVeryExpensive => 'PRICE_LEVEL_VERY_EXPENSIVE',
      inter.PriceLevel.priceLevelUnspecified => 'PRICE_LEVEL_UNSPECIFIED',
    };
  }

  @override
  Future<inter.SearchNearbyResponse> searchNearby({
    required List<inter.PlaceField> fields,
    required inter.CircularBounds locationRestriction,
    List<String>? includedTypes,
    List<String>? includedPrimaryTypes,
    List<String>? excludedTypes,
    List<String>? excludedPrimaryTypes,
    inter.NearbySearchRankPreference? rankPreference,
    String? regionCode,
    int? maxResultCount,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey!,
      'X-Goog-FieldMask': buildFieldMask(fields, prefix: 'places'),
    };

    final body = _buildSearchNearbyBody(
      locationRestriction: locationRestriction,
      includedTypes: includedTypes,
      includedPrimaryTypes: includedPrimaryTypes,
      excludedTypes: excludedTypes,
      excludedPrimaryTypes: excludedPrimaryTypes,
      rankPreference: rankPreference,
      regionCode: regionCode,
      maxResultCount: maxResultCount,
    );

    final url = '$_kApiHostV2/v1/places:searchNearby';
    final json = await _doPost(
      url,
      jsonEncode(body),
      (json) => json,
      headers: headers,
    );

    final places = _parsePlacesList(json);
    return inter.SearchNearbyResponse(places);
  }

  Map<String, dynamic> _buildSearchNearbyBody({
    required inter.CircularBounds locationRestriction,
    List<String>? includedTypes,
    List<String>? includedPrimaryTypes,
    List<String>? excludedTypes,
    List<String>? excludedPrimaryTypes,
    inter.NearbySearchRankPreference? rankPreference,
    String? regionCode,
    int? maxResultCount,
  }) {
    final data = <String, dynamic>{
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': locationRestriction.center.lat,
            'longitude': locationRestriction.center.lng,
          },
          'radius': locationRestriction.radius,
        },
      },
    };

    final langCode = _locale?.languageCode;
    if (langCode != null) data['languageCode'] = langCode;

    if (includedTypes != null && includedTypes.isNotEmpty) {
      data['includedTypes'] = includedTypes;
    }
    if (includedPrimaryTypes != null && includedPrimaryTypes.isNotEmpty) {
      data['includedPrimaryTypes'] = includedPrimaryTypes;
    }
    if (excludedTypes != null && excludedTypes.isNotEmpty) {
      data['excludedTypes'] = excludedTypes;
    }
    if (excludedPrimaryTypes != null && excludedPrimaryTypes.isNotEmpty) {
      data['excludedPrimaryTypes'] = excludedPrimaryTypes;
    }
    if (maxResultCount != null) data['maxResultCount'] = maxResultCount;
    if (regionCode != null) data['regionCode'] = regionCode;

    if (rankPreference != null) {
      data['rankPreference'] = rankPreference.value;
    }

    return data;
  }

  List<inter.Place> _parsePlacesList(Map<String, Object?> json) {
    final placesJson = json['places'] as List?;
    if (placesJson == null) return const [];
    return placesJson
        .map((p) => parsePlaceFromJson(p as Map<String, Object?>))
        .toList(growable: false);
  }

  Future<Map<String, Object?>> _doGet(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _httpClient.get(Uri.parse(url), headers: headers);

    String? strBody;
    String strBodyErr = '';
    try {
      strBody = utf8.decode(response.bodyBytes);
    } catch (err) {
      strBodyErr = 'Failed decoding body! $err';
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        strBody == null) {
      final err =
          "Bad result on GET $url. Status code (${response.statusCode}), body: $strBody, bodyFetchErr (if any): $strBodyErr";
      throw err;
    }

    return jsonDecode(strBody) as Map<String, Object?>;
  }

  Future<T> _doPost<T>(
    String url,
    Object body,
    T Function(Map<String, Object?>) jsonParser, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    String? strBody;
    String strBodyErr = '';
    try {
      strBody = utf8.decode(response.bodyBytes);
    } catch (err) {
      strBodyErr = 'Failed decoding body! $err';
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        strBody == null) {
      final err =
          "Bad result on call to $url. Status code (${response.statusCode}), body: $strBody, bodyFetchErr (if any): $strBodyErr";
      throw err;
    }

    final Map<String, Object?> jsonBody = jsonDecode(strBody);
    return jsonParser(jsonBody);
  }
}
