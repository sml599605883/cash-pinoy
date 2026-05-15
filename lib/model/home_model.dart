import 'package:cash_pinoy/tools/json.dart';
import 'package:flutter/material.dart';

class HomeModel {
  HomeGrayoutModel grayout;
  List<HomeBannerModel> banners;
  HomeLargeCardModel? largeCard;
  List<HomeProductModel> productList;
  List<HomeProcessModel> processList;

  HomeModel({
    required this.grayout,
    required this.banners,
    this.largeCard,
    this.productList = const [],
    this.processList = const [],
  });

  factory HomeModel.fromJson(Json json) {
    List<Json> list = json['bleaching'].listValue;

    List<HomeBannerModel> bannerList = [];
    HomeLargeCardModel? largeCard;
    List<HomeProductModel> productList = [];
    List<HomeProcessModel> processList = [];

    for (final item in list) {
      final dipteral = item['dipteral'].stringValue;
      final odeons = item['odeons'];
      if (dipteral == 'DefocussedCompletely') {
        bannerList = odeons.listValue
            .map((e) => HomeBannerModel.fromJson(e))
            .toList();
      } else if (dipteral == 'UncrossedCrusading' ||
          dipteral == 'AgitationalCuria') {
        largeCard = HomeLargeCardModel.fromJson(odeons.listValue.first);
      } else if (dipteral == 'FederalizedLire') {
        productList = odeons.listValue
            .map((e) => HomeProductModel.fromJson(e))
            .toList();
      } else if (dipteral == 'RassledProtases') {
        processList = odeons.listValue
            .map((e) => HomeProcessModel.fromJson(e))
            .toList();
      }
    }
    return HomeModel(
      grayout: HomeGrayoutModel.fromJson(json['grayout']),
      banners: bannerList,
      largeCard: largeCard,
      productList: productList,
      processList: processList,
    );
  }
}

class HomeGrayoutModel {
  final String muggers;
  final String surliest;

  HomeGrayoutModel({required this.muggers, required this.surliest});

  factory HomeGrayoutModel.fromJson(Json json) {
    return HomeGrayoutModel(
      muggers: json['muggers'].stringValue,
      surliest: json['surliest'].stringValue,
    );
  }
}

class HomeBannerModel {
  final String bannerId;
  final String bannerUrl;
  final String linkUrl;

  HomeBannerModel({
    required this.bannerId,
    required this.bannerUrl,
    required this.linkUrl,
  });
  factory HomeBannerModel.fromJson(Json json) {
    return HomeBannerModel(
      bannerId: json['uniquely'].stringValue,
      bannerUrl: json['explainer'].stringValue,
      linkUrl: json['dampen'].stringValue,
    );
  }
}

class HomeLargeCardModel {
  final String uniquely;
  final String preadapt;
  final String caesiums;
  final String pargetting;
  final String sternite;
  final String charpoy;
  final String wistfulness;
  final String eavesdrops;
  final String taffarel;
  final String precipitantness;
  final String overinsistent;
  final String helistops;
  final String amendable;
  final String stabs;
  final List<HomeEgestionsModel> egestions;
  final List<HomeTranscendencyModel> transcendency;

  HomeLargeCardModel({
    required this.uniquely,
    required this.preadapt,
    required this.caesiums,
    required this.pargetting,
    required this.sternite,
    required this.charpoy,
    required this.wistfulness,
    required this.eavesdrops,
    required this.taffarel,
    required this.precipitantness,
    required this.overinsistent,
    required this.helistops,
    required this.amendable,
    required this.stabs,
    required this.egestions,
    required this.transcendency,
  });

  factory HomeLargeCardModel.fromJson(Json json) {
    return HomeLargeCardModel(
      uniquely: json['uniquely'].stringValue,
      preadapt: json['preadapt'].stringValue,
      caesiums: json['caesiums'].stringValue,
      pargetting: json['pargetting'].stringValue,
      sternite: json['sternite'].stringValue,
      charpoy: json['charpoy'].stringValue,
      wistfulness: json['wistfulness'].stringValue,
      eavesdrops: json['eavesdrops'].stringValue,
      taffarel: json['taffarel'].stringValue,
      precipitantness: json['precipitantness'].stringValue,
      overinsistent: json['overinsistent'].stringValue,
      helistops: json['helistops'].stringValue,
      amendable: json['amendable'].stringValue,
      stabs: json['stabs'].stringValue,
      egestions: json['egestions'].listValue
          .map((e) => HomeEgestionsModel.fromJson(e))
          .toList(),
      transcendency: json['transcendency'].listValue
          .map((e) => HomeTranscendencyModel.fromJson(e))
          .toList(),
    );
  }
}

class HomeEgestionsModel {
  final String earnings;
  final String choky;
  final String imides;

  HomeEgestionsModel({
    required this.earnings,
    required this.choky,
    required this.imides,
  });

  factory HomeEgestionsModel.fromJson(Json json) {
    return HomeEgestionsModel(
      earnings: json['earnings'].stringValue,
      choky: json['choky'].stringValue,
      imides: json['imides'].stringValue,
    );
  }
}

class HomeTranscendencyModel {
  final String pirates;
  final String dupes;
  final String taffarel;
  final String mahatma;
  final String goniometry;
  final String lifelong;
  final String actualPeriods;
  final String termsOfPayment;
  final String flashbulbs;
  final String hayseeds;

  HomeTranscendencyModel({
    required this.pirates,
    required this.dupes,
    required this.taffarel,
    required this.mahatma,
    required this.goniometry,
    required this.lifelong,
    required this.actualPeriods,
    required this.termsOfPayment,
    required this.flashbulbs,
    required this.hayseeds,
  });

  factory HomeTranscendencyModel.fromJson(Json json) {
    return HomeTranscendencyModel(
      pirates: json['pirates'].stringValue,
      dupes: json['dupes'].stringValue,
      taffarel: json['taffarel'].stringValue,
      mahatma: json['mahatma'].stringValue,
      goniometry: json['goniometry'].stringValue,
      lifelong: json['lifelong'].stringValue,
      actualPeriods: json['actual_periods'].stringValue,
      termsOfPayment: json['termsOfPayment'].stringValue,
      flashbulbs: json['flashbulbs'].stringValue,
      hayseeds: json['hayseeds'].stringValue,
    );
  }
}

class HomeProductModel {
  final String uniquely;
  final String preadapt;
  final String sternite;
  final List<String> housebreakings;
  final String remissness;
  final String caesiums;
  final String disinterests;
  final String pargetting;
  final String lacquered;
  final String charpoy;
  final String precipitantness;
  final String contrails;
  final String oxidising;
  final String zizzles;
  final String flashbulbs;
  final String roselle;
  final String zonked;
  final String speakable;
  final String dampen;
  final String wistfulness;
  final String switchblade;
  final List<Json> bicameral;
  final String belfried;
  final List<Json> stegosaurus;
  final String overdosage;
  final String oysterman;
  final String taffarel;
  final String pandowdy;

  HomeProductModel({
    required this.uniquely,
    required this.preadapt,
    required this.sternite,
    required this.housebreakings,
    required this.remissness,
    required this.caesiums,
    required this.disinterests,
    required this.pargetting,
    required this.lacquered,
    required this.charpoy,
    required this.precipitantness,
    required this.contrails,
    required this.oxidising,
    required this.zizzles,
    required this.flashbulbs,
    required this.roselle,
    required this.zonked,
    required this.speakable,
    required this.dampen,
    required this.wistfulness,
    required this.switchblade,
    required this.bicameral,
    required this.belfried,
    required this.stegosaurus,
    required this.overdosage,
    required this.oysterman,
    required this.taffarel,
    required this.pandowdy,
  });

  factory HomeProductModel.fromJson(Json json) {
    return HomeProductModel(
      uniquely: json['uniquely'].stringValue,
      preadapt: json['preadapt'].stringValue,
      sternite: json['sternite'].stringValue,
      housebreakings: json['housebreakings'].listValue
          .map((e) => e.stringValue)
          .toList(),
      remissness: json['remissness'].stringValue,
      caesiums: json['caesiums'].stringValue,
      disinterests: json['disinterests'].stringValue,
      pargetting: json['pargetting'].stringValue,
      lacquered: json['lacquered'].stringValue,
      charpoy: json['charpoy'].stringValue,
      precipitantness: json['precipitantness'].stringValue,
      contrails: json['contrails'].stringValue,
      oxidising: json['oxidising'].stringValue,
      zizzles: json['zizzles'].stringValue,
      flashbulbs: json['flashbulbs'].stringValue,
      roselle: json['roselle'].stringValue,
      zonked: json['zonked'].stringValue,
      speakable: json['speakable'].stringValue,
      dampen: json['dampen'].stringValue,
      wistfulness: json['wistfulness'].stringValue,
      switchblade: json['switchblade'].stringValue,
      bicameral: json['bicameral'].listValue,
      belfried: json['belfried'].stringValue,
      stegosaurus: json['stegosaurus'].listValue,
      overdosage: json['overdosage'].stringValue,
      oysterman: json['oysterman'].stringValue,
      taffarel: json['taffarel'].stringValue,
      pandowdy: json['pandowdy'].stringValue,
    );
  }
}

class HomeProcessModel {
  final String defilading;
  final String strikes;
  final String prostitute;
  final String enalapril;
  final String earnings;
  final String goniometry;
  final String denies;
  final String birl;
  final String loci;
  final String exaptive;
  final String tory;
  final String mismanaging;
  final String auditories;
  final String feminity;
  final String overdried;
  final String amendable;
  final List<HomeProcessEgestionsModel> egestions;
  final String philomela;
  final String masculinizes;
  final String dampen;
  final List<HomeProcessArtisticModel> artistic;

  List<Color> get bgColors => auditories == '2' || auditories == '3'
      ? [Color(0xFFFFE1C7), Color(0x00FFE0A5), Color(0x00FFE0A5)]
      : [Color(0xFFE1C7FF), Color(0x00C4A5FF), Color(0x00C4A5FF)];

  Color get statusColor => auditories == '2' || auditories == '3'
      ? Color(0xFFFE6436)
      : Color(0xFF2F2F2F);

  HomeProcessModel({
    required this.defilading,
    required this.strikes,
    required this.prostitute,
    required this.enalapril,
    required this.earnings,
    required this.goniometry,
    required this.denies,
    required this.birl,
    required this.loci,
    required this.exaptive,
    required this.tory,
    required this.mismanaging,
    required this.auditories,
    required this.feminity,
    required this.overdried,
    required this.amendable,
    required this.egestions,
    required this.philomela,
    required this.masculinizes,
    required this.dampen,
    required this.artistic,
  });

  factory HomeProcessModel.fromJson(Json json) {
    return HomeProcessModel(
      defilading: json['defilading'].stringValue,
      strikes: json['strikes'].stringValue,
      prostitute: json['prostitute'].stringValue,
      enalapril: json['enalapril'].stringValue,
      earnings: json['earnings'].stringValue,
      goniometry: json['goniometry'].stringValue,
      denies: json['denies'].stringValue,
      birl: json['birl'].stringValue,
      loci: json['loci'].stringValue,
      exaptive: json['exaptive'].stringValue,
      tory: json['tory'].stringValue,
      mismanaging: json['mismanaging'].stringValue,
      auditories: json['auditories'].stringValue,
      feminity: json['feminity'].stringValue,
      overdried: json['overdried'].stringValue,
      amendable: json['amendable'].stringValue,
      egestions: json['egestions'].listValue
          .map((e) => HomeProcessEgestionsModel.fromJson(e))
          .toList(),
      philomela: json['philomela'].stringValue,
      masculinizes: json['masculinizes'].stringValue,
      dampen: json['dampen'].stringValue,
      artistic: json['artistic'].listValue
          .map((e) => HomeProcessArtisticModel.fromJson(e))
          .toList(),
    );
  }
}

class HomeProcessEgestionsModel {
  final String earnings;
  final String goniometry;
  final String choky;
  final bool imides;

  HomeProcessEgestionsModel({
    required this.earnings,
    required this.goniometry,
    required this.choky,
    required this.imides,
  });

  factory HomeProcessEgestionsModel.fromJson(Json json) {
    return HomeProcessEgestionsModel(
      earnings: json['earnings'].stringValue,
      goniometry: json['goniometry'].stringValue,
      choky: json['choky'].stringValue,
      imides: json['imides'].intValue == 1,
    );
  }
}

class HomeProcessArtisticModel {
  final String dipteral;
  final bool babiest;
  final String jaeger;

  Color get color => dipteral == 'repay'
      ? Color(0xFFFE6436)
      : dipteral == 'change'
      ? Color(0xFF7927EB)
      : Color(0xFFBFBAC2);

  String get title => dipteral == 'repay'
      ? 'Repay'
      : dipteral == 'change'
      ? 'Change'
      : 'Try Again';
  HomeProcessArtisticModel({
    required this.dipteral,
    required this.babiest,
    required this.jaeger,
  });

  factory HomeProcessArtisticModel.fromJson(Json json) {
    return HomeProcessArtisticModel(
      dipteral: json['dipteral'].stringValue,
      babiest: json['babiest'].intValue == 1,
      jaeger: json['jaeger'].stringValue,
    );
  }
}
