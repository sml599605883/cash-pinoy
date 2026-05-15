import '../tools/json.dart';

class FormFieldsResponseModel {
  final List<FormFieldModel> fields;

  FormFieldsResponseModel({required this.fields});

  factory FormFieldsResponseModel.fromJson(Json json) {
    final threaders = json['threaders'].listValue;
    return FormFieldsResponseModel(
      fields: threaders.map((e) => FormFieldModel.fromJson(e)).toList(),
    );
  }
}

class FormFieldModel {
  final int uniquely;
  final String earnings;
  final String saccharide;
  final String juridic;
  final String coaxal;
  final int reckoners;
  final int sacraria;
  final int acidnesses;
  final String deforcement;
  final bool adown;
  final String paralyze;
  final int secondly;
  final List<FormOptionModel> cogito;

  FormOptionModel? selectedOption;

  FormFieldModel({
    required this.uniquely,
    required this.earnings,
    required this.saccharide,
    required this.juridic,
    required this.coaxal,
    required this.reckoners,
    required this.sacraria,
    required this.acidnesses,
    required this.deforcement,
    required this.adown,
    required this.paralyze,
    required this.secondly,
    required this.cogito,
  });

  factory FormFieldModel.fromJson(Json json) {
    final options = json['cogito'].listValue
        .map((e) => FormOptionModel.fromJson(e))
        .toList();
    return FormFieldModel(
      uniquely: json['uniquely'].intValue,
      earnings: json['earnings'].stringValue,
      saccharide: json['saccharide'].stringValue,
      juridic: json['juridic'].stringValue,
      coaxal: json['coaxal'].stringValue,
      reckoners: json['reckoners'].intValue,
      sacraria: json['sacraria'].intValue,
      acidnesses: json['acidnesses'].intValue,
      deforcement: json['deforcement'].stringValue,
      adown: json['adown'].boolValue,
      paralyze: json['paralyze'].stringValue,
      secondly: json['secondly'].intValue,
      cogito: options,
    );
  }

  bool get isInput => coaxal == 'EcholalicDotted';
  bool get isAddress => coaxal == 'Sphynx';
  bool get isAnnouncer => coaxal == 'Announcer';
  bool get isSelect => !isInput;

  void selectOption(FormOptionModel option) {
    selectedOption = option;
  }
}

class FormOptionModel {
  final String unpaid;
  final String dipteral;
  final List<FormOptionModel>? cogito;

  const FormOptionModel({
    required this.unpaid,
    required this.dipteral,
    this.cogito,
  });

  factory FormOptionModel.fromJson(Json json) {
    return FormOptionModel(
      unpaid: json['unpaid'].stringValue,
      dipteral: json['dipteral'].stringValue,
      cogito: json['cogito'].listValue
          .map((e) => FormOptionModel.fromJson(e))
          .toList(),
    );
  }
}
