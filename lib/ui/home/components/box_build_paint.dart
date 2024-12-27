import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:projeto_cicero/ui/home/components/orvelay_components.dart';

class BoundingBoxView extends StatelessWidget {
  final List<RecognizedText> blocks;
  final Size previewSize;
  final Size screenSize;
  final bool isPlateDetected;

  const BoundingBoxView({
    Key? key,
    required this.blocks,
    required this.previewSize,
    required this.screenSize,
    this.isPlateDetected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BoundingBoxPainter(
        previewSize,
        screenSize,
        blocks,
        isPlateDetected: isPlateDetected,
      ),
    );
  }
}
