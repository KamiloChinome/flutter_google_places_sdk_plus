import 'package:flutter/services.dart';
import 'package:google_places_sdk_plus_platform_interface/google_places_sdk_plus_platform_interface.dart';
import 'package:google_places_sdk_plus_platform_interface/method_channel_google_places_sdk_plus.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the Android plugin package.
///
/// Since the Android plugin is a native implementation with no Dart source,
/// these tests verify that the method channel contract between the platform
/// interface and the native side is correctly defined and that the platform
/// interface (which the Android plugin implements natively) behaves as expected.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'plugins.msh.com/google_places_sdk_plus';

  group('FlutterGooglePlacesSdkAndroid', () {
    final channel = MethodChannel(channelName);
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            return null;
          });
    });

    tearDown(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'default platform instance is FlutterGooglePlacesSdkMethodChannel',
      () {
        expect(
          FlutterGooglePlacesSdkPlatform.instance,
          isA<FlutterGooglePlacesSdkMethodChannel>(),
        );
      },
    );

    test('initialize sends correct method call', () async {
      final places = FlutterGooglePlacesSdkMethodChannel();
      await places.initialize('test-key');

      expect(log, hasLength(1));
      expect(log[0].method, 'initialize');
      expect(log[0].arguments['apiKey'], 'test-key');
    });

    test('deinitialize sends correct method call', () async {
      final places = FlutterGooglePlacesSdkMethodChannel();
      await places.deinitialize();

      expect(log, hasLength(1));
      expect(log[0].method, 'deinitialize');
    });

    test('findAutocompletePredictions sends correct method call', () async {
      final places = FlutterGooglePlacesSdkMethodChannel();
      await places.findAutocompletePredictions('test query', countries: ['US']);

      expect(log, hasLength(1));
      expect(log[0].method, 'findAutocompletePredictions');
      expect(log[0].arguments['query'], 'test query');
      expect(log[0].arguments['countries'], ['US']);
    });
  });
}
