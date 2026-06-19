import 'dart:io' show Platform;

String describeCurrentDevice() {
  final os = _osName(Platform.operatingSystem);
  final v = Platform.operatingSystemVersion;
  // Flutter native: include short OS + version
  return v.isEmpty ? os : '$os ($v)';
}

String _osName(String raw) {
  switch (raw) {
    case 'android':
      return 'Android';
    case 'ios':
      return 'iOS';
    case 'macos':
      return 'macOS';
    case 'windows':
      return 'Windows';
    case 'linux':
      return 'Linux';
    case 'fuchsia':
      return 'Fuchsia';
    default:
      return raw;
  }
}
