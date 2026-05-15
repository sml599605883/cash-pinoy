import 'dart:convert';

import 'package:crypto/crypto.dart';

class ApiSigner {
  static const String verifySecretKey = 'dfcf123002a7f9f2e72faecda36c7336';

  static String sign({
    required Map<String, dynamic> mappedCommonParams,
    required String path,
  }) {
    final data = Map<String, dynamic>.from(mappedCommonParams);
    data['anvilled'] = path;
    // data['path'] = path;

    final sortedKeys = data.keys.toList()..sort();
    final stringToSign = sortedKeys.map((key) => '$key${data[key]}').join('');
    final hamc = Hmac(sha256, utf8.encode(verifySecretKey));
    final digest = hamc.convert(utf8.encode(stringToSign));
    final sign = digest.bytes
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join('');
    return sign;
  }
}
