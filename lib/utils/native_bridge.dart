import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('cash_pinoy/proxy');
  static Future<void> Function(String url)? _onPushRoute;
  static final List<String> _pendingPushRoutes = <String>[];
  static bool _methodHandlerBound = false;

  static void bindNativeEventHandlers({
    Future<void> Function(String url)? onPushRoute,
  }) {
    _onPushRoute = onPushRoute;
    if (!_methodHandlerBound) {
      _methodHandlerBound = true;
      _channel.setMethodCallHandler(_handleNativeCall);
    }
    _flushPendingPushRoutes();
  }

  static Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onPushRoute':
        final args = call.arguments;
        String url = '';
        if (args is String) {
          url = args;
        } else if (args is Map) {
          url = (args['url'] ?? '').toString();
        }
        if (url.isEmpty) return null;
        if (_onPushRoute == null) {
          _pendingPushRoutes.add(url);
          return null;
        }
        NavHelper.toScheme(url);
        return null;
      default:
        return null;
    }
  }

  static void _flushPendingPushRoutes() {
    if (_onPushRoute == null || _pendingPushRoutes.isEmpty) return;
    final routes = List<String>.from(_pendingPushRoutes);
    _pendingPushRoutes.clear();
    for (final route in routes) {
      _onPushRoute!(route);
    }
  }

  static Future<Map<String, dynamic>?> getSystemProxy() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getSystemProxy');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getIosIdentifiers() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getIosIdentifiers');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  /// iOS only: explicitly request ATT permission and return latest idfa.
  static Future<String> requestTrackingPermission() async {
    try {
      final result = await _channel.invokeMethod<dynamic>(
        'requestTrackingPermission',
      );
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return '';
  }

  static Future<bool> openLocationSettings() async {
    try {
      final result = await _channel.invokeMethod<dynamic>(
        'openLocationSettings',
      );
      if (result is bool) return result;
    } catch (_) {
      // ignore
    }
    return false;
  }

  /// true: not determined (never requested)
  static Future<bool> isLocationPermissionNotDetermined() async {
    try {
      final result = await _channel.invokeMethod<dynamic>(
        'isLocationPermissionNotDetermined',
      );
      if (result is bool) return result;
    } catch (_) {
      // ignore
    }
    return false;
  }

  /// iOS APNs token (Android returns empty for now)
  static Future<String> getPushToken() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getPushToken');
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// Returns battery info:
  /// dayroom: percentage string, furazolidones: "1" charging else "0"
  static Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getBatteryInfo');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {
      // ignore
    }
    return {'dayroom': '', 'furazolidones': ''};
  }

  /// iOS device uptime seconds since boot (Android returns empty for now)
  static Future<int?> getDeviceUptime() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getDeviceUptime');
      if (result is int) return result;
    } catch (_) {
      // ignore
    }
    return null;
  }

  /// whether system proxy enabled: "1" yes, "0" no
  static Future<int> getProxyEnabled() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getProxyEnabled');
      if (result is int) return result;
    } catch (_) {
      // ignore
    }
    return 0;
  }

  /// whether VPN enabled: 1 yes, 0 no
  static Future<int> getVpnEnabled() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getVpnEnabled');
      if (result is int) return result;
      if (result is String) return int.tryParse(result) ?? 0;
    } catch (_) {
      // ignore
    }
    return 0;
  }

  /// whether device is jailbroken/rooted: 1 yes, 0 no
  static Future<int> getRooted() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getRooted');
      if (result is int) return result;
      if (result is String) return int.tryParse(result) ?? 0;
    } catch (_) {
      // ignore
    }
    return 0;
  }

  /// whether device is emulator/simulator: 1 yes, 0 no
  static Future<int> getIsEmulator() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getIsEmulator');
      if (result is int) return result;
      if (result is String) return int.tryParse(result) ?? 0;
    } catch (_) {
      // ignore
    }
    return 0;
  }

  /// device language, e.g. "en", "zh-Hans"
  static Future<String> getDeviceLanguage() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getDeviceLanguage');
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// network carrier name
  static Future<String> getCarrierName() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getCarrierName');
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// network type: 2G/3G/4G/5G/WIFI/OTHER
  static Future<String> getNetworkType() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getNetworkType');
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return 'OTHER';
  }

  /// device timezone id, e.g. "Asia/Shanghai"
  static Future<String> getTimeZoneId() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getTimeZoneId');
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// available CPU cores count
  static Future<int> getCpuCores() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getCpuCores');
      if (result is int) return result;
      if (result is String) return int.tryParse(result) ?? 0;
    } catch (_) {
      // ignore
    }
    return 0;
  }

  /// iOS device name (e.g. "xxx's iPhone"), Android returns empty for now
  static Future<String> getDeviceName() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getDeviceName');
      if (result is String) return result;
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// device screen size in inches, string like "5.5"
  static Future<String> getScreenInches() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getScreenInches');
      if (result is String) return result;
      if (result is num) return result.toString();
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// iOS in-app review prompt
  static Future<bool> requestAppReview() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('requestAppReview');
      if (result is bool) return result;
      if (result is int) return result == 1;
    } catch (_) {
      // ignore
    }
    return false;
  }

  /// wifi info: ip, ssid, bssid, wifiCount
  static Future<Json> getWifiInfo() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getWifiInfo');
      if (result is Map) {
        return Json(Map<String, dynamic>.from(result));
      }
    } catch (_) {
      // ignore
    }
    return Json({'ip': '', 'ssid': '', 'bssid': '', 'wifiCount': 0});
  }

  /// iOS storage/memory info in KB (string values)
  static Future<Map<String, dynamic>> getDeviceStorageInfo() async {
    try {
      final result = await _channel.invokeMethod<dynamic>(
        'getDeviceStorageInfo',
      );
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {
      // ignore
    }
    return {'chondriosome': '', 'blatted': '', 'bouncers': '', 'towrope': ''};
  }

  /// Returns location info map:
  /// adminArea, countryCode, countryName, featureName,
  /// latitude, longitude, locality, juxtaposition, extemporaneous
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getCurrentLocation');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (_) {
      // ignore
    }
    return null;
  }
}
