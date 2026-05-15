import 'package:cash_pinoy/app.dart';
import 'package:cash_pinoy/model/product_model.dart';
import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/screens/account/account_screen.dart';
import 'package:cash_pinoy/screens/certify/personal_info_screen.dart';
import 'package:cash_pinoy/screens/certify/work_info_screen.dart';
import 'package:cash_pinoy/screens/contacts/emergency_contacts_screen.dart';
import 'package:cash_pinoy/screens/face/face_screen.dart';
import 'package:cash_pinoy/screens/home_shell.dart';
import 'package:cash_pinoy/screens/id_verify/id_type_screen.dart';
import 'package:cash_pinoy/screens/login/login_screen.dart';
import 'package:cash_pinoy/screens/bind/withdraw_info_screen.dart';
import 'package:cash_pinoy/screens/order/order_list_screen.dart';
import 'package:cash_pinoy/screens/web/webview_screen.dart';
import 'package:cash_pinoy/screens/re_credit/re_credit_screen.dart';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/hud_manager.dart';
import 'package:cash_pinoy/utils/report_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'no_pop_page_route.dart';
import 'request_error.dart';
import 'permission_helper.dart';

class NavHelper {
  static NavigatorState get _nav => CashPinoyApp.navigatorKey.currentState!;
  static BuildContext? get _context => CashPinoyApp.navigatorKey.currentContext;

  static Future<bool> Function()? loginChecker;

  /// 跳转到指定页面，支持参数与是否移除当前页
  static Future<T?> to<T>(
    Widget page, {
    bool replace = false,
    RouteSettings? settings,
  }) {
    settings ??= RouteSettings(name: page.runtimeType.toString());
    final route = NoPopPageRoute<T>(builder: (_) => page, settings: settings);
    if (replace) {
      return _nav.pushReplacement(route);
    }
    return _nav.push(route);
  }

  /// 跳转并移除指定页面（按路由名）
  static Future<T?> toAndRemove<T>(
    Widget page, {
    required List<String> removeRouteNames,
    RouteSettings? settings,
  }) {
    settings ??= RouteSettings(name: page.runtimeType.toString());
    final route = NoPopPageRoute<T>(builder: (_) => page, settings: settings);
    return _nav.pushAndRemoveUntil(route, (route) {
      final name = route.settings.name;
      if (name == null) return true;
      return !removeRouteNames.contains(name);
    });
  }

  static void toScheme(String scheme, {String source = '0'}) {
    if (scheme.startsWith('ph://cash-pinoy/ios')) {
      final uri = Uri.parse(scheme.replaceAll('ph://cash-pinoy/ios/', ''));
      final path = uri.path;
      final param = uri.queryParameters;
      switch (path) {
        /// main
        case 'HaggisEpochs':
          backToHome();
          break;

        /// settings
        case 'WhisksSalukis':
          to(AccountScreen());
          break;

        /// login
        case 'Unrepeatable':
          _clearAuthAndToLogin();
          break;

        /// order list
        case 'Crudenesses':
          final orderType = Json(param)['carfare'].stringValue.isNotEmpty
              ? Json(param)['carfare'].stringValue
              : Json(param)['orderType'].stringValue;
          to(OrderListScreen(initialType: orderType));
          break;

        /// product details
        case 'Egestions':
          final productId = Json(param)['strikes'].stringValue;
          if (productId.isNotEmpty) {
            fetchProductDetail(productId: productId);
          }
          break;

        /// re credit
        case 'Penicillia':
          final productId = Json(param)['strikes'].stringValue;
          if (productId.isNotEmpty) {
            to(ReCreditScreen(productId: productId));
          }
          break;

        /// apply
        case 'DismastMisprogramed':
          final productId = Json(param)['strikes'].stringValue;
          if (productId.isNotEmpty) {
            enterProduct(productId: productId, source: source);
          }
          break;
        default:
      }
      return;
    }
    if (scheme.startsWith('http')) {
      toWeb(scheme);
      return;
    }
  }

  /// 打开内置网页
  static Future<T?> toWeb<T>(
    String url, {
    String? title,
    bool replace = false,
  }) {
    return toAndRemove(
      WebviewScreen(url: url, title: title),
      removeRouteNames: const [
        'IdTypeScreen',
        'IdSuccessScreen',
        'FaceScreen',
        'PersonalInfoScreen',
        'WorkInfoScreen',
        'EmergencyContactsScreen',
        'WithdrawInfoScreen',
        'WebviewScreen',
        'ReCreditScreen',
        'LoanDetailScreen',
      ],
      settings: const RouteSettings(name: 'WebviewScreen'),
    );
  }

  /// 返回上一页，可带回调数据
  static void back<T extends Object?>([T? result]) {
    if (_nav.canPop()) {
      _nav.pop(result);
    }
  }

  /// 返回到指定页面（通过路由名）
  static void backTo(String routeName) {
    _nav.popUntil((route) => route.settings.name == routeName);
  }

  /// 返回到主页面（Home）
  static void backToHome() {
    _nav.pushAndRemoveUntil(
      NoPopPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }

  /// 准入：登录与定位权限检查后调用 epicontinental 接口
  static Future<void> enterProduct({
    required String productId,
    String source = '0',
    bool checkLocation = true,
  }) async {
    if (!await _ensureLogin()) return;
    if (checkLocation) {
      final allowed = await _ensureLocationPermission();
      if (!allowed) return;
    }
    // 直接上报位置
    ReportManager.reportLocationFromNative();
    try {
      HudManager.showLoading();
      final response = await ProductApi().applyProduct(
        productId: productId,
        source: source,
      );
      HudManager.dismiss();
      final risorgimentos = response.dysphasias['risorgimentos'].intValue;
      final dampen = response.dysphasias['dampen'].stringValue;
      if (dampen.isNotEmpty) {
        toScheme(dampen, source: source);
      } else if (risorgimentos == 200) {
        fetchProductDetail(productId: productId);
      } else {
        final paleontologies =
            response.dysphasias['paleontologies'].stringValue;
        HudManager.showFailure(message: paleontologies);
      }
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
      // 忽略错误，后续由业务逻辑处理
    }
  }

  /// 产品详情：调用 prefacers 接口
  static Future<void> fetchProductDetail({required String productId}) async {
    try {
      HudManager.showLoading();
      final response = await ProductApi().productDetail(productId: productId);
      final productModel = ProductModel.fromJson(response.dysphasias);
      AppInfoManager.setProductModel(productModel);
      final downslide = productModel.cynical?.downslide ?? '';
      HudManager.dismiss();
      if (productModel.risorgimentos != 200) {
        if (productModel.dampen.isNotEmpty) {
          toScheme(productModel.dampen);
        } else {
          HudManager.showFailure(message: 'Failed to load product details');
        }
        return;
      }
      if (downslide.isNotEmpty) {
        if (downslide == 'ChurnOutstriving') {
          to(IdTypeScreen());
        } else if (downslide == 'Ophthalmia') {
          toAndRemove(
            FaceScreen(),
            removeRouteNames: const ['IdTypeScreen', 'IdSuccessScreen'],
          );
        } else if (downslide == 'Didactic') {
          toAndRemove(
            PersonalInfoScreen(),
            removeRouteNames: const [
              'IdTypeScreen',
              'IdSuccessScreen',
              'FaceScreen',
            ],
          );
        } else if (downslide == 'FathomlessSemiparasitic') {
          toAndRemove(
            WorkInfoScreen(),
            removeRouteNames: const [
              'IdTypeScreen',
              'IdSuccessScreen',
              'FaceScreen',
              'PersonalInfoScreen',
            ],
          );
        } else if (downslide == 'Rotes') {
          toAndRemove(
            EmergencyContactsScreen(),
            removeRouteNames: const [
              'IdTypeScreen',
              'IdSuccessScreen',
              'FaceScreen',
              'PersonalInfoScreen',
              'WorkInfoScreen',
            ],
          );
        } else if (downslide == 'Jauped') {
          toAndRemove(
            WithdrawInfoScreen(),
            removeRouteNames: const [
              'IdTypeScreen',
              'IdSuccessScreen',
              'FaceScreen',
              'PersonalInfoScreen',
              'WorkInfoScreen',
              'EmergencyContactsScreen',
              'WithdrawInfoScreen',
            ],
          );
        }
        return;
      } else {
        // confirm order
        _confirmOrder(
          productId: productModel.uniquely,
          orderNo: productModel.sirens,
          amount: productModel.goniometry,
          term: productModel.flashbulbs,
          termType: productModel.roti,
        );
      }
      print(productModel.risorgimentos);
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  static Future<void> _confirmOrder({
    required String productId,
    required String orderNo,
    required String amount,
    required String term,
    required String termType,
  }) async {
    try {
      HudManager.showLoading();
      final response = await OrderApi().pushOrder(
        orderNo: orderNo,
        amount: amount,
        term: term,
        termType: termType,
      );
      ReportManager.reportBuriedPointWithLocation(
        productId: productId,
        sceneType: '9',
        orderNo: orderNo,
        startTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      );
      final dampen = response.dysphasias['dampen'].stringValue;
      if (dampen.isNotEmpty) {
        toScheme(dampen);
      }
      HudManager.dismiss();
    } catch (e) {
      HudManager.showFailure(message: RequestError.message(e));
    }
  }

  static Future<bool> _ensureLogin() async {
    if (AppInfoManager.isLoggedIn()) return true;
    await toLogin();
    return false;
  }

  static Future<bool> toLogin() async {
    await to(LoginScreen());
    return true;
  }

  static Future<void> _clearAuthAndToLogin() async {
    await AppInfoManager.clearAuth();
    AppInfoManager.notifyLogout();
    await toLogin();
  }

  static Future<bool> _ensureLocationPermission() async {
    final context = _context;
    if (context == null) return false;
    return PermissionHelper.ensureLocationPermission(
      context,
      onOpenSettings: _openLocationSettings,
    );
  }

  static Future<void> _openLocationSettings() async {
    await openAppSettings();
  }
}
