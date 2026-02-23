import 'package:google_places_sdk_plus_http/google_places_sdk_plus_http.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart';
import 'package:google_places_sdk_plus_windows/google_places_sdk_plus_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterGooglePlacesSdkWindowsPlugin', () {
    test('registerWith sets platform instance', () {
      FlutterGooglePlacesSdkWindowsPlugin.registerWith();
      expect(
        FlutterGooglePlacesSdkPlatform.instance,
        isA<FlutterGooglePlacesSdkWindowsPlugin>(),
      );
    });

    test('extends FlutterGooglePlacesSdkHttpPlugin', () {
      final plugin = FlutterGooglePlacesSdkWindowsPlugin();
      expect(plugin, isA<FlutterGooglePlacesSdkHttpPlugin>());
    });

    test('extends FlutterGooglePlacesSdkPlatform', () {
      final plugin = FlutterGooglePlacesSdkWindowsPlugin();
      expect(plugin, isA<FlutterGooglePlacesSdkPlatform>());
    });

    test('can be used as platform instance', () {
      final plugin = FlutterGooglePlacesSdkWindowsPlugin();
      FlutterGooglePlacesSdkPlatform.instance = plugin;
      expect(FlutterGooglePlacesSdkPlatform.instance, same(plugin));
    });
  });
}
