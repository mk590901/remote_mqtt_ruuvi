import 'package:flutter/foundation.dart';

String platform() {
  String result = 'Unknown platform';
  if (kIsWeb) {
    result = 'Web';
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        result = 'Android';
        break;
      case TargetPlatform.iOS:
        result = 'iOS';
        break;
      case TargetPlatform.linux:
        result = 'Linux';
        break;
      case TargetPlatform.macOS:
        result = 'macOS';
        break;
      case TargetPlatform.windows:
        result = 'Windows';
        break;
      case TargetPlatform.fuchsia:
        result = 'Fuchsia';
        break;
    }
  }
  return result;
}
