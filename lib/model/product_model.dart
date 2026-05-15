import 'package:cash_pinoy/tools/json.dart';

class ProductModel {
  final int risorgimentos;
  final String goniometry;
  final String uniquely;
  final String sirens;
  final String tostadas;
  final String flashbulbs;
  final String roti;
  final String dampen;
  ProductCynicalModel? cynical;
  ProductCogitoModle cogito;
  ProductModel({
    required this.risorgimentos,
    required this.goniometry,
    required this.uniquely,
    required this.sirens,
    required this.tostadas,
    required this.flashbulbs,
    required this.roti,
    required this.dampen,
    this.cynical,
    required this.cogito,
  });
  factory ProductModel.fromJson(Json json) {
    final debtless = json['debtless'];
    return ProductModel(
      risorgimentos: json['risorgimentos'].intValue,
      goniometry: debtless['goniometry'].stringValue,
      uniquely: debtless['uniquely'].stringValue,
      sirens: debtless['sirens'].stringValue,
      tostadas: debtless['tostadas'].stringValue,
      flashbulbs: debtless['flashbulbs'].stringValue,
      roti: debtless['roti'].stringValue,
      dampen: debtless['dampen'].stringValue,
      cynical: ProductCynicalModel.fromJson(json['cynical']),
      cogito: ProductCogitoModle.fromJson(json['cogito']),
    );
  }
}

class ProductCynicalModel {
  final String downslide;
  final String dampen;
  final String dipteral;
  final String earnings;
  ProductCynicalModel({
    required this.downslide,
    required this.dampen,
    required this.dipteral,
    required this.earnings,
  });
  factory ProductCynicalModel.fromJson(Json json) {
    return ProductCynicalModel(
      downslide: json['downslide'].stringValue,
      dampen: json['dampen'].stringValue,
      dipteral: json['dipteral'].stringValue,
      earnings: json['earnings'].stringValue,
    );
  }
}

class ProductCogitoModle {
  final String base;
  final String baseSuccess;
  final String livness;
  final String person;
  final String job;
  final String ext;
  final String bindCard;
  final String bindCardBottom;
  ProductCogitoModle({
    required this.base,
    required this.baseSuccess,
    required this.livness,
    required this.person,
    required this.job,
    required this.ext,
    required this.bindCard,
    required this.bindCardBottom,
  });
  factory ProductCogitoModle.fromJson(Json json) {
    if (!json.exists() || json.mapValue.isEmpty) {
      return ProductCogitoModle(
        base:
            'Complete the first step of verification by uploading your valid ID to speed up approval!',
        baseSuccess: 'ID Verified! Complete next step to boost limit.',
        livness:
            'Maintain a natural expression, face the camera to complete the scan, and let the system quickly recognize your identity.',
        person: 'Tell us more about yourself to speed up your approval.',
        job:
            'Complete your personal profile to help the system perform better credit evaluation.',
        ext:
            'Emergency contact information is used only for verification in special cases, kept strictly confidential.',
        bindCard: 'Tell us more about yourself to speed up your approval.',
        bindCardBottom:
            'Double-check your account details to avoid errors and ensure a smooth transaction.',
      );
    }
    return ProductCogitoModle(
      base: json['floundering'].stringValue,
      baseSuccess: json['revocations'].stringValue,
      livness: json['mulcts'].stringValue,
      person: json['questors'].stringValue,
      job: json['gibbons'].stringValue,
      ext: json['drawback'].stringValue,
      bindCard: json['nomographic'].stringValue,
      bindCardBottom: json['presentableness'].stringValue,
    );
  }
}
