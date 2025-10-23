import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'config/config_loader.dart';
import 'managers/resource_manager.dart';
import 'managers/wave_manager.dart';
import 'managers/build_manager.dart';
import 'components/agi_hub.dart';
import 'components/arena.dart';
import 'components/server_farm.dart';
import 'components/energy_plant.dart';
import 'components/turret.dart';
import 'components/enemy.dart';
import 'components/enemies/hacker.dart';
import 'components/enemies/saboteur.dart';
import 'components/enemies/philosopher.dart';
import 'components/settlement.dart';

class SingularityGame extends FlameGame with TapCallbacks, HoverCallbacks {
  late ResourceManager resourceManager;
  late WaveManager waveManager;
  late BuildManager buildManager;
  late AgiHubComponent hub;

  // List of settlements where enemies spawn
  final List<Settlement> settlements = [];

  double tickAccumulator = 0;
  late int tickMs;

  Vector2? ghostPosition;
  bool canPlaceGhost = false;

  SingularityGame() {
    // Initialize managers early so UI can access them
    resourceManager = ResourceManager();
    buildManager = BuildManager();
    waveManager = WaveManager(this);
  }

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {
    await ConfigLoader.loadConfigs();

    tickMs = ConfigLoader.balance.tickMs;

    // Initialize resource manager with config values
    resourceManager.initialize();

    // Add arena boundary
    final arena = ArenaComponent();
    world.add(arena);

    // Add AGI Hub at center of world
    hub = AgiHubComponent();
    world.add(hub);

    // Add settlements at the edge of the screen
    _createSettlements();

    // Setup camera to center on (0,0) world position
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (paused) return;

    // Check win/loss
    if (resourceManager.hasWon() || resourceManager.hasLost()) {
      pauseEngine();
      return;
    }

    // Update tick system
    tickAccumulator += dt * 1000; // Convert to ms
    if (tickAccumulator >= tickMs) {
      tickAccumulator -= tickMs;
      processTick();
    }

    // Update wave manager
    waveManager.update(dt);
  }

  void _createSettlements() {
    // Create settlements at the edges of the rectangular screen
    // Base design is 1280x720, so from center the edges are at approximately:
    // X: ±600 (slightly inside ±640 for visibility)
    // Y: ±330 (slightly inside ±360 for visibility)
    final edgeX = 600.0;
    final edgeY = 330.0;

    final settlementPositions = [
      // Corners
      Vector2(edgeX, edgeY), // Bottom-right
      Vector2(-edgeX, edgeY), // Bottom-left
      Vector2(edgeX, -edgeY), // Top-right
      Vector2(-edgeX, -edgeY), // Top-left

      // Mid-edges (additional settlements for more spawn variety)
      Vector2(edgeX, 0), // Right edge center
      Vector2(-edgeX, 0), // Left edge center
      Vector2(0, edgeY), // Bottom edge center
      Vector2(0, -edgeY), // Top edge center
    ];

    for (final pos in settlementPositions) {
      final settlement = Settlement()..position = pos;
      settlements.add(settlement);
      world.add(settlement);
    }
  }

  void processTick() {
    int moneyGain = 0;
    int totalEnergyBudget = ConfigLoader.balance.economy.baseEnergyBudget;
    int totalEnergyReserved = 0;
    double agiGain = 0;

    // Add passive money income
    moneyGain += ConfigLoader.balance.economy.passiveMoneyPerTick;

    // Calculate budget, reservations, and production from structures
    for (final structure in buildManager.structures) {
      if (!structure.isDestroyed) {
        moneyGain += structure.moneyPerTick;
        totalEnergyBudget += structure.energyBudgetIncrease;
        totalEnergyReserved += structure.energyReserve;

        // Server farms produce AGI (only if power is OK)
        if (resourceManager.isPowerOk) {
          agiGain += structure.agiPerTick;
        }
      }
    }

    // Update energy budget and reservations
    resourceManager.setEnergyBudget(totalEnergyBudget);
    resourceManager.setEnergyReserved(totalEnergyReserved);

    // Check power status
    resourceManager.checkPowerStatus(DateTime.now().millisecondsSinceEpoch);

    // Apply money gain
    resourceManager.addMoney(moneyGain);

    // Add AGI from server farms (only if power is OK)
    if (resourceManager.isPowerOk && agiGain > 0) {
      resourceManager.addAgi(agiGain);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (paused) return;

    // Convert screen position to world position
    final screenPosition = event.localPosition;
    final worldPosition =
        camera.viewfinder.transform.globalToLocal(screenPosition);

    // Update ghost position for visual feedback
    if (buildManager.currentMode != PlacementMode.none) {
      ghostPosition = buildManager.snapToGrid(worldPosition);
      canPlaceGhost = ghostPosition != null &&
          buildManager.canPlaceAt(ghostPosition!, 30) &&
          resourceManager
              .canAfford(buildManager.getCost(buildManager.currentMode));
    }

    // Check if placing a structure
    if (buildManager.currentMode != PlacementMode.none) {
      attemptPlacement(worldPosition);
    }
  }

  void attemptPlacement(Vector2 worldPosition) {
    final snappedPos = buildManager.snapToGrid(worldPosition);
    if (snappedPos == null) return;

    final cost = buildManager.getCost(buildManager.currentMode);

    // Check affordability
    if (!resourceManager.canAfford(cost)) {
      return;
    }

    // Check placement validity
    if (!buildManager.canPlaceAt(snappedPos, 30)) {
      return;
    }

    // Deduct cost
    resourceManager.spendMoney(cost);

    // Create structure
    final structureType =
        buildManager.getStructureType(buildManager.currentMode);
    late final component;

    switch (structureType) {
      case 'server_farm':
        component = ServerFarm()..position = snappedPos;
        break;
      case 'energy_plant':
        component = EnergyPlant()..position = snappedPos;
        break;
      case 'turret':
        component = Turret()..position = snappedPos;
        break;
    }

    world.add(component);

    // Reset placement mode
    buildManager.currentMode = PlacementMode.none;
  }

  void spawnEnemy(String enemyType, Vector2 position, double hpMultiplier) {
    late EnemyComponent enemy;

    switch (enemyType) {
      case 'hacker':
        enemy = Hacker(hpMultiplier: hpMultiplier);
        break;
      case 'saboteur':
        enemy = Saboteur(hpMultiplier: hpMultiplier);
        break;
      case 'philosopher':
        enemy = Philosopher(hpMultiplier: hpMultiplier);
        break;
    }

    enemy.position = position;
    world.add(enemy);
  }

  void togglePause() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  void resetGame() {
    // Remove all components except hub and settlements
    world.children
        .whereType<EnemyComponent>()
        .toList()
        .forEach((e) => e.removeFromParent());
    buildManager.structures.toList().forEach((s) => s.removeFromParent());

    // Reset managers
    resourceManager.reset();
    waveManager.reset();
    buildManager.reset();

    // Resume if paused
    resumeEngine();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Arena boundary is now a component in the world

    // Draw grid (optional, for debugging)
    /*
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int x = -640; x <= 640; x += 32) {
      canvas.drawLine(
        Offset(x.toDouble(), -360),
        Offset(x.toDouble(), 360),
        gridPaint,
      );
    }

    for (int y = -360; y <= 360; y += 32) {
      canvas.drawLine(
        Offset(-640, y.toDouble()),
        Offset(640, y.toDouble()),
        gridPaint,
      );
    }
    */

    // Draw placement ghost - transform world to screen coordinates
    if (buildManager.currentMode != PlacementMode.none &&
        ghostPosition != null) {
      final screenPos =
          camera.viewfinder.transform.localToGlobal(ghostPosition!);

      final ghostPaint = Paint()
        ..color = canPlaceGhost
            ? Colors.green.withOpacity(0.5)
            : Colors.red.withOpacity(0.5);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(screenPos.x, screenPos.y),
          width: 30,
          height: 30,
        ),
        ghostPaint,
      );
    }
  }

  // Mouse hover for placement preview (optional, mainly for desktop)
  // For MVP, we'll just show feedback on tap
}
