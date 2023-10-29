import 'dart:convert';

import '../infra/prefs.dart';

class FalconModel {
  final String? latlong;
  final String? datahora;
  final String? placa;
  final String? nick_usuario;

  const FalconModel({
    this.latlong,
    this.placa,
    this.datahora,
    this.nick_usuario,
  });

  factory FalconModel.fromJson(Map json) {
    return FalconModel(
      latlong: json["latlong"],
      placa: json["placa"],
      datahora: json["datahora"],
      nick_usuario: json["nick_usuario"],
    );
  }

  static void save(map) {
    List<String> placas = [];
    placas.add(jsonEncode(map));

    Prefs.setListString("listaPlacas.prefs", placas);
  }

  static Future<List<dynamic>> get() async {
    List json = await Prefs.getListString("listaPlacas.prefs");
    var json_list;
    if (json.isNotEmpty) {
      json_list = [jsonDecode(json.first)];
    } else {
      json_list = [];
    }
    List<dynamic> listaPlacas = json_list.map<FalconModel>((map) => FalconModel.fromJson(map)).toList();
    return listaPlacas;
  }

  static Future<void> clear() async {
    Prefs.setClearString();
  }
}
