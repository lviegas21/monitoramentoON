import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projeto_cicero/ui/home/components/box_build_paint.dart';

import '../../controller/home_page_controller.dart';
import 'components/orvelay_components.dart';

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    final controller = Get.find<HomePageController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Leitor de Placas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() => !controller.isButton.value
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedContainer(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            controller.isButton.value = true;
                            await controller.chamadaInicio();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 48, // Tamanho do ícone aumentado
                          ),
                          label: Text(
                            'Iniciar Leitor de Placas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        )),
                    const SizedBox(height: 50),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Toque no Botão para iniciar o leitor de placas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24, // Aumentei o tamanho da fonte para 24
                          fontWeight: FontWeight.bold, // Negrito
                          fontStyle: FontStyle.italic, // Itálico
                          letterSpacing: 1.2, // Espaçamento entre letras
                          wordSpacing: 2.0, // Espaçamento entre palavras
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        // Usar Expanded para preencher toda a coluna disponível.
                        child: AspectRatio(
                          // Usar AspectRatio para manter o aspecto da câmera.
                          aspectRatio: controller.controller.value.aspectRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.indigo,
                                width: 4.0,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit
                                  .expand, // Faz o Stack preencher o espaço disponível.
                              children: <Widget>[
                                CameraPreview(controller.controller),
                                BoundingBoxView(
                                  blocks: controller.textBoxs.value,
                                  previewSize:
                                      controller.controller.value.previewSize!,
                                  screenSize: MediaQuery.of(context).size,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(() => ElevatedButton(
                            onPressed: () => controller.toggleMonitoring(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.isMonitoring.value
                                  ? Colors.red
                                  : Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              controller.isMonitoring.value
                                  ? 'Parar Monitoramento'
                                  : 'Iniciar Monitoramento',
                              style: const TextStyle(fontSize: 16),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            )),
    );
  }
}
