import 'dart:convert';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_session_failure.dart';
import 'package:adjust_sdk/adjust_session_success.dart';
import 'package:cash_pinoy/model/base_response.dart';
import 'package:cash_pinoy/network/api_crypto.dart';
import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/native_bridge.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:cash_pinoy/utils/screen_adapter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ReportManager {
  static Future<void> reportLocation({
    String? adminArea,
    required String countryCode,
    required String countryName,
    required String featureName,
    required String latitude,
    required String longitude,
    required String locality,
  }) async {
    try {
      await DataReportApi().reportLocation(
        adminArea: adminArea,
        countryCode: countryCode,
        countryName: countryName,
        featureName: featureName,
        latitude: latitude,
        longitude: longitude,
        locality: locality,
      );
    } catch (e) {
      print(RequestError.message(e));
    }
  }

  static Future<void> reportGoogleMarket() async {
    final deviceInfo = await NativeBridge.getIosIdentifiers();
    final idfv = deviceInfo?['idfv'] ?? '';
    final idfa = deviceInfo?['idfa'] ?? '';
    try {
      final response = await DataReportApi().reportGoogleMarket(
        idfv: idfv,
        idfa: idfa,
      );
      final harbouring = response.dysphasias['harbouring'].stringValue;
      if (harbouring.isNotEmpty && !AppInfoManager.adJustInit) {
        final config = AdjustConfig(harbouring, AdjustEnvironment.production);
        config.isSendingInBackgroundEnabled = true;
        config.sessionSuccessCallback = (AdjustSessionSuccess success) {
          // loggerTools.e(success.jsonResponse ?? '');
          AppInfoManager.setAdJustInit(true);
        };
        config.sessionFailureCallback = (AdjustSessionFailure failure) {
          // loggerTools.e(failure.jsonResponse ?? '');
        };
        Adjust.initSdk(config);
      }
    } catch (_) {}
  }

  static Future<void> reportBuriedPoint({
    required Map<String, dynamic> params,
  }) async {
    try {
      await DataReportApi().reportBuriedPoint(params: params);
    } catch (e) {
      // ignore: avoid_print
      print(RequestError.message(e));
    }
  }

  static Future<void> reportDeviceInfo() async {
    if (!AppInfoManager.isLoggedIn()) return;
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final batteryInfo = await NativeBridge.getBatteryInfo();
    final iosInfo = await NativeBridge.getIosIdentifiers();
    final idfv = iosInfo?['idfv'] ?? '';
    final idfa = iosInfo?['idfa'] ?? '';
    final uptime = await NativeBridge.getDeviceUptime();
    final proxyFlag = await NativeBridge.getProxyEnabled();
    final vpn = await NativeBridge.getVpnEnabled();
    final rooted = await NativeBridge.getRooted();
    final isEmu = await NativeBridge.getIsEmulator();
    final lang = await NativeBridge.getDeviceLanguage();
    final carrier = await NativeBridge.getCarrierName();
    final netType = await NativeBridge.getNetworkType();
    List<Map<String, String>> syndicalist = [];
    final tz = await NativeBridge.getTimeZoneId();
    final cores = await NativeBridge.getCpuCores();
    final name = await NativeBridge.getDeviceName();
    final inches = await NativeBridge.getScreenInches();
    final wifiInfo = await NativeBridge.getWifiInfo();
    final storageInfo = await NativeBridge.getDeviceStorageInfo();
    Map<String, dynamic> data = {
      'tensities': iosDeviceInfo.systemVersion,
      'unburdened': AppInfoManager.loginTime,
      'stinkwoods': packageInfo.packageName,
      'proconsulate': batteryInfo,
      'edacity': AppInfoManager.locationInfo,
      'injudiciousness': {
        'moderate': idfv,
        'spiritualist': idfa,
        'slipped': wifiInfo['bssid'].stringValue,
        'obelus': DateTime.now().millisecondsSinceEpoch,
        'client': '${uptime ?? ''}',
        'imbalances': proxyFlag,
        'polarization': vpn,
        'kickboard': rooted,
        'mayflies': isEmu,
        'stampers': lang,
        'nieces': carrier,
        'gills': netType,
        'syndicalist': syndicalist,
        'montaging': tz,
        'didappers': uptime ?? 0,
      },
      'goaling': {
        'aspersor': 'QC_Reference_Phone',
        'bunks': 'iPhone',
        'ethionines': cores,
        'tomorrow': ScreenAdapter.screenH,
        'plasmons': name,
        'finitenesses': ScreenAdapter.screenW,
        'risk': iosDeviceInfo.modelName,
        'porcelainlike': inches,
        'conferee': iosDeviceInfo.systemVersion,
      },
      'outsmarting': {
        'secretaryship': wifiInfo['ip'].stringValue,
        'arenous': [
          {
            'unpaid': wifiInfo['ssid'].stringValue,
            'pities': wifiInfo['bssid'].stringValue,
            'slipped': wifiInfo['bssid'].stringValue,
            'surenesses': wifiInfo['ssid'].stringValue,
          },
        ],
        'chumminesses': {
          'unpaid': wifiInfo['ssid'].stringValue,
          'pities': wifiInfo['bssid'].stringValue,
          'slipped': wifiInfo['bssid'].stringValue,
          'surenesses': wifiInfo['ssid'].stringValue,
        },
        'undecidable': wifiInfo['wifiCount'].intValue,
      },
      'ourself': storageInfo,
    };
    final raw = Json(data).rawString();
    final encrypted = ApiCrypto.encryptText(raw);
    await DataReportApi().reportDeviceInfo(data: encrypted);
  }

  static Future<BaseResponse> uploadContactList({
    required String type,
    required dynamic data,
  }) {
    final payload = data is String ? data : jsonEncode(data);
    return DataReportApi().uploadContactList(type: type, data: payload);
  }

  static Future<void> uploadApplePushToken() async {
    final appleToken = await NativeBridge.getPushToken();
    await DataReportApi().uploadApplePushToken(appleToken: appleToken);
  }

  static Future<Map<String, String>?> fetchNativeLocationInfo() async {
    final raw = await NativeBridge.getCurrentLocation();
    if (raw == null) return null;
    final info = raw.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    _cacheLocationInfo(info);
    return info;
  }

  static Future<void> reportLocationFromNative() async {
    if (!AppInfoManager.isLoggedIn()) return;
    final info = await fetchNativeLocationInfo();
    final locationStatus =
        await NativeBridge.isLocationPermissionNotDetermined();
    if (!locationStatus) {
      reportDeviceInfo();
    }
    if (info == null) return;
    final infoJson = Json(info);
    await reportLocation(
      adminArea: infoJson['adminArea'].stringValue,
      countryCode: infoJson['countryCode'].stringValue,
      countryName: infoJson['countryName'].stringValue,
      featureName: infoJson['featureName'].stringValue,
      latitude: infoJson['latitude'].stringValue,
      longitude: infoJson['longitude'].stringValue,
      locality: infoJson['locality'].stringValue,
    );
  }

  static Future<void> reportBuriedPointWithLocation({
    required String productId,
    required String sceneType,
    required String orderNo,
    required String startTime,
  }) async {
    try {
      final deviceInfo = await NativeBridge.getIosIdentifiers();
      Map<String, dynamic> params = {
        'enfeeblement': productId,
        'prednisones': sceneType,
        'sirens': orderNo,
        'extraverts': deviceInfo?['idfv'] ?? '',
        'preparedness': deviceInfo?['idfa'] ?? '',
        'branchlet': startTime,
        'boogeyman': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      };
      var info = await fetchNativeLocationInfo().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (info == null && AppInfoManager.hasLocationInfoCache) {
        info = _restoreLocationInfoFromCache();
      }
      final infoJson = Json(info);
      params.addAll({
        'brisket': infoJson['longitude'].stringOrNull ?? '',
        'imponderable': infoJson['latitude'].stringOrNull ?? '',
      });
      await reportBuriedPoint(params: params);
    } catch (e) {
      print(e.toString());
    }
  }

  static void _cacheLocationInfo(Map<String, String> info) {
    final json = Json(info);
    AppInfoManager.setLocationInfo({
      'czarevitches': json['longitude'].stringValue,
      'relatively': json['latitude'].stringValue,
      'cathodically': _buildGpsAddress(json),
      'hirsuteness': {
        'subscripts': json['countryName'].stringValue,
        'nonfinite': json['countryCode'].stringValue,
        'isocyanates': json['adminArea'].stringValue,
        'imitators': json['locality'].stringValue,
        'jilting': json['extemporaneous'].stringValue,
        'confiscate': json['featureName'].stringValue,
      },
    });
  }

  static String _buildGpsAddress(Json json) {
    final parts = [
      json['countryName'].stringValue,
      json['adminArea'].stringValue,
      json['locality'].stringValue,
      json['featureName'].stringValue,
    ].where((e) => e.trim().isNotEmpty).toList();
    return parts.join(' ');
  }

  static Map<String, String> _restoreLocationInfoFromCache() {
    final cache = Json(AppInfoManager.locationInfo);
    final addressInfo = cache['hirsuteness'];
    return {
      'longitude': cache['czarevitches'].stringValue,
      'latitude': cache['relatively'].stringValue,
      'countryName': addressInfo['subscripts'].stringValue,
      'countryCode': addressInfo['nonfinite'].stringValue,
      'adminArea': addressInfo['isocyanates'].stringValue,
      'locality': addressInfo['imitators'].stringValue,
      'extemporaneous': addressInfo['jilting'].stringValue,
      'featureName': addressInfo['confiscate'].stringValue,
    };
  }

  static Future<void> reportFaceRecognitionResult({
    required String livenessId,
    required String requestId,
    required String resultCode,
    required String result,
  }) async {
    try {
      await CertifyApi().reportTrustDecision(
        livenessId: livenessId,
        requestId: requestId,
        resultCode: resultCode,
        result: result,
      );
    } catch (e) {
      print(RequestError.message(e));
    }
  }
}
