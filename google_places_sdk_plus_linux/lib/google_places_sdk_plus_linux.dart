import 'package:google_places_sdk_plus_http/google_places_sdk_plus_http.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart';

/// Web implementation plugin for flutter google places sdk
class FlutterGooglePlacesSdkLinuxPlugin
    extends FlutterGooglePlacesSdkHttpPlugin {
  /// Registers this class as the default instance of [FlutterGooglePlacesSdkPlatform].
  static void registerWith() {
    FlutterGooglePlacesSdkPlatform.instance =
        FlutterGooglePlacesSdkLinuxPlugin();
  }
}
