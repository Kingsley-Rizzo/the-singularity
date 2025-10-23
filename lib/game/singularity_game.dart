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

class SingularityGame extends FlameGame with TapCallbacks, HoverCallbacks {
  late ResourceManager resourceManager;
  late WaveManager waveManager;
  late BuildManager buildManager;
  late AgiHubComponent hub;

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

  void processTick() {
    int moneyGain = 0;
    int energyGain = 0;
    int totalUpkeep = 0;

    // Calculate income from structures
    for (final structure in buildManager.structures) {
      if (!structure.isDestroyed) {
        moneyGain += structure.moneyPerTick;
        energyGain += structure.energyPerTick;
        totalUpkeep += structure.upkeepEnergy;
      }
    }

    // Apply gains
    resourceManager.addMoney(moneyGain);
    resourceManager.addEnergy(energyGain);
    resourceManager.removeEnergy(totalUpkeep);

    // Check power status
    resourceManager.checkPowerStatus(DateTime.now().millisecondsSinceEpoch);

    // Add passive AGI if power is OK
    if (resourceManager.isPowerOk) {
      final agiGain = ConfigLoader.balance.agi.passivePerTick;
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
    // Remove all components except hub
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
