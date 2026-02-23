import 'package:freezed_annotation/freezed_annotation.dart';

part 'localized_text.freezed.dart';
part 'localized_text.g.dart';

/// Localized variant of a text in a particular language.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#LocalizedText
@freezed
sealed class LocalizedText with _$LocalizedText {
  /// Constructs a [LocalizedText] object.
  const factory LocalizedText({
    /// Localized string in the language corresponding to [languageCode].
    String? text,

    /// The text's BCP-47 language code, such as "en-US" or "sr-Latn".
    String? languageCode,
  }) = _LocalizedText;

  /// Parse a [LocalizedText] from json.
  factory LocalizedText.fromJson(Map<String, Object?> json) =>
      _$LocalizedTextFromJson(json);
}
