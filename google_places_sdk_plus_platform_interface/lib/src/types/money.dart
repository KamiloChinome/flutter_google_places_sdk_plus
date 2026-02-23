import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';
part 'money.g.dart';

/// Represents an amount of money with its currency type.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#Money
@freezed
sealed class Money with _$Money {
  /// Constructs a [Money] object.
  const factory Money({
    /// The three-letter currency code defined in ISO 4217.
    String? currencyCode,

    /// The whole units of the amount.
    /// For example if [currencyCode] is "USD", then 1 unit is one US dollar.
    String? units,

    /// Number of nano (10^-9) units of the amount.
    /// The value must be between -999,999,999 and +999,999,999 inclusive.
    int? nanos,
  }) = _Money;

  /// Parse a [Money] from json.
  factory Money.fromJson(Map<String, Object?> json) => _$MoneyFromJson(json);
}
