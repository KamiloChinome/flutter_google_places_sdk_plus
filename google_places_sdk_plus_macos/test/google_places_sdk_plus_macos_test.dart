import 'package:google_places_sdk_plus_http/google_places_sdk_plus_http.dart';
import 'package:google_places_sdk_plus_macos/google_places_sdk_plus_macos.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterGooglePlacesSdkMacosPlugin', () {
    test('registerWith sets platform instance', () {
      FlutterGooglePlacesSdkMacosPlugin.registerWith();
      expect(
        FlutterGooglePlacesSdkPlatform.instance,
        isA<FlutterGooglePlacesSdkMacosPlugin>(),
      );
    });

    test('extends FlutterGooglePlacesSdkHttpPlugin', () {
      final plugin = FlutterGooglePlacesSdkMacosPlugin();
      expect(plugin, isA<FlutterGooglePlacesSdkHttpPlugin>());
    });

    test('extends FlutterGooglePlacesSdkPlatform', () {
      final plugin = FlutterGooglePlacesSdkMacosPlugin();
      expect(plugin, isA<FlutterGooglePlacesSdkPlatform>());
    });

    test('can be used as platform instance', () {
      final plugin = FlutterGooglePlacesSdkMacosPlugin();
      FlutterGooglePlacesSdkPlatform.instance = plugin;
      expect(FlutterGooglePlacesSdkPlatform.instance, same(plugin));
    });
  });
}
