import 'dart:async';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppStartupReporter {
  static bool _didRun = false;
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  static Future<void> run() async {
    if (_didRun) return;
    _didRun = true;

    final connectivity = Connectivity();
    final initial = await connectivity.checkConnectivity();
    if (!_isOnline(initial)) {
      _connectivitySub?.cancel();
      _connectivitySub = connectivity.onConnectivityChanged.listen((results) {
        if (_isOnline(results)) {
          _connectivitySub?.cancel();
          _connectivitySub = null;
          _runReports();
        }
      });
      return;
    }
    await _runReports();
  }

  static bool _isOnline(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  static Future<void> _runReports() async {
    // 1) location info (cached for later use)
    await ReportManager.reportLocationFromNative();

    // 2) google market report (idfv/idfa)
    await ReportManager.reportGoogleMarket();

    // 3) apple push token upload
    await ReportManager.uploadApplePushToken();
  }
}
