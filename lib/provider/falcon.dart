import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class Falcon {
  static final Falcon _instance = Falcon._internal();
  Database? _database;
  
  factory Falcon() {
    return _instance;
  }
  
  Falcon._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathToDb = path.join(dbPath, 'falcon.db');

    return await openDatabase(
      pathToDb,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE tb_posicao(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            placa_veiculo TEXT,
            tipo_placa TEXT,
            imagem TEXT,
            lat REAL,
            long REAL,
            data_hora_evento TEXT,
            confianca REAL
          )
        ''');
      },
    );
  }

  bool _isValidMercosulPlate(String plate) {
    // Formato Mercosul: LLLNLNN (L=Letra, N=Número)
    RegExp mercosulRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');
    return mercosulRegex.hasMatch(plate);
  }

  bool _isValidBrazilianPlate(String plate) {
    // Formato antigo brasileiro: LLL-NNNN
    RegExp brRegex = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    return brRegex.hasMatch(plate.replaceAll('-', ''));
  }

  String _normalizePlate(String plate) {
    // Remove hífens e espaços, converte para maiúsculas
    return plate.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
  }

  Future<void> conection(Map<String, dynamic> chave) async {
    final String normalizedPlate = _normalizePlate(chave['placa'] ?? '');
    String tipoPlaca = 'DESCONHECIDO';
    
    if (_isValidMercosulPlate(normalizedPlate)) {
      tipoPlaca = 'MERCOSUL';
    } else if (_isValidBrazilianPlate(normalizedPlate)) {
      tipoPlaca = 'NACIONAL';
    }

    final db = await database;
    try {
      var result = await db.insert(
        'tb_posicao',
        {
          'placa_veiculo': normalizedPlate,
          'tipo_placa': tipoPlaca,
          'imagem': chave['imagem'],
          'lat': chave['lat'],
          'long': chave['long'],
          'data_hora_evento': chave['timestamp'],
          'confianca': chave['confianca'] ?? 0.0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Cache apenas placas válidas com alta confiança
      if (tipoPlaca != 'DESCONHECIDO' && (chave['confianca'] ?? 0.0) > 0.7) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ultima_placa', normalizedPlate);
        await prefs.setString('tipo_placa', tipoPlaca);
        await prefs.setString('imagem', chave['imagem']);
        await prefs.setDouble('lat', chave['lat']);
        await prefs.setDouble('long', chave['long']);
        await prefs.setString('timestamp', chave['timestamp']);
        await prefs.setDouble('confianca', chave['confianca'] ?? 0.0);
      }

      print('Placa processada: $normalizedPlate ($tipoPlaca) - ID=$result');
    } catch (e) {
      print('Erro ao salvar placa: $e');
      throw Exception('Falha ao salvar dados no banco: $e');
    }
  }
}