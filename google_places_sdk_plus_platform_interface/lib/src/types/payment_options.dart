import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_options.freezed.dart';
part 'payment_options.g.dart';

/// Payment options the place accepts.
///
/// Ref: https://developers.google.com/maps/documentation/places/web-service/reference/rest/v1/places#PaymentOptions
@freezed
sealed class PaymentOptions with _$PaymentOptions {
  /// Constructs a [PaymentOptions] object.
  const factory PaymentOptions({
    /// Place accepts credit cards as payment.
    bool? acceptsCreditCards,

    /// Place accepts debit cards as payment.
    bool? acceptsDebitCards,

    /// Place accepts cash only as payment.
    /// Places with this attribute may still accept other payment methods.
    bool? acceptsCashOnly,

    /// Place accepts NFC payments.
    bool? acceptsNfc,
  }) = _PaymentOptions;

  /// Parse a [PaymentOptions] from json.
  factory PaymentOptions.fromJson(Map<String, Object?> json) =>
      _$PaymentOptionsFromJson(json);
}
