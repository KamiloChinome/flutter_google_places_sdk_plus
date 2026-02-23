import 'package:freezed_annotation/freezed_annotation.dart';

part 'consumer_alert.freezed.dart';
part 'consumer_alert.g.dart';

/// A link with associated language.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Link
@freezed
sealed class ConsumerAlertLink with _$ConsumerAlertLink {
  /// Constructs a [ConsumerAlertLink] object.
  const factory ConsumerAlertLink({
    /// The URL of the link.
    String? uri,

    /// The language code of the link.
    String? languageCode,
  }) = _ConsumerAlertLink;

  /// Parse a [ConsumerAlertLink] from json.
  factory ConsumerAlertLink.fromJson(Map<String, Object?> json) =>
      _$ConsumerAlertLinkFromJson(json);
}

/// Details about a consumer alert.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Details
@freezed
sealed class ConsumerAlertDetails with _$ConsumerAlertDetails {
  /// Constructs a [ConsumerAlertDetails] object.
  const factory ConsumerAlertDetails({
    /// The text description of the consumer alert details.
    String? description,

    /// A link providing more information about the alert.
    ConsumerAlertLink? link,
  }) = _ConsumerAlertDetails;

  /// Parse a [ConsumerAlertDetails] from json.
  factory ConsumerAlertDetails.fromJson(Map<String, Object?> json) =>
      _$ConsumerAlertDetailsFromJson(json);
}

/// A consumer alert placed on a place.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#ConsumerAlert
@freezed
sealed class ConsumerAlert with _$ConsumerAlert {
  /// Constructs a [ConsumerAlert] object.
  const factory ConsumerAlert({
    /// An overview of the alert.
    String? overview,

    /// Detailed information about the alert.
    ConsumerAlertDetails? details,

    /// The language code of the alert.
    String? languageCode,
  }) = _ConsumerAlert;

  /// Parse a [ConsumerAlert] from json.
  factory ConsumerAlert.fromJson(Map<String, Object?> json) =>
      _$ConsumerAlertFromJson(json);
}
