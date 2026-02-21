#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_google_places_sdk_ios.podspec` to validate before publishing.
#
# NOTE: CocoaPods is supported but Swift Package Manager (SPM) is preferred.
# See Package.swift in this directory for SPM configuration.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_google_places_sdk_ios'
  s.version          = '0.3.0'
  s.summary          = 'iOS implementation of the Flutter Google Places SDK plugin.'
  s.description      = <<-DESC
iOS implementation of the Flutter Google Places SDK plugin, providing access to the
Google Places API (New) including place details, autocomplete, text search, and nearby search.
                       DESC
  s.homepage         = 'https://github.com/matanshukry/flutter_google_places_sdk/tree/master/flutter_google_places_sdk_ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Matan Shukry' => 'matanshukry@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Dependencies
  s.dependency 'GooglePlaces', '~> 10.1.0'
  s.static_framework = true
end
