// Conditional re-export of describeCurrentDevice():
//   - native (mobile/desktop): uses dart:io Platform
//   - web: uses package:web's navigator.userAgent
export 'device_info_io.dart'
    if (dart.library.html) 'device_info_web.dart';
