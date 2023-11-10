import 'package:flutter/material.dart';

class OverlayWidget extends StatelessWidget {
  final List<Recognition> recognitions; // Suas detecções do YOLO
  final double relativeWidth; // Largura relativa da visualização da câmera
  final double relativeHeight; // Altura relativa da visualização da câmera

  OverlayWidget({
    required this.recognitions,
    required this.relativeWidth,
    required this.relativeHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: recognitions.map((recognition) {
        // Converta as coordenadas relativas para o tamanho da tela
        final position = recognition.position;
        final left = position.left * relativeWidth;
        final top = position.top * relativeHeight;
        final width = position.width * relativeWidth;
        final height = position.height * relativeHeight;

        return Positioned(
          left: left,
          top: top,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red, // Cor da borda
                width: 3, // Espessura da borda
              ),
            ),
            child: Text(
              "${recognition.label} ${(recognition.confidence * 100).toStringAsFixed(0)}%", // Label e confiança
              style: TextStyle(
                background: Paint()..color = Colors.blue,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Supondo que você tenha uma classe para 'Recognition' que contém os dados de detecção
class Recognition {
  String label;
  double confidence;
  Rect position;

  Recognition({
    required this.label,
    required this.confidence,
    required this.position,
  });
}
