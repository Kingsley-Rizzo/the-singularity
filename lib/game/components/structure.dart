import 'dart:ui';
import 'package:flame/components.dart';
import '../singularity_game.dart';
import '../config/config_loader.dart';

abstract class StructureComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  final String structureType;
  late double maxHp;
  late double currentHp;
  late int energyReserve;
  late int energyBudgetIncrease;
  late int moneyPerTick;
  late double agiPerTick;
  double structureSize = 30.0;

  bool isDestroyed = false;
  Sprite? sprite;

  StructureComponent(this.structureType) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final config = ConfigLoader.balance.structures[structureType]!;
    maxHp = config.hp.toDouble();
    currentHp = maxHp;
    energyReserve = config.energyReserve;
    energyBudgetIncrease = config.energyBudgetIncrease;
    moneyPerTick = config.moneyPerTick;
    agiPerTick = config.agiPerTick;
    size = Vector2.all(structureSize);

    // Load sprite based on structure type
    await loadSprite();

    gameRef.buildManager.registerStructure(this);
  }

  Future<void> loadSprite() async {
    final spriteMap = {
      'turret': 'Turret.png',
      'energy_plant': 'EnergyPlant.png',
      'server_farm': 'ServerFarm.png',
    };

    final spriteName = spriteMap[structureType];
    if (spriteName != null) {
      try {
        print('Loading sprite for $structureType: config/sprites/$spriteName');
        sprite = await gameRef.loadSprite('config/sprites/$spriteName');
        print('Successfully loaded sprite for $structureType');
      } catch (e) {
        print('Failed to load sprite for $structureType: $e');
      }
    }
  }

  @override
  void onRemove() {
    gameRef.buildManager.unregisterStructure(this);
    super.onRemove();
  }

  void takeDamage(int damage) {
    currentHp -= damage;
    if (currentHp <= 0 && !isDestroyed) {
      isDestroyed = true;
      onDestroyed();
    }
  }

  void onDestroyed() {
    removeFromParent();
  }

  Color getStructureColor();

  @override
  void render(Canvas canvas) {
    // Draw sprite if available, otherwise fall back to colored rectangle
    if (sprite != null) {
      sprite!.render(
        canvas,
        position: Vector2.zero(),
        size: Vector2.all(structureSize),
      );
    } else {
      // Fallback to colored rectangle
      final paint = Paint()
        ..color = getStructureColor()
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(structureSize / 2, structureSize / 2),
          width: structureSize,
          height: structureSize,
        ),
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(structureSize / 2, structureSize / 2),
          width: structureSize,
          height: structureSize,
        ),
        borderPaint,
      );
    }

    // Draw HP bar
    if (currentHp < maxHp) {
      final hpRatio = currentHp / maxHp;
      final barWidth = structureSize;
      final barHeight = 4.0;

      // Background
      canvas.drawRect(
        Rect.fromLTWH(0, -8, barWidth, barHeight),
        Paint()..color = const Color(0xFF444444),
      );

      // HP
      canvas.drawRect(
        Rect.fromLTWH(0, -8, barWidth * hpRatio, barHeight),
        Paint()..color = const Color(0xFF00FF00),
      );
    }
  }

  int getSellValue() {
    final cost = ConfigLoader.balance.structures[structureType]!.cost;
    final refundRatio = ConfigLoader.balance.economy.sellRefundRatio;
    return (cost * refundRatio).floor();
  }
}
