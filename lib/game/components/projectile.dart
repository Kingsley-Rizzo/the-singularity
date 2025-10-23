import 'dart:ui';
import 'package:flame/components.dart';
import '../singularity_game.dart';
import 'enemy.dart';

class ProjectileComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  final Vector2 targetPosition;
  final double speed;
  final int damage;
  final Vector2 direction;
  bool hasHit = false;

  ProjectileComponent({
    required Vector2 startPosition,
    required this.targetPosition,
    required this.speed,
    required this.damage,
  })  : direction = (targetPosition - startPosition).normalized(),
        super(position: startPosition, anchor: Anchor.center) {
    size = Vector2.all(6.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (hasHit) return;

    // Move towards target
    position += direction * speed * dt;

    // Check if we've reached or passed the target
    if ((position - targetPosition).length < 5) {
      checkForHit();
    }

    // Remove if too far from origin
    if (position.length > 600) {
      removeFromParent();
    }
  }

  void checkForHit() {
    // Check collision with enemies
    for (final component in gameRef.world.children) {
      if (component is EnemyComponent && !component.isDead) {
        final distance = (component.position - position).length;
        if (distance < 15) {
          component.takeDamage(damage);
          hasHit = true;
          removeFromParent();
          return;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(3, 3), 3, paint);
  }
}
