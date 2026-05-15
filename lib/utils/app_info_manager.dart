import '../model/product_model.dart';
import 'local_store.dart';
import 'package:flutter/foundation.dart';

class AppInfoManager {
  static const String _keyToken = 'app_token';
  static const String _keyPushToken = 'push_token';
  static const String _keyPhone = 'user_phone';
  static const String _keyLoginTime = 'login_time';
  static const String _keyADJustInit = 'ad_just_init';
  static ProductModel? _productModel;
  static final ValueNotifier<int> loginVersion = ValueNotifier<int>(0);
  static final ValueNotifier<int> homeRefreshVersion = ValueNotifier<int>(0);
  static String? _tokenCache;
  static String? _phoneCache;
  static Map<String, dynamic>? _locationInfo;

  static Future<void> init() async {
    await LocalStore.init();
    _tokenCache = LocalStore.getString(_keyToken);
    _phoneCache = LocalStore.getString(_keyPhone);
  }

  static Future<void> setToken(String token) async {
    _tokenCache = token;
    await LocalStore.setString(_keyToken, token);
  }

  static String get token => _tokenCache ?? LocalStore.getString(_keyToken);

  static Future<void> setPushToken(String token) async {
    await LocalStore.setString(_keyPushToken, token);
  }

  static String get pushToken => LocalStore.getString(_keyPushToken);

  static Future<void> setPhone(String phone) async {
    _phoneCache = phone;
    await LocalStore.setString(_keyPhone, phone);
  }

  static String get phone => _phoneCache ?? LocalStore.getString(_keyPhone);

  static Future<void> setLoginTime(String loginTime) async {
    await LocalStore.setString(_keyLoginTime, loginTime);
  }

  static String get loginTime => LocalStore.getString(_keyLoginTime);

  static Future<void> setAdJustInit(bool status) async {
    await LocalStore.setBool(_keyADJustInit, status);
  }

  static bool get adJustInit => LocalStore.getBool(_keyADJustInit);

  static Future<void> clearAuth() async {
    _tokenCache = '';
    await LocalStore.remove(_keyToken);
  }

  static bool isLoggedIn() {
    return token != '';
  }

  static void notifyLogin() {
    loginVersion.value += 1;
  }

  static void notifyLogout() {
    loginVersion.value += 1;
  }

  static void notifyHomeRefresh() {
    homeRefreshVersion.value += 1;
  }

  static void setProductModel(ProductModel model) {
    _productModel = model;
  }

  static ProductModel? get productModel => _productModel;

  static String get productId => _productModel?.uniquely ?? '';
  static String get orderNo => _productModel?.sirens ?? '';

  static void setLocationInfo(Map<String, dynamic> info) {
    _locationInfo = info;
  }

  static bool get hasLocationInfoCache => _locationInfo != null;

  static Map<String, dynamic> get locationInfo =>
      _locationInfo ??
      {
        'czarevitches': '',
        'relatively': '',
        'cathodically': '',
        'hirsuteness': {
          'subscripts': '',
          'nonfinite': '',
          'isocyanates': '',
          'imitators': '',
          'jilting': '',
          'confiscate': '',
        },
      };
}
