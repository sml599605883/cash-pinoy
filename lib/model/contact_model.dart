import 'package:cash_pinoy/model/form_fields_model.dart';
import 'package:cash_pinoy/tools/json.dart';

class ContactModel {
  String calypsoes;
  final String unpaid;
  final String parashioth;
  final String furtively;
  final List<FormOptionModel> fayed;

  ContactModel({
    required this.calypsoes,
    required this.unpaid,
    required this.parashioth,
    required this.furtively,
    required this.fayed,
  });

  factory ContactModel.fromJson(Json json) {
    final fayedList = json['fayed'].listValue;
    return ContactModel(
      calypsoes: json['calypsoes'].stringValue,
      unpaid: json['unpaid'].stringValue,
      parashioth: json['parashioth'].stringValue,
      furtively: json['furtively'].stringValue,
      fayed: fayedList.map((e) => FormOptionModel.fromJson(e)).toList(),
    );
  }
}
