import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<TextBlock> blocks;
  final Size previewSize;
  final Size screenSize;

  BoundingBoxPainter({
    required this.blocks,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // A proporção da visualização da câmera pode ser diferente da imagem processada.
    // Portanto, calcule a escala com base na largura e na altura separadamente.
    final double scaleX = screenSize.width / previewSize.width;
    final double scaleY = screenSize.height / previewSize.height;

    // Se a imagem foi cortada (por exemplo, para manter a proporção), você pode precisar ajustar o offset.
    // Calcula o offset baseado na diferença entre a altura da visualização da câmera e a altura da imagem processada pelo modelo.
    final double offsetY = (previewSize.height -
            screenSize.height * (previewSize.width / screenSize.width)) /
        2;

    for (var block in blocks) {
      final Rect rect = block.rect;
      final double left = rect.left * scaleX;
      final double top =
          (rect.top * scaleY) - offsetY; // Ajuste para o offsetY se necessário.
      final double right = rect.right * scaleX;
      final double bottom = (rect.bottom * scaleY) -
          offsetY; // Ajuste para o offsetY se necessário.

      final Paint paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
