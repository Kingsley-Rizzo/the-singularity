import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/resource_manager.dart';
import '../singularity_game.dart';

class GameHUD extends StatelessWidget {
  final SingularityGame game;

  const GameHUD({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.resourceManager,
      child: SafeArea(
        child: Stack(
          children: [
            // Top bar with resources
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black.withOpacity(0.7),
                child: Consumer<ResourceManager>(
                  builder: (context, resources, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResourceDisplay(
                          Icons.attach_money,
                          'Money',
                          resources.money.toString(),
                          Colors.green,
                        ),
                        _buildResourceDisplay(
                          Icons.bolt,
                          'Energy',
                          resources.energy.toString(),
                          resources.energy >= 0 ? Colors.yellow : Colors.red,
                        ),
                        _buildResourceDisplay(
                          Icons.psychology,
                          'AGI',
                          '${resources.agiPercent.toStringAsFixed(1)}%',
                          Colors.cyan,
                        ),
                        _buildResourceDisplay(
                          Icons.waves,
                          'Wave',
                          (game.waveManager.currentWaveIndex).toString(),
                          Colors.white,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Pause button
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(
                  game.paused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
                onPressed: () {
                  game.togglePause();
                },
              ),
            ),

            // Win/Loss overlay
            Consumer<ResourceManager>(
              builder: (context, resources, child) {
                if (resources.hasWon()) {
                  return _buildGameOverOverlay(
                    'Victory!',
                    'AGI has achieved 100%',
                    Colors.green,
                  );
                } else if (resources.hasLost()) {
                  return _buildGameOverOverlay(
                    'Defeat',
                    'AGI has been destroyed',
                    Colors.red,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceDisplay(
      IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverOverlay(String title, String message, Color color) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                game.resetGame();
              },
              child: const Text('Play Again', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
