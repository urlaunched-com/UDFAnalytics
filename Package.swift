// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UDFAnalytics",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "UDFAnalytics",
            targets: ["UDFAnalytics"]
        ),
        .library(
            name: "UDFAnalyticsFirebase",
            targets: ["UDFAnalyticsFirebase"]
        ),
        .library(
            name: "UDFAnalyticsAmplitude",
            targets: ["UDFAnalyticsAmplitude"]
        ),
        .library(
            name: "UDFAnalyticsMixpanel",
            targets: ["UDFAnalyticsMixpanel"]
        ),
        .library(
            name: "UDFAnalyticsAppsFlyer",
            targets: ["UDFAnalyticsAppsFlyer"]
        ),
        .library(
            name: "UDFAnalyticsFacebook",
            targets: ["UDFAnalyticsFacebook"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Maks-Jago/SwiftUI-UDF", from: "1.4.5"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        .package(url: "https://github.com/amplitude/Amplitude-Swift", from: "1.14.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.2.6"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", from: "6.13.2"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", from: "18.0.0")
    ],
    targets: [
        .target(
            name: "UDFAnalytics",
            dependencies: [
                .product(name: "UDF", package: "SwiftUI-UDF")
            ]
        ),
        .target(
            name: "UDFAnalyticsFirebase",
            dependencies: [
                .target(name: "UDFAnalytics"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]
        ),
        .target(
            name: "UDFAnalyticsAmplitude",
            dependencies: [
                .target(name: "UDFAnalytics"),
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift")
            ]
        ),
        .target(
            name: "UDFAnalyticsMixpanel",
            dependencies: [
                .target(name: "UDFAnalytics"),
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ]
        ),
        .target(
            name: "UDFAnalyticsAppsFlyer",
            dependencies: [
                .target(name: "UDFAnalytics"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework")
            ]
        ),
        .target(
            name: "UDFAnalyticsFacebook",
            dependencies: [
                .target(name: "UDFAnalytics"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk")
            ]
        )
    ]
)
