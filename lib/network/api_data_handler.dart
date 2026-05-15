import '../model/base_response.dart';
import '../tools/json.dart';

class ApiDataHandler {
  static BaseResponse parse(dynamic data) {
    final json = Json(data);
    if (json.mapValue.isEmpty) {
      return BaseResponse(
        juridic: -1,
        amenorrheic: 'empty response',
        dysphasias: Json(null),
      );
    }
    return BaseResponse.fromJson(json);
  }
}
