import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/resource_manager.dart';
import '../managers/build_manager.dart';
import '../singularity_game.dart';
import '../config/config_loader.dart';

class BuildPalette extends StatelessWidget {
  final SingularityGame game;

  const BuildPalette({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.resourceManager,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.black.withOpacity(0.7),
          child: Consumer<ResourceManager>(
            builder: (context, resources, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStructureButton(
                    context,
                    resources,
                    'Server Farm',
                    Icons.computer,
                    Colors.green,
                    PlacementMode.serverFarm,
                    'server_farm',
                  ),
                  _buildStructureButton(
                    context,
                    resources,
                    'Energy Plant',
                    Icons.power,
                    Colors.yellow,
                    PlacementMode.energyPlant,
                    'energy_plant',
                  ),
                  _buildStructureButton(
                    context,
                    resources,
                    'Turret',
                    Icons.adjust,
                    Colors.red,
                    PlacementMode.turret,
                    'turret',
                  ),
                  if (game.buildManager.currentMode != PlacementMode.none)
                    _buildCancelButton(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStructureButton(
    BuildContext context,
    ResourceManager resources,
    String name,
    IconData icon,
    Color color,
    PlacementMode mode,
    String configKey,
  ) {
    final config = ConfigLoader.balance.structures[configKey]!;
    final cost = config.cost;
    final reserve = config.energyReserve;
    final canAfford = resources.canAfford(cost);
    final isSelected = game.buildManager.currentMode == mode;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : color.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: canAfford ? Colors.white : Colors.red,
                width: 2,
              ),
            ),
          ),
          onPressed: canAfford
              ? () {
                  game.buildManager.currentMode = mode;
                }
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                '\$$cost',
                style: TextStyle(
                  color: canAfford ? Colors.white : Colors.red,
                  fontSize: 12,
                ),
              ),
              Text(
                '⚡$reserve',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            game.buildManager.currentMode = PlacementMode.none;
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 24),
              SizedBox(height: 4),
              Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
