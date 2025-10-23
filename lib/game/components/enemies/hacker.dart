import 'dart:ui';
import '../enemy.dart';

class Hacker extends EnemyComponent {
  Hacker({super.hpMultiplier}) : super('hacker');

  @override
  Color getEnemyColor() {
    return const Color(0xFFFF00FF); // Magenta
  }

  @override
  List<Offset> getShapePoints() {
    // Triangle pointing down
    return [
      const Offset(0, -8),
      const Offset(8, 8),
      const Offset(-8, 8),
    ];
  }
}
