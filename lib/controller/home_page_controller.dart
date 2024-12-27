import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:path_provider/path_provider.dart';

import '../ui/home/components/orvelay_components.dart';
import '../provider/falcon.dart';
import '../models/falcon_model.dart';

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxList<RecognizedText> textBoxs = <RecognizedText>[].obs;
  final RxBool isWifi = false.obs;
  final RxBool isButton = false.obs;
  final RxBool isProcessingImage = false.obs;
  final RxBool isCameraInitialized = false.obs;
  final Rx<TextEditingController> lat = TextEditingController().obs;
  final Rx<TextEditingController> long = TextEditingController().obs;

  bool isBusy = false;
  late Timer _timer;
  double _currentZoom = 1.0;
  late CameraController controller;
  final textRecognizer = TextRecognizer();
  final Falcon falcon = Falcon();
  List<XFile>? imageFileList = [];
  Position? currentPosition;
  tfl.Interpreter? _interpreter;

  // Controle de monitoramento
  RxBool isMonitoring = false.obs;
  // Set para armazenar placas já detectadas
  final Set<String> detectedPlates = {};

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    loadModel();
    _determinePosition();
  }

  @override
  void onClose() {
    _timer.cancel();
    controller.dispose();
    textRecognizer.close();
    _interpreter?.close();
    super.onClose();
  }

  Future<void> loadModel() async {
    try {
      final modelFile = await _getModel();
      _interpreter = await tfl.Interpreter.fromFile(modelFile);
      print('Modelo carregado com sucesso');
    } catch (e) {
      print('Erro ao carregar modelo: $e');
    }
  }

  Future<File> _getModel() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDir.path}/model_unquant.tflite';
    final modelFile = File(modelPath);

    if (!await modelFile.exists()) {
      final byteData = await rootBundle.load('assets/model_unquant.tflite');
      await modelFile.writeAsBytes(byteData.buffer.asUint8List());
    }
    return modelFile;
  }

  Future<void> chamadaInicio() async {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (!isBusy && isMonitoring.value) {
        takePicture();
      }
    });
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off); // Desativa o flash permanentemente
      isCameraInitialized.value = true;
    } catch (e) {
      print('Erro ao inicializar câmera: $e');
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização estão desabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissões de localização foram negadas');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permissões de localização foram permanentemente negadas');
    }

    currentPosition = await Geolocator.getCurrentPosition();
    lat.value.text = currentPosition?.latitude.toString() ?? '';
    long.value.text = currentPosition?.longitude.toString() ?? '';
  }

  Future<void> takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }

    if (isBusy) {
      return;
    }

    try {
      isBusy = true;
      final image = await controller.takePicture();
      await processImage(image);
    } catch (e) {
      print('Erro ao tirar foto: $e');
    } finally {
      isBusy = false;
    }
  }

  Future<void> notificarUsuario(bool sucesso, {String? mensagem}) async {
    if (sucesso) {
      Fluttertoast.showToast(
          msg: mensagem ?? "Nova placa detectada!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: mensagem ?? "Erro ao processar placa",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<List<dynamic>> runModelInference(String imagePath) async {
    if (_interpreter == null) {
      print('Interpreter não inicializado');
      return [];
    }

    try {
      final imageData = File(imagePath).readAsBytesSync();
      final image = img.decodeImage(imageData);
      if (image == null) return [];

      final resizedImage = img.copyResize(image, width: 224, height: 224);
      var input = Float32List(1 * 224 * 224 * 3);
      var pixel = 0;

      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final p = resizedImage.getPixel(x, y);

          // Normaliza os valores RGB para o intervalo [-1, 1]
          input[pixel] = (p.r.toDouble() - 127.5) / 127.5;
          input[pixel + 1] = (p.g.toDouble() - 127.5) / 127.5;
          input[pixel + 2] = (p.b.toDouble() - 127.5) / 127.5;
          pixel += 3;
        }
      }

      var output = List.filled(1 * 2, 0).reshape([1, 2]);
      _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

      // Aumentando o threshold para reduzir falsos positivos
      final confidence = output[0][1];
      if (confidence > 0.85) {
        // Threshold mais alto
        print('Detecção: Placa com confiança: ${confidence * 100}%');
        return [
          {'confidence': confidence, 'index': 1, 'label': 'Placa'}
        ];
      }

      return [];
    } catch (e) {
      print('Erro ao executar inferência: $e');
      return [];
    }
  }

  Future<RecognizedText?> detectText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText;
    } catch (e) {
      print('Erro ao detectar texto: $e');
      return null;
    }
  }

  Future<bool> isLicensePlate(String imagePath) async {
    try {
      final results = await runModelInference(imagePath);
      if (results.isEmpty) return false;

      final confidence = results[0]['confidence'] as double;
      // Adicionando verificações adicionais
      if (confidence > 0.85) {
        // Verifica se há texto na imagem que se parece com uma placa
        final recognizedText = await detectText(imagePath);
        if (recognizedText != null) {
          // Verifica se o texto segue o padrão de placa brasileira
          final platePattern = RegExp(r'^[A-Z]{3}[0-9][0-9A-Z][0-9]{2}$');
          final hasPlateFormat = recognizedText.blocks.any((block) =>
              block.text.replaceAll(RegExp(r'[^A-Z0-9]'), '').length >= 7 &&
              platePattern
                  .hasMatch(block.text.replaceAll(RegExp(r'[^A-Z0-9]'), '')));

          if (hasPlateFormat) {
            print('Placa detectada com formato válido');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Erro ao verificar placa: $e');
      return false;
    }
  }

  void toggleMonitoring() {
    isMonitoring.value = !isMonitoring.value;
    if (isMonitoring.value) {
      Fluttertoast.showToast(
          msg: "Monitoramento iniciado",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      detectedPlates.clear(); // Limpa placas detectadas ao parar
      Fluttertoast.showToast(
          msg: "Monitoramento parado",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> processImage(XFile image) async {
    // Se não estiver monitorando, ignora a imagem
    if (!isMonitoring.value) return;

    try {
      if (await isLicensePlate(image.path)) {
        final plateText = await getPlateText(image.path);

        // Verifica se a placa já foi detectada
        if (detectedPlates.contains(plateText)) {
          await notificarUsuario(false,
              mensagem: "Placa $plateText já foi registrada");
          return;
        }

        final timestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        File imageFile = File(image.path);
        Uint8List imageBytes = await imageFile.readAsBytes();
        String base64Image = base64.encode(imageBytes);

        Map<String, dynamic> dados = {
          "placa": plateText,
          "imagem": base64Image,
          "lat": currentPosition?.latitude ?? 0.0,
          "long": currentPosition?.longitude ?? 0.0,
          "timestamp": timestamp,
          "confianca":
              (await runModelInference(image.path))[0]['confidence'] ?? 0.0,
        };

        await falcon.conection(dados);
        // Adiciona a placa ao set de placas detectadas
        detectedPlates.add(plateText);
        await notificarUsuario(true);
      }
    } catch (e) {
      print('Erro ao processar imagem: $e');
      await notificarUsuario(false);
    }
  }

  Future<String> getPlateText(String imagePath) async {
    try {
      final recognizedText = await detectText(imagePath);
      if (recognizedText != null) {
        final platePattern = RegExp(r'^[A-Z]{3}[0-9][0-9A-Z][0-9]{2}$');
        final plateText = recognizedText.blocks
            .firstWhere((block) => platePattern
                .hasMatch(block.text.replaceAll(RegExp(r'[^A-Z0-9]'), '')))
            .text;
        return plateText;
      }
      return '';
    } catch (e) {
      print('Erro ao obter texto da placa: $e');
      return '';
    }
  }
}
