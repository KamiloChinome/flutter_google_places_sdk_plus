import 'package:flutter_google_places_sdk_http/flutter_google_places_sdk_http.dart';
import 'package:flutter_google_places_sdk_linux/flutter_google_places_sdk_linux.dart';
import 'package:flutter_google_places_sdk_platform_interface/flutter_google_places_sdk_platform_interface.dart';
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
