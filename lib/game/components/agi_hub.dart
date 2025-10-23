import 'dart:ui';
import 'package:flame/components.dart';
import '../singularity_game.dart';

class AgiHubComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  final double radius = 40.0;

  AgiHubComponent() : super(anchor: Anchor.center);

  @override
  void onLoad() {
    position = Vector2.zero(); // Center of the world
    size = Vector2.all(radius * 2);
  }

  @override
  void render(Canvas canvas) {
    // Draw main hub as a circle
    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      borderPaint,
    );
  }

  void takeDamage(int damage) {
    // Convert damage to AGI percent loss
    // Each point of damage = ~0.5% AGI
    final agiLoss = damage * 0.5;
    gameRef.resourceManager.removeAgi(agiLoss);
  }
}
