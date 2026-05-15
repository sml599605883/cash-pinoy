import 'dart:async';
import 'dart:io';

import 'native_bridge.dart';

class AppLaunchPermissionRequester {
  static bool _didRun = false;

  /// Request critical permissions right after app launch.
  /// - ATT(IDFA, iOS only) first
  /// - Notification second
  static Future<void> run() async {
    if (_didRun) return;
    _didRun = true;

    if (Platform.isIOS) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      try {
        await NativeBridge.requestTrackingPermission();
      } catch (_) {
        // ignore
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      await NativeBridge.getPushToken();
    } catch (_) {
      // ignore
    }
  }
}
