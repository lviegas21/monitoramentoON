// ignore_for_file: avoid_print

import 'dart:async';

import 'package:mysql1/mysql1.dart';

class Falcon {
  Future<dynamic> conection(Map<String, dynamic> chave) async {
    var settings = await MySqlConnection.connect(
      ConnectionSettings(
        host: '172.20.1.142',
        port: 3306,
        user: 'user_db_vehicle',
        password: 'us3r1nt3l1g3nc1@v3h1cl3@#',
        db: 'db_vehicle',
      ),
    );
    var result = await settings.query(
      'insert into db_vehicle.tb_veiculos_detectados (placa, latlong, datahora, nick_usuario) values (?, ?, ?, ?)',
      [chave["placa"], chave["latlong"], chave["datahora"], chave["nick_usuario"]],
    );
    print('Inserted row id=${result.insertId}');
  }
}
