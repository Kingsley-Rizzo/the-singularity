import 'dart:ui';
import 'package:flutter/material.dart';
import 'structure.dart';

class ServerFarm extends StructureComponent {
  ServerFarm() : super('server_farm');

  @override
  Color getStructureColor() {
    // Grey out when power is not OK (brownout)
    if (!gameRef.resourceManager.isPowerOk) {
      return const Color(0xFF404040); // Dark grey
    }
    return const Color(0xFF00FF00); // Green
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Add visual indication for brownout
    if (!gameRef.resourceManager.isPowerOk) {
      // Draw diagonal lines over the structure to indicate offline status
      final linePaint = Paint()
        ..color = Colors.red.withOpacity(0.6)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Draw X pattern
      canvas.drawLine(
        const Offset(0, 0),
        Offset(structureSize, structureSize),
        linePaint,
      );
      canvas.drawLine(
        Offset(structureSize, 0),
        Offset(0, structureSize),
        linePaint,
      );
    }
  }
}
