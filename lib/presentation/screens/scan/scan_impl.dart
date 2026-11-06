// Routes to web or mobile implementation at compile time.
// dart.library.html  = web (Chrome)
// dart.library.io    = native (Android)
export 'scan_screen_web.dart'
    if (dart.library.io) 'scan_screen_mobile.dart';
