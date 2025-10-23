import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/singularity_game.dart';
import 'game/ui/game_hud.dart';
import 'game/ui/build_palette.dart';

void main() {
  runApp(const SingularityApp());
}

class SingularityApp extends StatelessWidget {
  const SingularityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Singularity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SingularityGame game;

  @override
  void initState() {
    super.initState();
    game = SingularityGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game canvas (bottom layer)
          GameWidget(game: game),
          // HUD overlay (allows tap-through except on buttons)
          Positioned.fill(
            child: GameHUD(game: game),
          ),
          // Build palette overlay
          Positioned.fill(
            child: BuildPalette(game: game),
          ),
        ],
      ),
    );
  }
}
