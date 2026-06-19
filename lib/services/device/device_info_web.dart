import 'package:web/web.dart' as web;

String describeCurrentDevice() {
  final ua = web.window.navigator.userAgent;
  return _parseUserAgent(ua);
}

String _parseUserAgent(String ua) {
  String browser = 'Browser';
  if (ua.contains('Edg/')) {
    browser = 'Edge';
  } else if (ua.contains('OPR/') || ua.contains('Opera')) {
    browser = 'Opera';
  } else if (ua.contains('Chrome/') && !ua.contains('Chromium')) {
    browser = 'Chrome';
  } else if (ua.contains('Firefox/')) {
    browser = 'Firefox';
  } else if (ua.contains('Safari/') && !ua.contains('Chrome')) {
    browser = 'Safari';
  }

  String os = 'Unknown';
  if (ua.contains('Windows NT')) {
    os = 'Windows';
  } else if (ua.contains('Macintosh') || ua.contains('Mac OS X')) {
    os = 'macOS';
  } else if (ua.contains('Android')) {
    os = 'Android';
  } else if (ua.contains('iPhone')) {
    os = 'iPhone';
  } else if (ua.contains('iPad')) {
    os = 'iPad';
  } else if (ua.contains('Linux')) {
    os = 'Linux';
  }

  return '$browser di $os';
}
