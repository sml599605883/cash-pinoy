import '../tools/json.dart';

class LoanCardSectionModel {
  final int harrowers;
  final String prosodists;
  final String traplike;
  final List<LoanCardItemModel> odeons;

  LoanCardSectionModel({
    required this.harrowers,
    required this.prosodists,
    required this.traplike,
    required this.odeons,
  });

  factory LoanCardSectionModel.fromJson(Json json) {
    return LoanCardSectionModel(
      harrowers: json['harrowers'].intValue,
      prosodists: json['prosodists'].stringValue,
      traplike: json['traplike'].stringValue,
      odeons: json['odeons'].listValue.map(LoanCardItemModel.fromJson).toList(),
    );
  }
}

class LoanCardItemModel {
  final String tillers;
  final String matchboard;
  final int acidnesses;
  final String tightwires;
  final String exaptive;
  int interfluves;
  final String dipteral;
  final String voter;
  final String summersaults;
  final String civilising;
  final String postvagotomy;

  LoanCardItemModel({
    required this.tillers,
    required this.matchboard,
    required this.acidnesses,
    required this.tightwires,
    required this.exaptive,
    required this.interfluves,
    required this.dipteral,
    required this.voter,
    required this.summersaults,
    required this.civilising,
    required this.postvagotomy,
  });

  factory LoanCardItemModel.fromJson(Json json) {
    final banteng = json['banteng'];
    return LoanCardItemModel(
      tillers: json['tillers'].stringValue,
      matchboard: json['matchboard'].stringValue,
      acidnesses: json['acidnesses'].intValue,
      tightwires: json['tightwires'].stringValue,
      exaptive: json['exaptive'].stringValue,
      interfluves: json['interfluves'].intValue,
      dipteral: json['dipteral'].stringValue,
      voter: banteng['voter'].stringValue,
      summersaults: banteng['summersaults'].stringValue,
      civilising: banteng['civilising'].stringValue,
      postvagotomy: json['postvagotomy'].stringValue,
    );
  }

  bool get isSelected => interfluves == 1;

  void setSelected(bool value) {
    interfluves = value ? 1 : 0;
  }

  bool get isSafeguard => acidnesses != 1;
}
