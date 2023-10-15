import 'dart:async';

import 'package:mysql1/mysql1.dart';

class Falcon {
  Future<dynamic> conection(Map<String, dynamic> chave) async {
    var settings = await MySqlConnection.connect(ConnectionSettings(
        host: '10.0.2.2',
        port: 3306,
        user: 'root',
        password: 'password',
        db: 'falcon_db'));

    var result = await settings.query(
      'insert into falcon_db.tb_posicao (placa_veiculo, imagem, lat, long, data_hora_evento) values (?, ?, ?, ?)',
      ['1', chave["imagem"], chave["lat"], chave["long"], chave["timestamp"]],
    );
    print('Inserted row id=${result.insertId}');
  }
}
