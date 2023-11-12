import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:projeto_cicero/ui/home/components/orvelay_components.dart';

class BoundingBoxView extends StatelessWidget {
  final List<TextBlock> blocks;
  final Size? previewSize;
  final Size screenSize;

  BoundingBoxView({
    required this.blocks,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BoundingBoxPainter(
        blocks: blocks,
        previewSize: previewSize!,
        screenSize: screenSize,
      ),
    );
  }
}
