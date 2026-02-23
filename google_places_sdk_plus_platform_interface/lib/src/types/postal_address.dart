import 'package:freezed_annotation/freezed_annotation.dart';

part 'postal_address.freezed.dart';
part 'postal_address.g.dart';

/// Represents a postal address, e.g. for postal delivery or payments addresses.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places (adrFormatAddress / postalAddress)
@freezed
sealed class PostalAddress with _$PostalAddress {
  /// Constructs a [PostalAddress] object.
  const factory PostalAddress({
    /// The schema revision of the PostalAddress.
    /// All new revisions MUST be backward compatible with old revisions.
    int? revision,

    /// CLDR region code of the country/region of the address.
    String? regionCode,

    /// BCP-47 language code of the contents of this address.
    String? languageCode,

    /// Postal code of the address.
    String? postalCode,

    /// Sorting code — this is optional and used in some countries.
    String? sortingCode,

    /// Highest administrative subdivision which is used for postal addresses.
    /// For example, this can be a state, a province, an oblast, or a prefecture.
    String? administrativeArea,

    /// A locality or city.
    String? locality,

    /// A civil region below the locality.
    String? sublocality,

    /// Unstructured address lines describing the lower levels of an address.
    List<String>? addressLines,

    /// The recipient at the address.
    List<String>? recipients,

    /// The name of the organization at the address.
    String? organization,
  }) = _PostalAddress;

  /// Parse a [PostalAddress] from json.
  factory PostalAddress.fromJson(Map<String, Object?> json) =>
      _$PostalAddressFromJson(json);
}
