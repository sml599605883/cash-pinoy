import '../tools/json.dart';

class BindInitModel {
  final List<BindTabModel> tabs;
  final String chirked;
  final String presentableness;

  BindInitModel({
    required this.tabs,
    required this.chirked,
    required this.presentableness,
  });

  factory BindInitModel.fromJson(Json json) {
    return BindInitModel(
      tabs: json['threaders'].listValue
          .map((e) => BindTabModel.fromJson(e))
          .toList(),
      chirked: json['chirked'].stringValue,
      presentableness: json['presentableness'].stringValue,
    );
  }
}

class BindTabModel {
  final String earnings;
  final String dipteral;
  final List<BindFieldModel> fields;

  BindTabModel({
    required this.earnings,
    required this.dipteral,
    required this.fields,
  });

  factory BindTabModel.fromJson(Json json) {
    return BindTabModel(
      earnings: json['earnings'].stringValue,
      dipteral: json['dipteral'].stringValue,
      fields: json['threaders'].listValue
          .map((e) => BindFieldModel.fromJson(e))
          .toList(),
    );
  }
}

class BindFieldModel {
  final String earnings;
  final String juridic;
  final String saccharide;
  final String coaxal;
  final List<BindOptionModel> cogito;
  final int sacraria;
  final int acidnesses;
  final String deforcement;
  String paralyze;
  final String ruddy;
  final int secondly;
  final int reckoners;

  BindOptionModel? selectedOption;

  BindFieldModel({
    required this.earnings,
    required this.juridic,
    required this.saccharide,
    required this.coaxal,
    required this.cogito,
    required this.sacraria,
    required this.acidnesses,
    required this.deforcement,
    required this.paralyze,
    required this.ruddy,
    required this.secondly,
    required this.reckoners,
  });

  factory BindFieldModel.fromJson(Json json) {
    return BindFieldModel(
      earnings: json['earnings'].stringValue,
      juridic: json['juridic'].stringValue,
      saccharide: json['saccharide'].stringValue,
      coaxal: json['coaxal'].stringValue,
      cogito: json['cogito'].listValue
          .map((e) => BindOptionModel.fromJson(e))
          .toList(),
      sacraria: json['sacraria'].intValue,
      acidnesses: json['acidnesses'].intValue,
      deforcement: json['deforcement'].stringValue,
      paralyze: json['paralyze'].stringValue,
      ruddy: json['ruddy'].stringValue,
      secondly: json['secondly'].intValue,
      reckoners: json['reckoners'].intValue,
    );
  }

  bool get isInput => coaxal == 'EcholalicDotted';
  bool get isSelect => coaxal == 'Announcer';
}

class BindOptionModel {
  final String dipteral;
  final String unpaid;
  final String matchboard;
  final bool acidnesses;
  final String postvagotomy;

  BindOptionModel({
    required this.dipteral,
    required this.unpaid,
    required this.matchboard,
    required this.acidnesses,
    required this.postvagotomy,
  });

  factory BindOptionModel.fromJson(Json json) {
    return BindOptionModel(
      dipteral: json['dipteral'].stringValue,
      unpaid: json['unpaid'].stringValue,
      matchboard: json['matchboard'].stringValue,
      acidnesses: json['acidnesses'].intValue == 1,
      postvagotomy: json['postvagotomy'].stringValue,
    );
  }
}
