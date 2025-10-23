import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../singularity_game.dart';

/// Human settlement component - represented as a brown circle
/// Enemies spawn from these settlements
class Settlement extends PositionComponent with HasGameRef<SingularityGame> {
  static const double settlementRadius = 25.0;

  Settlement() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(settlementRadius * 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Main brown settlement body
    final settlementPaint = Paint()
      ..color = const Color(0xFF8B4513) // Saddle brown
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(settlementRadius, settlementRadius),
      settlementRadius,
      settlementPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF654321) // Darker brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(settlementRadius, settlementRadius),
      settlementRadius,
      borderPaint,
    );

    // Inner details to make it look like buildings/settlement
    final detailPaint = Paint()
      ..color = const Color(0xFF654321).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw a few small rectangles to represent buildings
    canvas.drawRect(
      Rect.fromLTWH(settlementRadius - 8, settlementRadius - 6, 5, 8),
      detailPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(settlementRadius + 3, settlementRadius - 4, 5, 6),
      detailPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(settlementRadius - 3, settlementRadius + 2, 4, 5),
      detailPaint,
    );
  }
}
