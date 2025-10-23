import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../singularity_game.dart';

/// Background component with green field and perlin noise
class BackgroundComponent extends PositionComponent
    with HasGameRef<SingularityGame> {
  late List<List<double>> noiseGrid;
  late int gridWidth;
  late int gridHeight;
  final double cellSize = 32.0; // Size of each grid cell

  BackgroundComponent() : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    // Get the game viewport size
    final viewportSize = gameRef.camera.viewport.size;

    // Calculate grid dimensions to fill the screen (with extra padding for any viewport)
    gridWidth = ((viewportSize.x / cellSize) * 2).ceil();
    gridHeight = ((viewportSize.y / cellSize) * 2).ceil();

    // Position at top-left of the visible area (centered around origin)
    position = Vector2(-viewportSize.x, -viewportSize.y);
    size = Vector2(gridWidth * cellSize, gridHeight * cellSize);

    // Generate perlin-like noise
    noiseGrid = _generateNoiseGrid();
  }

  List<List<double>> _generateNoiseGrid() {
    final random = Random(42); // Fixed seed for consistent background
    final grid = List.generate(
      gridHeight,
      (y) => List.generate(gridWidth, (x) => random.nextDouble()),
    );

    // Smooth the noise using simple averaging
    final smoothed = List.generate(
      gridHeight,
      (y) => List.generate(gridWidth, (x) => 0.0),
    );

    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        double sum = 0;
        int count = 0;

        // Average with neighbors
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final ny = y + dy;
            final nx = x + dx;
            if (ny >= 0 && ny < gridHeight && nx >= 0 && nx < gridWidth) {
              sum += grid[ny][nx];
              count++;
            }
          }
        }

        smoothed[y][x] = sum / count;
      }
    }

    return smoothed;
  }

  @override
  void render(Canvas canvas) {
    // Draw the green field with noise variation
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final noise = noiseGrid[y][x];

        // Create green shades based on noise
        // Base green: 0x1a4d2e (darker green)
        // Light green: 0x2d6a3e (lighter green)
        final baseGreen = 0x1a;
        final lightGreen = 0x2d;
        final greenValue =
            (baseGreen + (lightGreen - baseGreen) * noise).toInt();

        final color = Color.fromARGB(
          255,
          (greenValue * 0.5).toInt(), // Red component (darker)
          greenValue + 50, // Green component
          (greenValue * 0.8).toInt(), // Blue component (darker)
        );

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final rect = Rect.fromLTWH(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize,
        );

        canvas.drawRect(rect, paint);
      }
    }

    // Add some subtle grid lines for texture
    final gridPaint = Paint()
      ..color = const Color(0xFF0f3820).withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int x = 0; x <= gridWidth; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, size.y),
        gridPaint,
      );
    }

    for (int y = 0; y <= gridHeight; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(size.x, y * cellSize),
        gridPaint,
      );
    }
  }
}
