import 'package:encrypt/encrypt.dart';

class ApiCrypto {
  static const String _aesKey = '7923334024c09c23';
  static const String _iv = 'b0ac0ac3fa699384';

  static String encryptText(String plainText) {
    final key = Key.fromUtf8(_aesKey);
    final iv = IV.fromUtf8(_iv);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptText(String base64Text) {
    final key = Key.fromUtf8(_aesKey);
    final iv = IV.fromUtf8(_iv);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt64(base64Text, iv: iv);
  }
}
