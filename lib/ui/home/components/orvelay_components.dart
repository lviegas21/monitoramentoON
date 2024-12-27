import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_ml_kit/google_ml_kit.dart';

class BoundingBoxPainter extends CustomPainter {
  final Size previewSize;
  final Size screenSize;
  final List<RecognizedText> blocks;
  final bool isPlateDetected;

  BoundingBoxPainter(this.previewSize, this.screenSize, this.blocks, {this.isPlateDetected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = isPlateDetected ? Colors.green : Colors.red;

    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.black54,
    );

    final double scaleX = screenSize.width / previewSize.width;
    final double scaleY = screenSize.height / previewSize.height;
    final double scale = math.min(scaleX, scaleY);

    final double offsetX = (screenSize.width - previewSize.width * scale) / 2;
    final double offsetY = (screenSize.height - previewSize.height * scale) / 2;

    for (var recognizedText in blocks) {
      for (var block in recognizedText.blocks) {
        final rect = block.boundingBox;
        if (rect == null) continue;
        
        // Ajusta as coordenadas do retângulo para a escala da tela
        final Rect adjustedRect = Rect.fromLTRB(
          offsetX + rect.left * scale,
          offsetY + rect.top * scale,
          offsetX + rect.right * scale,
          offsetY + rect.bottom * scale,
        );

        // Desenha o retângulo
        canvas.drawRect(adjustedRect, paint);

        // Se houver texto da placa, desenha-o acima do retângulo
        if (block.text.isNotEmpty) {
          final textSpan = TextSpan(
            text: block.text,
            style: textStyle,
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          // Posiciona o texto acima do retângulo com fundo preto semitransparente
          final textX = adjustedRect.left;
          final textY = adjustedRect.top - textPainter.height - 5;
          
          // Desenha o fundo do texto
          final textBackground = Rect.fromLTWH(
            textX - 4,
            textY - 4,
            textPainter.width + 8,
            textPainter.height + 8,
          );
          canvas.drawRect(textBackground, Paint()..color = Colors.black54);
          
          // Desenha o texto
          textPainter.paint(canvas, Offset(textX, textY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
