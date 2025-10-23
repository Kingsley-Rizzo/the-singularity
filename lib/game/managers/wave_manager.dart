import 'dart:math';
import 'package:flame/components.dart';
import '../config/config_loader.dart';
import '../singularity_game.dart';

class WaveManager {
  final SingularityGame game;
  int currentWaveIndex = 0;
  double timeSinceLastWave = 0;
  bool waveInProgress = false;
  int enemiesAlive = 0;

  WaveManager(this.game);

  void update(double dt) {
    timeSinceLastWave += dt;

    final waveConfig = ConfigLoader.wave;
    final waveInterval = waveConfig.waveIntervalS.toDouble();

    if (!waveInProgress && timeSinceLastWave >= waveInterval) {
      spawnWave();
      timeSinceLastWave = 0;
    }

    // Check if wave is cleared
    if (waveInProgress && enemiesAlive <= 0) {
      onWaveCleared();
    }
  }

  void spawnWave() {
    final waveConfig = ConfigLoader.wave;

    Map<String, int> enemiesToSpawn;
    double hpMultiplier = 1.0;

    if (currentWaveIndex < waveConfig.waves.length) {
      enemiesToSpawn = Map.from(waveConfig.waves[currentWaveIndex].enemies);
    } else {
      // Dynamic scaling for waves beyond predefined ones
      final lastWave = waveConfig.waves.last;
      final wavesAhead = currentWaveIndex - waveConfig.waves.length + 1;

      hpMultiplier = 1.0 + (waveConfig.scaling.hpMultPerWave * wavesAhead);
      final countMultiplier =
          1.0 + (waveConfig.scaling.countMultPerWave * wavesAhead);

      enemiesToSpawn = {};
      lastWave.enemies.forEach((type, count) {
        enemiesToSpawn[type] = (count * countMultiplier).round();
      });
    }

    // Spawn enemies from settlements
    final random = Random();

    if (game.settlements.isEmpty) {
      // Fallback to old behavior if no settlements exist
      final arenaRadius = 400.0;
      enemiesToSpawn.forEach((enemyType, count) {
        for (int i = 0; i < count; i++) {
          final angle = random.nextDouble() * 2 * pi;
          final spawnX = cos(angle) * arenaRadius;
          final spawnY = sin(angle) * arenaRadius;

          game.spawnEnemy(enemyType, Vector2(spawnX, spawnY), hpMultiplier);
          enemiesAlive++;
        }
      });
    } else {
      // Spawn enemies from random settlements
      enemiesToSpawn.forEach((enemyType, count) {
        for (int i = 0; i < count; i++) {
          // Pick a random settlement
          final settlement =
              game.settlements[random.nextInt(game.settlements.length)];

          // Spawn at or near the settlement position
          // Add slight random offset to avoid all enemies stacking
          final offsetX = (random.nextDouble() - 0.5) * 20;
          final offsetY = (random.nextDouble() - 0.5) * 20;
          final spawnPos = settlement.position + Vector2(offsetX, offsetY);

          game.spawnEnemy(enemyType, spawnPos, hpMultiplier);
          enemiesAlive++;
        }
      });
    }

    waveInProgress = true;
    currentWaveIndex++;
  }

  void onEnemyDied() {
    enemiesAlive--;
  }

  void onWaveCleared() {
    waveInProgress = false;

    // Wave cleared - no bonus AGI (AGI only comes from Server Farms now)
  }

  void reset() {
    currentWaveIndex = 0;
    timeSinceLastWave = 0;
    waveInProgress = false;
    enemiesAlive = 0;
  }
}
