# The Singularity

A top-down tower defense game built with Flutter and Flame where you protect an AGI Hub from waves of attackers while building up your economy.

## Overview

- **Objective**: Grow your AGI to 100% while defending it from enemies
- **Core Loop**: Build structures → Generate resources → Survive waves → Win
- **Win Condition**: AGI reaches 100%
- **Loss Condition**: AGI drops to 0%

## How to Play

### Resources
- **Money ($)**: Used to build structures
- **Energy (⚡)**: Powers your structures and turrets
- **AGI (%)**: Your progress toward victory (increases passively each tick)

### Structures
1. **Server Farm** (Green Square)
   - Cost: $100
   - Upkeep: 10 Energy/tick
   - Production: +10 Money/tick
   - Targeted by Hackers

2. **Energy Plant** (Yellow Square)
   - Cost: $75
   - Upkeep: 0 Energy/tick
   - Production: +8 Energy/tick
   - Targeted by Saboteurs

3. **Defense Turret** (Red Square)
   - Cost: $50
   - Upkeep: 5 Energy/tick
   - Auto-targets and shoots nearby enemies

### Enemies
- **Hacker** (Magenta Triangle): Targets Server Farms
- **Saboteur** (Orange Triangle): Targets Energy Plants
- **Philosopher** (Purple Diamond): Targets AGI Hub directly

### Gameplay Tips
1. Start by building 1-2 Server Farms for money generation
2. Build Energy Plants to power your structures
3. Place Turrets strategically to defend your economy
4. Waves spawn every 20 seconds from the edges
5. Keep Energy positive - negative energy causes brownouts!
6. AGI grows passively when powered, bonus on wave clear

## Running the Game

### Web
```bash
flutter run -d chrome
# or
flutter run -d web-server --web-port=8080
```

### Desktop (Windows/Mac/Linux)
```bash
flutter run -d windows
# or -d macos, -d linux
```

### Mobile
```bash
flutter run -d android
# or -d ios
```

### Build for Production
```bash
# Web
flutter build web

# Android
flutter build apk

# iOS (requires Mac)
flutter build ios
```

## Controls

### Mouse/Touch
- Click on a structure button to enter placement mode
- Click on the game board to place the structure
- Click "Cancel" to exit placement mode
- Pause button in top-right corner

### Keyboard (coming soon)
- `1`, `2`, `3`: Quick-select structures
- `P`: Pause
- `Esc`: Cancel placement

## Development

### Project Structure
```
lib/
  main.dart                 # App entry point
  game/
    singularity_game.dart   # Main game class
    config/                 # JSON config loaders
    managers/               # Resource, Wave, Build managers
    components/             # Game entities (Hub, Structures, Enemies)
    ui/                     # HUD and Build Palette
assets/
  config/
    balance.json            # Game balance configuration
    waves.json              # Wave spawn configuration
```

### Modifying Game Balance
Edit `assets/config/balance.json` to adjust:
- Structure costs and production rates
- Enemy HP, speed, and damage
- Tick rate and AGI progression
- Starting resources

Edit `assets/config/waves.json` to adjust:
- Wave timing and composition
- Enemy scaling over time

### Regenerating JSON Serialization
After modifying config models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Roadmap / Future Features
- Structure upgrades
- Multiple difficulty modes
- Save/load system
- More enemy types and boss waves
- Power-ups and special abilities
- Sound effects and music
- Better graphics/sprites
- Pathfinding and obstacles

## License
Created as a game development project.

