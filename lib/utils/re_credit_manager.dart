import 'dart:async';

import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:cash_pinoy/screens/home_shell.dart';

class ReCreditManager {
  static Timer? _timer;
  static bool _running = false;
  static bool _checking = false;
  static bool _pageVisible = false;
  static String _productId = '';

  static void start(String productId) {
    _productId = productId;
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _check());
    _check();
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  static void setPageVisible(bool visible) {
    _pageVisible = visible;
  }

  static Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final response = await AppApi().reCreditCheck();
      final risorgimentos = response.dysphasias['risorgimentos'].intValue;
      if (risorgimentos == 1) {
        stop();
        _handleSuccess();
      }
    } catch (e) {
      // ignore errors for polling
      // ignore: avoid_print
      print(RequestError.message(e));
    } finally {
      _checking = false;
    }
  }

  static void _handleSuccess() {
    if (_productId.isEmpty) return;
    if (_pageVisible) {
      NavHelper.enterProduct(productId: _productId, checkLocation: false);
      return;
    }
    if (HomeShell.tabIndex.value == 0) {
      AppInfoManager.notifyHomeRefresh();
    }
  }
}
