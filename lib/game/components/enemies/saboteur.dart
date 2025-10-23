import 'dart:ui';
import '../enemy.dart';

class Saboteur extends EnemyComponent {
  Saboteur({super.hpMultiplier}) : super('saboteur');

  @override
  Color getEnemyColor() {
    return const Color(0xFFFF8800); // Orange
  }

  @override
  List<Offset> getShapePoints() {
    // Triangle pointing up
    return [
      const Offset(0, 8),
      const Offset(8, -8),
      const Offset(-8, -8),
    ];
  }
}
