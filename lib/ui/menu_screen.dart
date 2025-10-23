import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatelessWidget {
  final VoidCallback onStartGame;

  const MenuScreen({Key? key, required this.onStartGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0a0a15),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Title with robotic font
              Text(
                'THE SINGULARITY',
                style: GoogleFonts.orbitron(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FFFF),
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 20,
                    ),
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'DEFEND THE AI',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF00FF00),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 80),
              // Start Button
              ElevatedButton(
                onPressed: onStartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFFF),
                  foregroundColor: const Color(0xFF0a0a15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'START MISSION',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Instructions
              Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION BRIEFING',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00FFFF),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInstruction('• Build SERVER FARMS to increase AGI'),
                    _buildInstruction(
                        '• Construct ENERGY PLANTS to power your base'),
                    _buildInstruction(
                        '• Deploy TURRETS to defend against intruders'),
                    _buildInstruction('• Protect the AGI HUB at all costs'),
                    _buildInstruction(
                        '• Reach 100% AGI to achieve singularity'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 14,
          color: const Color(0xFF00FF00),
          height: 1.5,
        ),
      ),
    );
  }
}
