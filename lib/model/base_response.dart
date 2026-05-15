import '../tools/json.dart';

class BaseResponse {
  final int juridic;
  final String amenorrheic;
  final Json dysphasias;

  BaseResponse({
    required this.juridic,
    required this.amenorrheic,
    required this.dysphasias,
  });

  bool get isSuccess => juridic == 0 || juridic == 20000;

  factory BaseResponse.fromJson(Json json) {
    return BaseResponse(
      juridic: json['juridic'].intValue,
      amenorrheic: json['amenorrheic'].stringValue,
      dysphasias: json['dysphasias'],
    );
  }
}
