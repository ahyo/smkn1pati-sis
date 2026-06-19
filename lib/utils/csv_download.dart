// Platform-conditional CSV download.
// Web   : triggers browser download via dart:html.
// Mobile: saves to temp dir and opens share sheet.
export 'csv_download_stub.dart'
    if (dart.library.html) 'csv_download_web.dart'
    if (dart.library.io) 'csv_download_io.dart';
