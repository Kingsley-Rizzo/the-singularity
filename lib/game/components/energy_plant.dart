import 'dart:ui';
import 'structure.dart';

class EnergyPlant extends StructureComponent {
  EnergyPlant() : super('energy_plant');

  @override
  Color getStructureColor() {
    return const Color(0xFFFFFF00); // Yellow
  }
}
