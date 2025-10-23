import 'dart:ui';
import 'package:flame/components.dart';
import '../singularity_game.dart';

class AgiHubComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  final double radius = 40.0;
  Sprite? sprite;

  AgiHubComponent() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2.zero(); // Center of the world
    size = Vector2.all(radius * 2);

    // Load sprite
    try {
      print('Loading AGI hub sprite: config/sprites/AGI.png');
      sprite = await gameRef.loadSprite('config/sprites/AGI.png');
      print('Successfully loaded AGI hub sprite');
    } catch (e) {
      print('Failed to load AGI hub sprite: $e');
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw sprite if available, otherwise fall back to circle
    if (sprite != null) {
      sprite!.render(
        canvas,
        position: Vector2.zero(),
        size: Vector2.all(radius * 2),
      );
    } else {
      // Fallback to circle
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
  }

  void takeDamage(int damage) {
    // Convert damage to AGI percent loss
    // Each point of damage = ~0.5% AGI
    final agiLoss = damage * 0.5;
    gameRef.resourceManager.removeAgi(agiLoss);
  }
}
