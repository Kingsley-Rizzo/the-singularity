import 'dart:ui';
import 'structure.dart';

class ServerFarm extends StructureComponent {
  ServerFarm() : super('server_farm');

  @override
  Color getStructureColor() {
    return const Color(0xFF00FF00); // Green
  }
}
