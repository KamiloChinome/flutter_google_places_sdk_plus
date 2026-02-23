// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "google_places_sdk_plus_ios",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "flutter-google-places-sdk-ios",
            targets: ["google_places_sdk_plus_ios"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "google_places_sdk_plus_ios",
            dependencies: [],
            resources: [
                // If your plugin requires a privacy manifest, for example if it
                // uses any required reason APIs, update the PrivacyInfo.xcprivacy
                // file to describe your plugin's privacy impact, and then
                // uncomment this line. For more information, see
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
