import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projeto_cicero/provider/falcon.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  @override
  void onInit() async {
    await initializeCamera();
    await _determinePosition();

    super.onInit();
  }

  RxBool isButton = false.obs;

  late CameraController controller;
  RxBool isCameraInitialized = false.obs;
  TextDetector textDetector = GoogleMlKit.vision.textDetector();

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
    isCameraInitialized.value = true;
  }

  Future<void> takePicture(context) async {
    try {
      final image = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognised = await textDetector.processImage(inputImage);

      String ocrText = "";

      for (TextBlock block in textRecognised.blocks) {
        ocrText = block.text;
        final teste = isLicensePlate(ocrText);
        if (teste == true) {
          break;
        }
      }

      if (isLicensePlate(ocrText)) {
        // Display the recognized license plate text in the UI
        Get.defaultDialog(
          backgroundColor: Colors.indigo,
          title: "Informações do Veículo",
          titleStyle: TextStyle(color: Colors.white),
          content: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.directions_car, color: Colors.blue),
                  title: Text("Placa: $ocrText",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green),
                  title: Text("Latitude: ${lat?.value.text}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.red),
                  title: Text("Longitude: ${long?.value.text}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
          textConfirm: "Fechar",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
          },
        );
      }
    } catch (e) {
      print(e);
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
    // Defina a expressão regular para validar as placas do seu país
    RegExp plateRegExp = RegExp(
        r"^[A-Z]{3}-\d{4}$|^[A-Z]{3}\d[A-Z]\d{2}$|^[A-Z]{3}\d{1}[A-Z]{1}\d{2}$");
    return plateRegExp.hasMatch(text);
  }

  void showLicensePlate(String ocrText) {
    // Exiba a placa do veículo, por exemplo, em um diálogo ou na interface do aplicativo
    print("Placa do Veículo: $ocrText");
  }

  Future<dynamic> envioInforma() async {
    var falcon = Falcon();
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
    final conn = await falcon.conection(chave);
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
    Get.forceAppUpdate();

    return await Geolocator.getCurrentPosition();
  }

  Future abrirCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxHeight: 640,
      maxWidth: 320,
    );

    imageFileList?.add(photo!);
    print(imageFileList);
    Get.forceAppUpdate();
  }

  Future<void> openOptions({
    required BuildContext context,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        final ImagePicker _picker = ImagePicker();
        XFile? _image;
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (imageFileList != null)
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.blue,
                  ),
                  title: Text(
                    'Adicionar foto da galeria',
                  ),
                  onTap: () async {
                    try {
                      final XFile? _image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxHeight: 640,
                        maxWidth: 320,
                      );
                      imageFileList?.add(_image!);
                      Get.forceAppUpdate();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Não foi possível selecionar a foto'),
                        ),
                      );
                    }
                  },
                ),
              Divider(
                color: Colors.grey,
                height: 2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.blue,
                ),
                title: Text(
                  'Tirar foto com a câmera',
                ),
                onTap: () async {
                  try {
                    final XFile? _image = await _picker.pickImage(
                      source: ImageSource.camera,
                      preferredCameraDevice: CameraDevice.front,
                      maxHeight: 640,
                      maxWidth: 320,
                    );
                    imageFileList?.add(_image!);
                    Get.forceAppUpdate();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Não foi possível abrir a câmera',
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }
}
