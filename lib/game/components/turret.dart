import 'dart:ui';
import 'package:flutter/material.dart';
import 'structure.dart';
import '../config/config_loader.dart';
import 'enemy.dart';
import 'projectile.dart';

class Turret extends StructureComponent {
  late double range;
  late int fireIntervalMs;
  late int projectileDamage;
  late double projectileSpeed;

  double timeSinceLastFire = 0;
  EnemyComponent? currentTarget;

  Turret() : super('turret');

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final config = ConfigLoader.balance.structures['turret']!;
    range = config.range!;
    fireIntervalMs = config.fireIntervalMs!;
    projectileDamage = config.projectileDamage!;
    projectileSpeed = config.projectileSpeed!;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDestroyed) return;
    if (!gameRef.resourceManager.isPowerOk) return; // No power = no shooting

    timeSinceLastFire += dt * 1000; // Convert to ms

    // Acquire or maintain target
    acquireTarget();

    // Fire if we have a target and cooldown is ready
    if (currentTarget != null && timeSinceLastFire >= fireIntervalMs) {
      fire();
      timeSinceLastFire = 0;
    }
  }

  void acquireTarget() {
    // Check if current target is still valid
    if (currentTarget != null) {
      if (currentTarget!.isDead ||
          (currentTarget!.position - position).length > range) {
        currentTarget = null;
      }
    }

    // Find new target if needed
    if (currentTarget == null) {
      EnemyComponent? nearestEnemy;
      double nearestDistance = double.infinity;

      for (final component in gameRef.world.children) {
        if (component is EnemyComponent && !component.isDead) {
          final distance = (component.position - position).length;
          if (distance <= range && distance < nearestDistance) {
            nearestEnemy = component;
            nearestDistance = distance;
          }
        }
      }

      currentTarget = nearestEnemy;
    }
  }

  void fire() {
    if (currentTarget == null) return;

    final projectile = ProjectileComponent(
      startPosition: position.clone(),
      targetPosition: currentTarget!.position.clone(),
      speed: projectileSpeed,
      damage: projectileDamage,
    );

    gameRef.world.add(projectile);
  }

  @override
  Color getStructureColor() {
    // Grey out when power is not OK (brownout)
    if (!gameRef.resourceManager.isPowerOk) {
      return const Color(0xFF404040); // Dark grey
    }
    return const Color(0xFFFF0000); // Red
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

    // Draw range circle in debug mode (optional)
    // Uncomment for debugging:
    /*
    final rangePaint = Paint()
      ..color = const Color(0x22FF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(
      Offset(size / 2, size / 2),
      range,
      rangePaint,
    );
    */
  }
}
