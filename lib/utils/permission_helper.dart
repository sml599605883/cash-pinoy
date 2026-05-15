import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> ensureCameraPermission(BuildContext context) async {
    final requested = await Permission.camera.request();
    if (requested.isGranted) return true;

    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    await _showCameraRetainDialog(context);
    return false;
  }

  static Future<void> _showCameraRetainDialog(BuildContext context) async {
    final action = await _showIosRetainDialog(
      context: context,
      title: 'No Camera Permission',
      message:
          'Camera access is required to complete verification. Please go to your device “Settings” and allow camera permission for this app.',
      cancelText: 'Later',
      confirmText: 'Enable Now',
    );
    if (action == _RetainAction.settings) {
      await openAppSettings();
    }
  }

  static Future<_RetainAction?> _showIosRetainDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String cancelText,
    required String confirmText,
  }) {
    return showCupertinoDialog<_RetainAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(_RetainAction.later),
            textStyle: const TextStyle(color: Color(0xFF969696)),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(_RetainAction.settings),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<bool> ensureLocationPermission(
    BuildContext context, {
    Future<void> Function()? onOpenSettings,
  }) async {
    final serviceStatus = await Permission.location.serviceStatus;
    if (serviceStatus.isDisabled) {
      final action = await _showLocationServiceRetainDialog(context);
      if (action == _RetainAction.later) {
        return true;
      }
      if (action == _RetainAction.settings) {
        await (onOpenSettings?.call() ?? openAppSettings());
      }
      return false;
    }

    var status = await Permission.location.status;
    if (status.isGranted) return true;

    status = await Permission.location.request();
    if (status.isGranted) return true;

    final action = await _showLocationRetainDialog(context);
    if (action == _RetainAction.later) {
      return true;
    }
    if (action == _RetainAction.settings) {
      await openAppSettings();
    }
    return false;
  }

  static Future<_RetainAction?> _showLocationServiceRetainDialog(
    BuildContext context,
  ) async {
    return _showIosRetainDialog(
      context: context,
      title: 'Location Disabled',
      message:
          'Location services are currently disabled, which may affect verification and account protection. Please turn on location services in “Settings” and try again.',
      cancelText: 'Later',
      confirmText: 'Enable Now',
    );
  }

  static Future<_RetainAction?> _showLocationRetainDialog(
    BuildContext context,
  ) async {
    return _showIosRetainDialog(
      context: context,
      title: 'No Location Permission',
      message:
          'Location access is required to continue verification and maintain account security. Please enable location permission in your device settings.',
      cancelText: 'Later',
      confirmText: 'Enable Now',
    );
  }
}

enum _RetainAction { later, settings }
