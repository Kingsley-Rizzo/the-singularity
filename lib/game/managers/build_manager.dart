import 'package:flame/components.dart';
import '../config/config_loader.dart';
import '../components/structure.dart';

enum PlacementMode {
  none,
  serverFarm,
  energyPlant,
  turret,
}

class BuildManager {
  PlacementMode currentMode = PlacementMode.none;
  final double gridSize = 32.0;
  final List<StructureComponent> structures = [];

  Vector2? snapToGrid(Vector2 position) {
    final snappedX = (position.x / gridSize).round() * gridSize;
    final snappedY = (position.y / gridSize).round() * gridSize;
    return Vector2(snappedX.toDouble(), snappedY.toDouble());
  }

  bool canPlaceAt(Vector2 position, double structSize) {
    // Check distance from center (arena bounds)
    if (position.length > 380) {
      return false;
    }

    // Check overlap with existing structures
    for (final structure in structures) {
      final distance = (structure.position - position).length;
      if (distance < structSize + structure.structureSize / 2) {
        return false;
      }
    }

    return true;
  }

  int getCost(PlacementMode mode) {
    final config = ConfigLoader.balance.structures;
    switch (mode) {
      case PlacementMode.serverFarm:
        return config['server_farm']!.cost;
      case PlacementMode.energyPlant:
        return config['energy_plant']!.cost;
      case PlacementMode.turret:
        return config['turret']!.cost;
      case PlacementMode.none:
        return 0;
    }
  }

  String getStructureType(PlacementMode mode) {
    switch (mode) {
      case PlacementMode.serverFarm:
        return 'server_farm';
      case PlacementMode.energyPlant:
        return 'energy_plant';
      case PlacementMode.turret:
        return 'turret';
      case PlacementMode.none:
        return '';
    }
  }

  void registerStructure(StructureComponent structure) {
    structures.add(structure);
  }

  void unregisterStructure(StructureComponent structure) {
    structures.remove(structure);
  }

  List<StructureComponent> getStructuresOfType(String type) {
    return structures.where((s) => s.structureType == type).toList();
  }

  void reset() {
    currentMode = PlacementMode.none;
    structures.clear();
  }
}
