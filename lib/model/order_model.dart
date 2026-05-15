import 'package:cash_pinoy/tools/json.dart';

class OrderModel {
  final String tostadas;
  final String sirens;
  final String enfeeblement;
  final String preadapt;
  final String caesiums;
  final String outdistances;
  final String imitatively;
  final String goniometry;
  final String sultans;
  final String pargetting;
  final String gaslight;
  final String affiliated;
  final String riderships;
  final String whiteners;

  OrderModel({
    required this.tostadas,
    required this.sirens,
    required this.enfeeblement,
    required this.preadapt,
    required this.caesiums,
    required this.outdistances,
    required this.imitatively,
    required this.goniometry,
    required this.sultans,
    required this.pargetting,
    required this.gaslight,
    required this.affiliated,
    required this.riderships,
    required this.whiteners,
  });

  factory OrderModel.fromJson(Json json) {
    return OrderModel(
      tostadas: json['tostadas'].stringValue,
      sirens: json['sirens'].stringValue,
      enfeeblement: json['enfeeblement'].stringValue,
      preadapt: json['preadapt'].stringValue,
      caesiums: json['caesiums'].stringValue,
      outdistances: json['outdistances'].stringValue,
      imitatively: json['imitatively'].stringValue,
      goniometry: json['goniometry'].stringValue,
      sultans: json['sultans'].stringValue,
      pargetting: json['pargetting'].stringValue,
      gaslight: json['gaslight'].stringValue,
      affiliated: json['affiliated'].stringValue,
      riderships: json['riderships'].stringValue,
      whiteners: json['whiteners'].stringValue,
    );
  }
}
