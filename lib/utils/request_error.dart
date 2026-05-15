import 'package:dio/dio.dart';

class RequestError {
  static String message(dynamic error) {
    if (error == null) return 'Request failed';
    if (error is ApiException) return error.message;
    if (error is DioException) {
      final msg = error.message;
      if (msg != null && msg.trim().isNotEmpty) return msg;
      return 'Network error';
    }
    return error.toString();
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
