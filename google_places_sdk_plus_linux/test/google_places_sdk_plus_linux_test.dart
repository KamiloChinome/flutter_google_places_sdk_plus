import 'package:google_places_sdk_plus_http/google_places_sdk_plus_http.dart';
import 'package:google_places_sdk_plus_linux/google_places_sdk_plus_linux.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterGooglePlacesSdkLinuxPlugin', () {
    test('registerWith sets platform instance', () {
      FlutterGooglePlacesSdkLinuxPlugin.registerWith();
      expect(
        FlutterGooglePlacesSdkPlatform.instance,
        isA<FlutterGooglePlacesSdkLinuxPlugin>(),
      );
    });

    test('extends FlutterGooglePlacesSdkHttpPlugin', () {
      final plugin = FlutterGooglePlacesSdkLinuxPlugin();
      expect(plugin, isA<FlutterGooglePlacesSdkHttpPlugin>());
    });

    test('extends FlutterGooglePlacesSdkPlatform', () {
      final plugin = FlutterGooglePlacesSdkLinuxPlugin();
      expect(plugin, isA<FlutterGooglePlacesSdkPlatform>());
    });

    test('can be used as platform instance', () {
      final plugin = FlutterGooglePlacesSdkLinuxPlugin();
      FlutterGooglePlacesSdkPlatform.instance = plugin;
      expect(FlutterGooglePlacesSdkPlatform.instance, same(plugin));
    });
  });
}
