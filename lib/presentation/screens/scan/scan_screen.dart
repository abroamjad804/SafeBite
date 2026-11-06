// Conditionally exports web or mobile ScanScreen at compile time.
// On web (dart.library.html)  → scan_screen_web.dart
// On Android (dart.library.io) → scan_screen_mobile.dart
export 'scan_screen_web.dart'
    if (dart.library.io) 'scan_screen_mobile.dart';
