import 'dart:ui';
import 'package:flame/components.dart';
import '../singularity_game.dart';
import '../config/config_loader.dart';
import 'structure.dart';
import 'agi_hub.dart';

abstract class EnemyComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  final String enemyType;
  late double maxHp;
  late double currentHp;
  late double speed;
  late int contactDamage;
  late int contactIntervalMs;
  late int bounty;
  late String targetType;

  PositionComponent? currentTarget;
  double timeSinceLastAttack = 0;
  bool isDead = false;
  double hpMultiplier = 1.0;

  EnemyComponent(this.enemyType, {this.hpMultiplier = 1.0})
      : super(anchor: Anchor.center);

  @override
  void onLoad() {
    final config = ConfigLoader.balance.enemies[enemyType]!;
    maxHp = config.hp * hpMultiplier;
    currentHp = maxHp;
    speed = config.speed;
    contactDamage = config.contactDamage;
    contactIntervalMs = config.contactIntervalMs;
    bounty = config.bounty;
    targetType = config.targetType;

    size = Vector2.all(20.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) return;

    timeSinceLastAttack += dt * 1000; // Convert to ms

    // Find or update target
    acquireTarget();

    if (currentTarget != null) {
      // Move towards target
      final direction = (currentTarget!.position - position).normalized();
      position += direction * speed * dt;

      // Check if in attack range
      final distance = (currentTarget!.position - position).length;
      if (distance < 30 && timeSinceLastAttack >= contactIntervalMs) {
        attack();
        timeSinceLastAttack = 0;
      }
    }
  }

  void acquireTarget() {
    // Check if current target is still valid
    if (currentTarget != null) {
      if (currentTarget is StructureComponent &&
          (currentTarget as StructureComponent).isDestroyed) {
        currentTarget = null;
      }
    }

    // Find new target if needed
    if (currentTarget == null) {
      if (targetType == 'agi_hub') {
        // Target the hub
        for (final component in gameRef.world.children) {
          if (component is AgiHubComponent) {
            currentTarget = component;
            break;
          }
        }
      } else {
        // Find nearest structure of the target type
        PositionComponent? nearestTarget;
        double nearestDistance = double.infinity;

        for (final component in gameRef.world.children) {
          if (component is StructureComponent &&
              component.structureType == targetType &&
              !component.isDestroyed) {
            final distance = (component.position - position).length;
            if (distance < nearestDistance) {
              nearestTarget = component;
              nearestDistance = distance;
            }
          }
        }

        currentTarget = nearestTarget;
      }
    }
  }

  void attack() {
    if (currentTarget is StructureComponent) {
      (currentTarget as StructureComponent).takeDamage(contactDamage);
    } else if (currentTarget is AgiHubComponent) {
      (currentTarget as AgiHubComponent).takeDamage(contactDamage);
    }
  }

  void takeDamage(int damage) {
    currentHp -= damage;
    if (currentHp <= 0 && !isDead) {
      isDead = true;
      onDeath();
    }
  }

  void onDeath() {
    gameRef.resourceManager.addMoney(bounty);
    gameRef.waveManager.onEnemyDied();
    removeFromParent();
  }

  Color getEnemyColor();

  List<Offset> getShapePoints();

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = getEnemyColor()
      ..style = PaintingStyle.fill;

    final path = Path()..addPolygon(getShapePoints(), true);
    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, borderPaint);

    // Draw HP bar
    if (currentHp < maxHp) {
      final hpRatio = currentHp / maxHp;
      final barWidth = 20.0;
      final barHeight = 3.0;

      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -15, barWidth, barHeight),
        Paint()..color = const Color(0xFF444444),
      );

      canvas.drawRect(
        Rect.fromLTWH(-barWidth / 2, -15, barWidth * hpRatio, barHeight),
        Paint()..color = const Color(0xFFFF0000),
      );
    }
  }
}
