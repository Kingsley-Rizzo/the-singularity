import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../singularity_game.dart';

/// Visual component for the circular arena boundary
class ArenaComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  final double radius;

  ArenaComponent({this.radius = 400}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2.zero(); // Center of world
    // Size should encompass the entire circle
    size = Vector2.all(radius * 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circle centered at component position
    canvas.drawCircle(
      Offset(radius, radius), // Center within the component's bounds
      radius,
      paint,
    );
  }
}
