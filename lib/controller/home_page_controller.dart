import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
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
import 'package:projeto_cicero/ui/home/components/orvelay_components.dart';
import '../infra/falcon_api.dart';
import '../models/falcon_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  @override
  void onInit() async {
    await initializeCamera();
    await loadmodel();
    await _determinePosition();

    super.onInit();
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  RxList<Recognition> recognition = <Recognition>[].obs;

  Interpreter? interpreter;

  RxBool isWifi = false.obs;

  bool isBusy = false;
  late Timer _timer;
  double _currentZoom = 1.0;

  RxBool isButton = false.obs;

  late CameraController controller;

  RxBool isCameraInitialized = false.obs;
  TextDetector textDetector = GoogleMlKit.vision.textDetector();

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    String filePath =
        'assets/sons/insercao.mp3'; // Substitua pelo caminho real do seu arquivo

    isCameraInitialized.value = true;
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      if (!isBusy) {
        takePicture();
      }
    });
  }

  Future<void> takePicture() async {
    if (!controller.value.isInitialized || isBusy) {
      return;
    }
    isBusy = true;

    // double maxZoom = await controller.getMaxZoomLevel();
    // double minZoom = await controller.getMinZoomLevel();

    // double targetZoom = minZoom + (maxZoom - minZoom) / 2;
    // await controller.setZoomLevel(targetZoom);

    // Captura a imagem

    try {
      // Suponha que você já tenha uma imagem capturada na variável 'image'.
      final XFile image = await controller.takePicture();

      // Execute a detecção YOLO na imagem para encontrar a placa de licença.
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (recognitions!.isNotEmpty) {
        // Suponha que a primeira detecção é a placa de licença.
        var recognition = recognitions.first;
        print(recognition);
        FalconApi falconApi = FalconApi();
        // Aqui você extrairia as coordenadas da detecção para recortar a imagem.
        // O código a seguir é apenas um exemplo e precisa ser ajustado.

        // Execute o OCR na imagem recortada.
        final inputImage = InputImage.fromFilePath(image.path);
        final RecognisedText recognisedText =
            await textDetector.processImage(inputImage);

        String ocrText = "";
        for (TextBlock block in recognisedText.blocks) {
          ocrText = block.text;
          if (isLicensePlate(ocrText)) {
            DateTime agora = DateTime.now();
            String timestampFormatado =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(agora);
            var falcon = FalconApi();
            Map<String, dynamic> chave = {
              "placa": ocrText,
              "latlong": '${lat?.value.text} ${long?.value.text}',
              "datahora": timestampFormatado,
              "nick_usuario": 'teste',
            };
            await falconApi.enviarVeiculo(chave);
            Fluttertoast.showToast(
                msg: "Nova placa detectada!",
                toastLength: Toast
                    .LENGTH_SHORT, // Defina a duração do toast. Pode ser LENGTH_SHORT (curto) ou LENGTH_LONG (longo)
                gravity: ToastGravity
                    .BOTTOM, // Posição na tela onde o toast deve aparecer. Pode ser TOP, BOTTOM, CENTER
                timeInSecForIosWeb:
                    1, // Duração em segundos para exibição em iOS e web
                backgroundColor: Colors.green, // Cor de fundo do toast
                textColor: Colors.white, // Cor do texto
                fontSize: 16.0 // Tamanho do texto
                );
            AssetsAudioPlayer.newPlayer().open(
              Audio("assets/sons/insercao.mp3"),
              showNotification: true,
            );
          }
        }

        // Verifique se o texto é uma placa de licença.
      }
    } catch (e) {
      print(e);
    } finally {
      isBusy = false; // Permite que a próxima captura ocorra.
    }
  }
}

Uint8List concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  planes.forEach((plane) {
    allBytes.putUint8List(plane.bytes);
  });
  return allBytes.done().buffer.asUint8List();
}

bool isLicensePlate(String text) {
  RegExp plateRegExp = RegExp(
      r"^[A-Z]{3}-\d{4}$|^[A-Z]{3}\d[A-Z]\d{2}$|^[A-Z]{3}\d{1}[A-Z]{1}\d{2}$");
  return plateRegExp.hasMatch(text);
}

void showLicensePlate(String ocrText) {
  print("Placa do Veículo: $ocrText");
}

Future<dynamic> envioInforma() async {
  var falcon = FalconApi();
  File imagefile = File(imageFileList!.first.path);
  Uint8List imagebytes = await imagefile.readAsBytes();
  String base64string = base64.encode(imagebytes);
  Map<String, dynamic> chave = {
    "lat": lat?.value.text,
    "long": long?.value.text,
    "imagem": base64string,
    "timestamp": DateTime.now().millisecondsSinceEpoch,
  };
  print(chave);
  final conn = await falcon.enviarVeiculo(chave);
  print(conn);
}

Rx<TextEditingController>? lat = TextEditingController().obs;
Rx<TextEditingController>? long = TextEditingController().obs;
List<XFile>? imageFileList = [];
List<String>? imageFileEnvio = [];
final ImagePicker _picker = ImagePicker();

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('O serviço de localização está desabilitado.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('A localização não foi permitida');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  var current = await Geolocator.getCurrentPosition();
  lat?.value.text = current.latitude.toString();
  long?.value.text = current.longitude.toString();

  return await Geolocator.getCurrentPosition();
}
