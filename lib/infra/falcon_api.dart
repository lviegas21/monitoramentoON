import 'dart:convert';

import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class FalconApi {
  Future<dynamic> enviarVeiculo(dynamic chave) async {
    try {
      HttpClient client = new HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

      var authority = "disquedenunciav01.ssp.ma.gov.br";
      var path = "/_vehicle/api/insert_evento.php";

      Map params = {
        "placa": chave["placa"],
        "datahora": chave["datahora"],
        "nick_usuario": chave["nick_usuario"],
        "latlong": chave["latlong"],
      };
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      final _uri = Uri.https(authority, path);
      var body = convert.json.encode(params);
      var response = await http.post(_uri, headers: headers, body: body).timeout(const Duration(seconds: 5));
      if (response.statusCode == 201) {
        print(response.statusCode);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
