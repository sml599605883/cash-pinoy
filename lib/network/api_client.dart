import 'dart:async';
import 'dart:io';
import 'package:cash_pinoy/model/base_response.dart';
import 'package:cash_pinoy/utils/app_info_manager.dart';
import 'package:cash_pinoy/utils/nav_helper.dart';
import 'package:cash_pinoy/utils/request_error.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'api_data_handler.dart';
import 'api_manager.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  static bool _authExpiredHandling = false;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (status) => status != null,
      ),
    );
  }

  void setup({String? baseUrl, Map<String, dynamic>? headers}) {
    if (baseUrl != null) {
      ApiManager.baseUrl = baseUrl;
    }
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }
  }

  void setupProxy({
    required String host,
    required int port,
    bool allowBadCert = false,
  }) {
    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (_) => 'PROXY $host:$port';
        if (allowBadCert) {
          client.badCertificateCallback = (_, __, ___) => true;
        }
        return client;
      };
    }
  }

  Future<BaseResponse> request(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
  }) async {
    final url = '${ApiManager.baseUrl}${endpoint.path}';

    final mappedCommon = await ApiManager.buildCommonParamsAsync(
      path: endpoint.path,
    );

    Response response;
    if (endpoint.method == HttpMethod.get) {
      final queryParameters = <String, dynamic>{
        ...mappedCommon,
        if (params != null) ...params,
      };
      response = await _dio.get(
        url,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } else {
      response = await _dio.post(
        url,
        queryParameters: mappedCommon,
        data: params ?? <String, dynamic>{},
        cancelToken: cancelToken,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    }
    final data = ApiDataHandler.parse(response.data);
    if (data.juridic == -2) {
      unawaited(_handleAuthExpired());
      throw ApiException(data.amenorrheic);
    }
    if (!data.isSuccess) {
      throw ApiException(data.amenorrheic);
    }
    return data;
  }

  Future<BaseResponse> get(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
  }) {
    return request(endpoint, params: params, cancelToken: cancelToken);
  }

  Future<BaseResponse> post(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
  }) {
    return request(endpoint, params: params, cancelToken: cancelToken);
  }

  Future<BaseResponse> uploadImage(
    ApiEndpoint endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
  }) async {
    final url = '${ApiManager.baseUrl}${endpoint.path}';

    final mappedCommon = await ApiManager.buildCommonParamsAsync(
      path: endpoint.path,
    );

    final form = FormData.fromMap({
      if (params != null) ...params,
      fieldName: await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      url,
      queryParameters: mappedCommon,
      data: form,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = ApiDataHandler.parse(response.data);
    if (data.juridic == -2) {
      unawaited(_handleAuthExpired());
      throw Exception('Need Login');
    }
    if (!data.isSuccess) {
      throw ApiException(data.amenorrheic);
    }
    return data;
  }

  Future<void> _handleAuthExpired() async {
    if (_authExpiredHandling) return;
    _authExpiredHandling = true;
    try {
      await AppInfoManager.clearAuth();
      AppInfoManager.notifyLogout();
      await NavHelper.toLogin();
    } finally {
      _authExpiredHandling = false;
    }
  }
}
