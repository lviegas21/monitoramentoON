import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerDemo(),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  // var dataList = [];
  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, maxWidth: 224, maxHeight: 224);
      var prediction = await Tflite.runModelOnImage(
          path: image!.path,
          numResults: 2,
          threshold: 0.6,
          imageMean: 127.5,
          imageStd: 127.5);
      print(prediction);
      // setState(() {
      //   _image = image;
      //   file = File(image!.path);
      // });
      // detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Uint8List imageToByteListUint8(img.Image image, int inputSize) {
  //   var buffer = Uint8List(1 * inputSize * inputSize * 3);
  //   int pixelIndex = 0;

  //   // Resize and crop image to expected size (inputSize x inputSize)
  //   image = img.copyResize(image, width: inputSize, height: inputSize);
  //   print(image);

  //   for (var i = 0; i < inputSize; i++) {
  //     for (var j = 0; j < inputSize; j++) {
  //       var pixel = image.getPixel(j, i);
  //       buffer[pixelIndex++] = img.getRed(pixel);
  //       buffer[pixelIndex++] = img.getGreen(pixel);
  //       buffer[pixelIndex++] = img.getBlue(pixel);
  //     }
  //   }
  //   return buffer;
  // }

  Future detectimage(io.File imageFile) async {
    // int startTime = new DateTime.now().millisecondsSinceEpoch;
    // Uint8List imageBytes = await imageFile.readAsBytes();

    // // Decodificar a imagem para um objeto da biblioteca 'image'.
    // img.Image? decodedImage = img.decodeImage(imageBytes);

    // if (decodedImage != null) {
    //   // Converta o objeto img.Image para um Uint8List adequado para TFLite.
    //   Uint8List inputImage = imageToByteListUint8(decodedImage, 224);

    //   // Execute o modelo TFLite na imagem processada.
    //   var recognitions = await Tflite.runModelOnBinary(
    //       binary: inputImage, // seus dados binários processados
    //       numResults: 2,
    //       threshold: 0.05,
    //       asynch: true);

    //   setState(() {
    //     _recognitions = recognitions;
    //     v = recognitions.toString();
    //     // dataList = List<Map<String, dynamic>>.from(jsonDecode(v));
    //   });
    print("//////////////////////////////////////////////////");

    // print(dataList);
    print("//////////////////////////////////////////////////");
    int endTime = new DateTime.now().millisecondsSinceEpoch;

    // Faça algo com os reconhecimentos...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter TFlite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}
