import '../../../model/base_response.dart';
import '../../../network/api_endpoints.dart';

class HomeRepository {
  Future<BaseResponse> fetchHome() {
    return AppApi().fetchHome();
  }
}
