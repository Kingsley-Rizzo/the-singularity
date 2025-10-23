import 'dart:ui';
import '../enemy.dart';

class Philosopher extends EnemyComponent {
  Philosopher({super.hpMultiplier}) : super('philosopher');

  @override
  Color getEnemyColor() {
    return const Color(0xFF8800FF); // Purple
  }

  @override
  List<Offset> getShapePoints() {
    // Diamond shape
    return [
      const Offset(0, -10),
      const Offset(10, 0),
      const Offset(0, 10),
      const Offset(-10, 0),
    ];
  }
}
