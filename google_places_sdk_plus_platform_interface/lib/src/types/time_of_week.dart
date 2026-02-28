import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/day_of_week.dart';
import 'package:google_places_sdk_plus_platform_interface/src/types/place_local_time.dart';

part 'time_of_week.freezed.dart';
part 'time_of_week.g.dart';

/// Represents a a timestamp that's identified by the day of the week, and the time in 24 hour format.
///
/// Ref: https://developers.google.com/maps/documentation/places/android-sdk/reference/com/google/android/libraries/places/api/model/TimeOfWeek
@freezed
sealed class TimeOfWeek with _$TimeOfWeek {
  /// Constructs a [TimeOfWeek] object.
  const factory TimeOfWeek({
    /// The day of the week.
    DayOfWeek? day,

    /// The time in 24 hour format, for example "1730", or "0000"
    PlaceLocalTime? time,
  }) = _TimeOfWeek;

  /// Parse an [TimeOfWeek] from json.
  factory TimeOfWeek.fromJson(Map<String, Object?> json) =>
      _$TimeOfWeekFromJson(json);
}
