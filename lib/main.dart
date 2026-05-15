import 'dart:async';

import 'package:cash_pinoy/utils/native_bridge.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app.dart';
import 'network/api_manager.dart';
import 'network/proxy_manager.dart';
import 'utils/app_launch_permission_requester.dart';
import 'utils/app_startup_reporter.dart';
import 'utils/nav_helper.dart';

Future<void> _handlePushRouteFromNative(String url) async {
  if (url.trim().isEmpty) return;
  // Wait until navigator is ready (cold start / early callback cases).
  for (var i = 0; i < 20; i++) {
    if (CashPinoyApp.navigatorKey.currentState != null &&
        CashPinoyApp.navigatorKey.currentContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavHelper.toScheme(url);
      });
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppInfoManager.init();
  await ApiManager.initBaseUrl();
  await ProxyManager.setupFromSystemProxy();
  ApiManager.configure(
    baseUrl: ApiManager.baseUrl,
    commonParamsAsyncProvider: () async {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final ids = await NativeBridge.getIosIdentifiers().timeout(
        const Duration(milliseconds: 800),
        onTimeout: () => null,
      );
      return {
        'appVersion': packageInfo.version,
        'deviceName': iosDeviceInfo.modelName,
        'deviceId': ids?['idfv'] ?? '',
        'osVersion': iosDeviceInfo.systemVersion,
        'appMarket': 'appstore-ph-cash-pinoy-ios',
        'sessionId': AppInfoManager.token,
        'gps_adid': ids?['idfv'] ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    },
  );
  NativeBridge.bindNativeEventHandlers(
    onPushRoute: _handlePushRouteFromNative,
  );
  runApp(const CashPinoyApp());
  unawaited(() async {
    await AppLaunchPermissionRequester.run();
    await AppStartupReporter.run();
  }());
}
