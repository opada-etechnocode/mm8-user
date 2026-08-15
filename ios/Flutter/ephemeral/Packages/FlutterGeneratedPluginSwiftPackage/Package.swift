// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.6")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "app_links", path: "../.packages/app_links-6.4.1"),
        .package(name: "app_tracking_transparency", path: "../.packages/app_tracking_transparency-2.0.7"),
        .package(name: "audio_session", path: "../.packages/audio_session-0.2.4"),
        .package(name: "audioplayers_darwin", path: "../.packages/audioplayers_darwin-6.4.0"),
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus-7.3.1"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-12.4.0"),
        .package(name: "emoji_picker_flutter", path: "../.packages/emoji_picker_flutter-4.4.0"),
        .package(name: "file_picker", path: "../.packages/file_picker-10.3.10"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-6.5.6"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.12.1"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-16.4.3"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications-20.1.0"),
        .package(name: "flutter_pdfview", path: "../.packages/flutter_pdfview-1.4.4"),
        .package(name: "flutter_secure_storage_darwin", path: "../.packages/flutter_secure_storage_darwin-0.3.2"),
        .package(name: "geocoding_ios", path: "../.packages/geocoding_ios-3.1.0"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.3.14"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios-6.2.5"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13+3"),
        .package(name: "just_audio", path: "../.packages/just_audio-0.10.6"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-9.0.1"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.5.1"),
        .package(name: "permission_handler_apple", path: "../.packages/permission_handler_apple-9.5.0"),
        .package(name: "pointer_interceptor_ios", path: "../.packages/pointer_interceptor_ios-0.10.1+1"),
        .package(name: "share_plus", path: "../.packages/share_plus-12.0.2"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.2"),
        .package(name: "sqlite3_flutter_libs", path: "../.packages/sqlite3_flutter_libs-0.5.42"),
        .package(name: "syncfusion_flutter_pdfviewer", path: "../.packages/syncfusion_flutter_pdfviewer-32.2.9"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.3.6"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.8.9"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.4.0"),
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.25.0"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "app-links", package: "app_links"),
                .product(name: "app-tracking-transparency", package: "app_tracking_transparency"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "audioplayers-darwin", package: "audioplayers_darwin"),
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "emoji-picker-flutter", package: "emoji_picker_flutter"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "flutter-pdfview", package: "flutter_pdfview"),
                .product(name: "flutter-secure-storage-darwin", package: "flutter_secure_storage_darwin"),
                .product(name: "geocoding-ios", package: "geocoding_ios"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "permission-handler-apple", package: "permission_handler_apple"),
                .product(name: "pointer-interceptor-ios", package: "pointer_interceptor_ios"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "sqlite3-flutter-libs", package: "sqlite3_flutter_libs"),
                .product(name: "syncfusion-flutter-pdfviewer", package: "syncfusion_flutter_pdfviewer"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
