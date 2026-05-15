import 'dart:convert';
import 'dart:math';

import 'package:cash_pinoy/network/api_data_handler.dart';
import 'package:cash_pinoy/network/api_client.dart';
import 'package:cash_pinoy/network/api_endpoints.dart';
import 'package:cash_pinoy/network/api_signer.dart';
import 'package:cash_pinoy/tools/json.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:dio/dio.dart';

enum HttpMethod { get, post }

class ApiEndpoint {
  final String path;
  final HttpMethod method;
  final bool isUpload;

  const ApiEndpoint(
    this.path, {
    this.method = HttpMethod.get,
    this.isUpload = false,
  });
}

class ApiManager {
  static const String defaultBaseApiUrl =
      'https://platform.babamunshi.com/phpin';
  static const String defaultBaseWebUrl = 'https://platform.babamunshi.com';
  static const String defaultInfoUrl =
      'https://raw.githubusercontent.com/BLMC22/cash-pinoy/refs/heads/main/url';

  static String baseUrl = defaultBaseApiUrl;
  static String baseWeb = defaultBaseWebUrl;
  static Map<String, dynamic> commonParams = {};
  static Map<String, dynamic> Function()? commonParamsProvider;
  static Future<Map<String, dynamic>> Function()? commonParamsAsyncProvider;

  static const String signatureKey = 'malcontent';

  static const Map<String, String> _commonFieldMap = {
    'appVersion': 'sharns',
    'deviceName': 'provider',
    'deviceId': 'untruest',
    'osVersion': 'frivoled',
    'appMarket': 'stereoisomerism',
    'sessionId': 'minesweepers',
    'gps_adid': 'ammunitions',
    'signature': 'malcontent',
    'timestamp': 'atlas',
  };

  static List<String> logs = [];

  static void configure({
    required String baseUrl,
    Map<String, dynamic>? commonParams,
    Map<String, dynamic> Function()? commonParamsProvider,
    Future<Map<String, dynamic>> Function()? commonParamsAsyncProvider,
  }) {
    ApiManager.baseUrl = baseUrl;
    ApiManager.commonParams = commonParams ?? {};
    ApiManager.commonParamsProvider = commonParamsProvider;
    ApiManager.commonParamsAsyncProvider = commonParamsAsyncProvider;
  }

  static Map<String, dynamic> buildCommonParams() {
    final source = commonParamsProvider?.call() ?? commonParams;
    final mapped = <String, dynamic>{};
    source.forEach((key, value) {
      final mappedKey = _commonFieldMap[key] ?? key;
      mapped[mappedKey] = value;
    });
    return mapped;
  }

  static Future<Map<String, dynamic>> buildCommonParamsAsync({
    String path = '',
  }) async {
    var params = <String, dynamic>{};
    if (commonParamsAsyncProvider != null) {
      final source = await commonParamsAsyncProvider!.call();
      source.forEach((key, value) {
        final mappedKey = _commonFieldMap[key] ?? key;
        params[mappedKey] = value;
      });
    }
    if (params.isEmpty) {
      params = buildCommonParams();
    }
    final signature = ApiSigner.sign(mappedCommonParams: params, path: path);
    params[ApiManager.signatureKey] = signature;
    params['celebrators'] = _obfuscationToken();
    return params;
  }

  static String _obfuscationToken([int length = 8]) {
    final random = Random.secure();
    const digits = '0123456789';
    return List.generate(
      length,
      (_) => digits[random.nextInt(digits.length)],
    ).join();
  }

  static Future<void> initBaseUrl({
    String? infoUrl,
    String? fallbackUrl,
  }) async {
    final fallback = fallbackUrl ?? baseUrl;
    logs.add('try link $fallback');
    if (await _isUrlAvailable(fallback)) {
      logs.add('$fallback link success');
      baseUrl = fallback;
      return;
    }
    logs.add('$fallback link error');

    logs.add('link github load new url');
    final remoteInfo = await _loadRemoteInfo(defaultInfoUrl);
    if (remoteInfo == null) {
      logs.add('link github error');
      return;
    }
    final (apiUrl, webUrl) = _parseApiUrl(remoteInfo);
    logs.add('link github success new url is $apiUrl');

    logs.add('try link $apiUrl');
    if (apiUrl.isNotEmpty && await _isUrlAvailable(apiUrl)) {
      logs.add('$apiUrl link success');
      baseUrl = apiUrl;
      baseWeb = webUrl;
      ApiClient.instance.reapplyProxy();
      reportChangeLog();
      return;
    }

    logs.add('$apiUrl link error');
    baseUrl = fallback;
  }

  static Future<bool> _isUrlAvailable(String url) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      ApiClient.instance.applyProxyTo(dio);
      final response = await dio.get(url);
      final data = ApiDataHandler.parse(response.data);
      return data.isSuccess;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _loadRemoteInfo(String url) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          responseType: ResponseType.plain,
        ),
      );
      ApiClient.instance.applyProxyTo(dio);
      final response = await dio.get(url);
      return response.data?.toString();
    } catch (_) {
      return null;
    }
  }

  static (String, String) _parseApiUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return ('', '');
    final decoded = _tryDecodeBase64(raw.trim());
    final json = Json.parse(decoded);
    final api = json.listValue.first['api'].stringOrNull ?? '';
    final web = json.listValue.first['web'].stringOrNull ?? '';
    return (api, web);
  }

  static String _tryDecodeBase64(String raw) {
    try {
      final normalized = raw.replaceAll(RegExp(r'\\s+'), '');
      final bytes = base64.decode(normalized);
      return utf8.decode(bytes);
    } catch (_) {
      return raw;
    }
  }

  static Future<void> reportChangeLog() async {
    try {
      await AppApi().uploadTag(log: Json(logs).rawString());
    } catch (e) {
      print(RequestError.message(e));
    }
  }
}
