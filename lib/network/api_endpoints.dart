import 'dart:math';
import 'package:cash_pinoy/network/api_manager.dart';
import '../model/base_response.dart';
import 'api_client.dart';

String _obfuscationToken([int length = 8]) {
  final random = Random.secure();
  const digits = '0123456789';
  return List.generate(
    length,
    (_) => digits[random.nextInt(digits.length)],
  ).join();
}

class UserApi {
  static const ApiEndpoint GET_SMS_CODE = ApiEndpoint(
    '/depictions/millefioris',
    method: HttpMethod.post,
  );
  static const ApiEndpoint LOGIN_BY_SMS = ApiEndpoint(
    '/depictions/foreshowing',
    method: HttpMethod.post,
  );
  static const ApiEndpoint LOGOUT_USER = ApiEndpoint(
    '/depictions/juridic',
    method: HttpMethod.get,
  );
  static const ApiEndpoint DELETE_USER = ApiEndpoint(
    '/depictions/amenorrheic',
    method: HttpMethod.get,
  );

  Future<BaseResponse> getSmsCode({required String phone}) {
    return ApiClient.instance.post(
      GET_SMS_CODE,
      params: {'millefioris': phone, 'foreshowing': _obfuscationToken()},
    );
  }

  Future<BaseResponse> loginBySms({
    required String username,
    required String smsCode,
  }) {
    return ApiClient.instance.post(
      LOGIN_BY_SMS,
      params: {
        'hairstreaks': username,
        'hognoses': smsCode,
        'figuration': _obfuscationToken(),
        'glasshouse': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> logoutUser() {
    return ApiClient.instance.get(
      LOGOUT_USER,
      params: {
        'misprisions': _obfuscationToken(),
        'hapkidos': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> deleteUser() {
    return ApiClient.instance.get(
      DELETE_USER,
      params: {'liberalise': _obfuscationToken()},
    );
  }
}

class AppApi {
  static const ApiEndpoint FETCH_HOME = ApiEndpoint(
    '/depictions/dysphasias',
    method: HttpMethod.get,
  );
  static const ApiEndpoint FETCH_PERSONAL_CENTER = ApiEndpoint(
    '/depictions/hairstreaks',
    method: HttpMethod.get,
  );
  static const ApiEndpoint UPLOAD_TAG = ApiEndpoint(
    '/depictions/hognoses',
    method: HttpMethod.post,
  );
  static const ApiEndpoint RE_CREDIT_CHECK = ApiEndpoint(
    '/depictions/figuration',
    method: HttpMethod.get,
  );
  static const ApiEndpoint FETCH_DIALOG = ApiEndpoint(
    '/depictions/glasshouse',
    method: HttpMethod.get,
  );
  static const ApiEndpoint UPLOAD_BANNER_CLICK = ApiEndpoint(
    '/depictions/forestation',
    method: HttpMethod.post,
  );

  Future<BaseResponse> fetchHome() {
    return ApiClient.instance.get(
      FETCH_HOME,
      params: {'hopped': _obfuscationToken(), 'nibble': _obfuscationToken()},
    );
  }

  Future<BaseResponse> fetchPersonalCenter() {
    return ApiClient.instance.get(
      FETCH_PERSONAL_CENTER,
      params: {'outfloated': _obfuscationToken()},
    );
  }

  Future<BaseResponse> uploadTag({required String log}) {
    return ApiClient.instance.post(
      UPLOAD_TAG,
      params: {
        'salsilla': '1',
        'anagrammatizes': log,
        'impunities': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> reCreditCheck() {
    return ApiClient.instance.get(
      RE_CREDIT_CHECK,
      params: {'correct': _obfuscationToken()},
    );
  }

  Future<BaseResponse> fetchDialog({required String adaptationPage}) {
    return ApiClient.instance.get(
      FETCH_DIALOG,
      params: {'yesternights': adaptationPage},
    );
  }

  Future<BaseResponse> uploadBannerClick({required String bannerConfigId}) {
    return ApiClient.instance.post(
      UPLOAD_BANNER_CLICK,
      params: {'neuters': bannerConfigId, 'baize': _obfuscationToken()},
    );
  }
}

class ProductApi {
  static const ApiEndpoint APPLY_PRODUCT = ApiEndpoint(
    '/depictions/epicontinental',
    method: HttpMethod.post,
  );
  static const ApiEndpoint PRODUCT_DETAIL = ApiEndpoint(
    '/depictions/prefacers',
    method: HttpMethod.post,
  );

  Future<BaseResponse> applyProduct({
    required String productId,
    required String source,
  }) {
    return ApiClient.instance.post(
      APPLY_PRODUCT,
      params: {
        'strikes': productId,
        'defrauds': source,
        'untraditional': _obfuscationToken(),
        'scratcher': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> productDetail({required String productId}) {
    return ApiClient.instance.post(
      PRODUCT_DETAIL,
      params: {
        'strikes': productId,
        'supplement': _obfuscationToken(),
        'viability': _obfuscationToken(),
        'misfocusing': _obfuscationToken(),
      },
    );
  }
}

class CertifyApi {
  static const ApiEndpoint FETCH_BASIC_PERSON_INFO = ApiEndpoint(
    '/depictions/restatements',
    method: HttpMethod.get,
  );
  static const ApiEndpoint SAVE_BASIC_PERSON_INFO = ApiEndpoint(
    '/depictions/hapkidos',
    method: HttpMethod.post,
  );
  static const ApiEndpoint CHECK_BASIC_INFO = ApiEndpoint(
    '/depictions/liberalise',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_FACE_TOKEN = ApiEndpoint(
    '/depictions/hopped',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_PERSONAL_INFO = ApiEndpoint(
    '/depictions/surliest',
    method: HttpMethod.post,
  );
  static const ApiEndpoint SAVE_PERSONAL = ApiEndpoint(
    '/depictions/bleaching',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_JOB_INFO = ApiEndpoint(
    '/depictions/dipteral',
    method: HttpMethod.get,
  );
  static const ApiEndpoint SAVE_JOB = ApiEndpoint(
    '/depictions/odeons',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_EXT_INFO = ApiEndpoint(
    '/depictions/uniquely',
    method: HttpMethod.get,
  );
  static const ApiEndpoint SAVE_EXT_INFO = ApiEndpoint(
    '/depictions/dampen',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_BIND_CARD_INIT = ApiEndpoint(
    '/depictions/explainer',
    method: HttpMethod.get,
  );
  static const ApiEndpoint BIND_CARD_SUBMIT = ApiEndpoint(
    '/depictions/preadapt',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_CITY_INIT = ApiEndpoint(
    '/depictions/caesiums',
    method: HttpMethod.get,
  );
  static const ApiEndpoint FETCH_USER_CARD_LIST = ApiEndpoint(
    '/depictions/pargetting',
    method: HttpMethod.post,
  );
  static const ApiEndpoint CHANGE_BANK_CARD = ApiEndpoint(
    '/depictions/sternite',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_RETAIN_DIALOG = ApiEndpoint(
    '/depictions/charpoy',
    method: HttpMethod.post,
  );
  static const ApiEndpoint REPORT_TRUST_DECISION = ApiEndpoint(
    '/depictions/wistfulness',
    method: HttpMethod.post,
  );
  static const ApiEndpoint UPLOAD_CERTIFY_IMAGE = ApiEndpoint(
    '/depictions/misprisions',
    method: HttpMethod.post,
    isUpload: true,
  );

  Future<BaseResponse> fetchBasicPersonInfo({required String productId}) {
    return ApiClient.instance.get(
      FETCH_BASIC_PERSON_INFO,
      params: {'strikes': productId, 'unhirable': _obfuscationToken()},
    );
  }

  Future<BaseResponse> saveBasicPersonInfo({
    required String birthday,
    required String idNumber,
    required String name,
    required String type,
    required String cardType,
  }) {
    return ApiClient.instance.post(
      SAVE_BASIC_PERSON_INFO,
      params: {
        'coassisting': birthday,
        'plimsols': idNumber,
        'unpaid': name,
        'dipteral': type,
        'harrowers': cardType,
        'celebrators': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> checkBasicInfo({required String productId}) {
    return ApiClient.instance.post(
      CHECK_BASIC_INFO,
      params: {
        'strikes': productId,
        'deraign': _obfuscationToken(),
        'befogs': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> fetchFaceToken({
    required String orderNo,
    required String type,
  }) {
    return ApiClient.instance.post(
      FETCH_FACE_TOKEN,
      params: {
        'defilading': orderNo,
        'dipteral': type,
        'repeats': _obfuscationToken(),
        'admeasurement': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> fetchPersonalInfo({required String productId}) {
    return ApiClient.instance.post(
      FETCH_PERSONAL_INFO,
      params: {'strikes': productId, 'abysses': _obfuscationToken()},
    );
  }

  /// form 中的字段要求使用“上一个接口返回的 key”（已混淆后的字段名）
  Future<BaseResponse> savePersonal({
    required Map<String, dynamic> form,
    required String productId,
  }) {
    final params = <String, dynamic>{
      ...form,
      'strikes': productId,
      'freneticisms': _obfuscationToken(),
      'superbombs': _obfuscationToken(),
    };
    return ApiClient.instance.post(SAVE_PERSONAL, params: params);
  }

  Future<BaseResponse> fetchJobInfo({required String productId}) {
    return ApiClient.instance.get(
      FETCH_JOB_INFO,
      params: {'strikes': productId, 'abysses': _obfuscationToken()},
    );
  }

  /// form 中的字段要求使用“上一个接口返回的 key”（已混淆后的字段名）
  Future<BaseResponse> saveJob({
    required Map<String, dynamic> form,
    required String productId,
  }) {
    final params = <String, dynamic>{
      ...form,
      'strikes': productId,
      'proctologists': _obfuscationToken(),
      'cutinised': _obfuscationToken(),
      'gusting': _obfuscationToken(),
    };
    return ApiClient.instance.post(SAVE_JOB, params: params);
  }

  Future<BaseResponse> fetchExtInfo({required String productId}) {
    return ApiClient.instance.get(
      FETCH_EXT_INFO,
      params: {'strikes': productId, 'preplaced': _obfuscationToken()},
    );
  }

  Future<BaseResponse> saveExtInfo({
    required String productId,
    required String data,
  }) {
    return ApiClient.instance.post(
      SAVE_EXT_INFO,
      params: {
        'strikes': productId,
        'dysphasias': data,
        'busybody': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> fetchBindCardInit({required String productId}) {
    return ApiClient.instance.get(
      FETCH_BIND_CARD_INIT,
      params: {
        'strikes': productId,
        'coprosperity': _obfuscationToken(),
        'fulfils': _obfuscationToken(),
      },
    );
  }

  /// form 中的字段要求使用“上一个接口返回的 key”（已混淆后的字段名）
  Future<BaseResponse> bindCardSubmit({
    required Map<String, dynamic> form,
    required String productId,
    required String filePath,
  }) {
    final params = <String, dynamic>{
      ...form,
      'strikes': productId,
      'showcased': _obfuscationToken(),
    };
    //(BIND_CARD_SUBMIT, params: params)
    return ApiClient.instance.uploadImage(
      BIND_CARD_SUBMIT,
      filePath: filePath,
      params: params,
      fieldName: 'attach',
    );
  }

  Future<BaseResponse> fetchCityInit() {
    return ApiClient.instance.get(FETCH_CITY_INIT, params: {});
  }

  Future<BaseResponse> fetchUserCardList({required String productId}) {
    return ApiClient.instance.post(
      FETCH_USER_CARD_LIST,
      params: {
        'strikes': productId,
        'silhouetted': _obfuscationToken(),
        'jetway': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> changeBankCard({
    required String orderNo,
    required String bindId,
  }) {
    return ApiClient.instance.post(
      CHANGE_BANK_CARD,
      params: {
        'defilading': orderNo,
        'tillers': bindId,
        'rescript': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> fetchRetainDialog({
    required String inputType,
    required String productId,
  }) {
    return ApiClient.instance.post(
      FETCH_RETAIN_DIALOG,
      params: {
        'reckoners': inputType,
        'enfeeblement': productId,
        'intellectualize': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> reportTrustDecision({
    required String livenessId,
    required String requestId,
    required String resultCode,
    required String result,
  }) {
    return ApiClient.instance.post(
      REPORT_TRUST_DECISION,
      params: {
        'orpine': livenessId,
        'woodstove': requestId,
        'regulate': resultCode,
        'risorgimentos': result,
      },
    );
  }

  Future<BaseResponse> uploadCertifyImage({
    required String filePath,
    required String type,
    required String imageSource,
    required String cardType,
    String? livenessId,
    String? license,
    String? faceType,
    String? bizId,
  }) {
    return ApiClient.instance.uploadImage(
      UPLOAD_CERTIFY_IMAGE,
      filePath: filePath,
      fieldName: 'attach',
      params: {
        'dipteral': type,
        'chibouks': imageSource,
        'harrowers': cardType,
        if (livenessId != null) 'nazi': livenessId,
        if (license != null) 'phonologists': license,
        if (faceType != null) 'illiterately': faceType,
        if (bizId != null) 'checkmating': bizId,
      },
    );
  }
}

class OrderApi {
  static const ApiEndpoint PUSH_ORDER = ApiEndpoint(
    '/depictions/eavesdrops',
    method: HttpMethod.post,
  );
  static const ApiEndpoint FETCH_ORDER_LIST = ApiEndpoint(
    '/depictions/taffarel',
    method: HttpMethod.post,
  );

  Future<BaseResponse> pushOrder({
    required String orderNo,
    required String amount,
    required String term,
    required String termType,
  }) {
    return ApiClient.instance.post(
      PUSH_ORDER,
      params: {
        'defilading': orderNo,
        'goniometry': amount,
        'flashbulbs': term,
        'roti': termType,
        'spooniest': _obfuscationToken(),
        'delimit': _obfuscationToken(),
        'salsas': _obfuscationToken(),
        'imines': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> fetchOrderList({
    required String orderType,
    required String pageNum,
  }) {
    return ApiClient.instance.post(
      FETCH_ORDER_LIST,
      params: {
        'carfare': orderType,
        'indecipherable': pageNum,
        'projections': '50',
      },
    );
  }
}

class DataReportApi {
  static const ApiEndpoint REPORT_LOCATION = ApiEndpoint(
    '/depictions/precipitantness',
    method: HttpMethod.post,
  );
  static const ApiEndpoint REPORT_GOOGLE_MARKET = ApiEndpoint(
    '/depictions/amendable',
    method: HttpMethod.post,
  );
  static const ApiEndpoint REPORT_BURIED_POINT = ApiEndpoint(
    '/depictions/stabs',
    method: HttpMethod.post,
  );
  static const ApiEndpoint REPORT_DEVICE_INFO = ApiEndpoint(
    '/depictions/exaptive',
    method: HttpMethod.post,
  );
  static const ApiEndpoint UPLOAD_CONTACT_LIST = ApiEndpoint(
    '/depictions/tory',
    method: HttpMethod.post,
  );
  static const ApiEndpoint UPLOAD_APPLE_PUSH_TOKEN = ApiEndpoint(
    '/depictions/egestions',
    method: HttpMethod.post,
  );

  Future<BaseResponse> reportLocation({
    String? adminArea,
    required String countryCode,
    required String countryName,
    required String featureName,
    required String latitude,
    required String longitude,
    required String locality,
  }) {
    return ApiClient.instance.post(
      REPORT_LOCATION,
      params: {
        if (adminArea != null) 'isocyanates': adminArea,
        'nonfinite': countryCode,
        'subscripts': countryName,
        'confiscate': featureName,
        'imponderable': latitude,
        'brisket': longitude,
        'imitators': locality,
        'expatriated': _obfuscationToken(),
        'pepsine': _obfuscationToken(),
      },
    );
  }

  Future<BaseResponse> reportGoogleMarket({
    required String idfv,
    required String idfa,
  }) {
    return ApiClient.instance.post(
      REPORT_GOOGLE_MARKET,
      params: {
        'moderate': idfv,
        'scuff': _obfuscationToken(),
        'spiritualist': idfa,
      },
    );
  }

  Future<BaseResponse> reportBuriedPoint({
    required Map<String, dynamic> params,
  }) {
    return ApiClient.instance.post(
      REPORT_BURIED_POINT,
      params: {...params, 'coprosperity': _obfuscationToken()},
    );
  }

  Future<BaseResponse> reportDeviceInfo({required String data}) {
    return ApiClient.instance.post(
      REPORT_DEVICE_INFO,
      params: {'dysphasias': data},
    );
  }

  Future<BaseResponse> uploadContactList({
    required String type,
    required String data,
  }) {
    return ApiClient.instance.post(
      UPLOAD_CONTACT_LIST,
      params: {
        'dipteral': type,
        'actualities': _obfuscationToken(),
        'choicenesses': _obfuscationToken(),
        'dysphasias': data,
      },
    );
  }

  Future<BaseResponse> uploadApplePushToken({required String appleToken}) {
    return ApiClient.instance.post(
      UPLOAD_APPLE_PUSH_TOKEN,
      params: {'foining': appleToken},
    );
  }
}

class RetryApi {
  static const ApiEndpoint RETRY_ORDER_REQUESTS = ApiEndpoint(
    '/depictions/prostitute',
    method: HttpMethod.post,
  );

  Future<BaseResponse> retryOrderRequests(String sirens) {
    return ApiClient.instance.post(
      RETRY_ORDER_REQUESTS,
      params: {'sirens': sirens},
    );
  }
}
