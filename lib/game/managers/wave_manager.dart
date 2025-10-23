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

    // Spawn enemies at edge positions
    final arenaRadius = 400.0;
    final random = Random();

    enemiesToSpawn.forEach((enemyType, count) {
      for (int i = 0; i < count; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final spawnX = cos(angle) * arenaRadius;
        final spawnY = sin(angle) * arenaRadius;

        game.spawnEnemy(enemyType, Vector2(spawnX, spawnY), hpMultiplier);
        enemiesAlive++;
      }
    });

    waveInProgress = true;
    currentWaveIndex++;
  }

  void onEnemyDied() {
    enemiesAlive--;
  }

  void onWaveCleared() {
    waveInProgress = false;

    // Grant AGI bonus
    final bonus = ConfigLoader.balance.agi.waveClearBonus;
    game.resourceManager.addAgi(bonus);
  }

  void reset() {
    currentWaveIndex = 0;
    timeSinceLastWave = 0;
    waveInProgress = false;
    enemiesAlive = 0;
  }
}
