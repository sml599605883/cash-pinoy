import 'package:cash_pinoy/tools/json.dart';

class AddressModel {
  final String uniquely;
  final String unpaid;
  final List<AddressModel> bleaching;

  AddressModel({
    required this.uniquely,
    required this.unpaid,
    required this.bleaching,
  });

  factory AddressModel.fromJson(Json json) {
    return AddressModel(
      uniquely: json['uniquely'].stringValue,
      unpaid: json['unpaid'].stringValue,
      bleaching: json['bleaching'].listValue
          .map((e) => AddressModel.fromJson(e))
          .toList(),
    );
  }
}
