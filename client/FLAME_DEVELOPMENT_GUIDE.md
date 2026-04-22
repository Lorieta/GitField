# GitField - Flame Game Development Guide (Client-Side)

A comprehensive guide for building a farming game using the Flame game engine in Flutter.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Getting Started](#getting-started)
3. [Flame Architecture](#flame-architecture)
4. [Core Concepts](#core-concepts)
5. [Step-by-Step Development](#step-by-step-development)
6. [Component System](#component-system)
7. [Input Handling](#input-handling)
8. [Animations](#animations)
9. [Collision Detection](#collision-detection)
10. [UI & HUD](#ui--hud)
11. [Asset Management](#asset-management)
12. [Networking (Client-Side Prep)](#networking-client-side-prep)
13. [Common Patterns](#common-patterns)
14. [Debugging & Testing](#debugging--testing)

---

## Project Overview

**GitField** is a farming simulation game built with:
- **Flutter** - UI framework
- **Flame** - 2D game engine (v1.37.0)
- **Dart** - Programming language

**Current Features:**
- Top-down 8-directional player movement
- Sprint mechanic with stamina system
- Dynamic grid-based map generation
- Collision detection

**Planned Features:**
- Farming plots (planting, watering, harvesting)
- Crop growth system
- Inventory management
- Animals & livestock
- Buildings & decoration
- Multiplayer support

---

## Getting Started

### Prerequisites

```bash
# Check Flutter installation
flutter doctor

# Flutter version 3.11.4+ required
flutter --version
```

### Project Structure

```
lib/
├── main.dart                 # Entry point - launches the game
├── game/
│   └── gitfield.dart         # Main game class - orchestrates everything
├── components/               # Game entities (Player, Land, Plots, etc.)
│   ├── player.dart
│   ├── land.dart
│   └── plot.dart
├── utils/                    # Utility functions, enums, helpers
│   └── direction.dart
├── managers/                 # Game managers (audio, state, etc.)
├── services/                 # Services (API client, local storage)
├── models/                   # Data classes (Crop, Item, PlayerData)
└── class/                    # Additional classes
```

### Running the Game

```bash
# Navigate to client directory
cd /home/john/Repo/GitField/client/gitfield

# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run                    # Auto-detect platform
flutter run -d chrome        # Web
flutter run -d android         # Android
flutter run -d ios             # iOS
flutter run -d macos           # macOS
flutter run -d linux           # Linux
flutter run -d windows         # Windows
```

---

## Flame Architecture

### Core Classes

```dart
// 1. FlameGame - The root of your game
class Gitfield extends FlameGame 
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  // Main game logic here
}

// 2. Component - Base class for all game objects
class Player extends SpriteAnimationGroupComponent<PlayerState> 
    with KeyboardHandler, HasGameReference {
  // Player logic here
}

// 3. PositionComponent - Components with position, size, angle
class Plot extends PositionComponent {
  // Plot logic here
}
```

### Game Lifecycle

```dart
class Gitfield extends FlameGame {
  
  @override
  Future<void> onLoad() async {
    // Called ONCE when game starts
    // - Load assets
    // - Initialize components
    // - Set up initial game state
  }
  
  @override
  void update(double dt) {
    // Called EVERY FRAME
    // - dt = delta time (time since last frame in seconds)
    // - Update game logic here
    super.update(dt);
  }
  
  @override
  void render(Canvas canvas) {
    // Called EVERY FRAME (after update)
    // - Custom rendering (usually not needed - components handle this)
    super.render(canvas);
  }
}
```

---

## Core Concepts

### 1. Vectors (Vector2)

Flame uses `Vector2` for 2D positions, sizes, and velocities.

```dart
import 'package:flame/components.dart';

// Creating vectors
final position = Vector2(100, 200);     // x=100, y=200
final size = Vector2.all(64);           // x=64, y=64
final velocity = Vector2(1, 0);         // Moving right

// Vector operations
final newPos = position + velocity;     // Addition
final scaled = velocity * 100;          // Multiplication (speed)
final normalized = velocity.normalized(); // Unit vector (length = 1)
final distance = position.distanceTo(otherPosition);

// Common properties
position.x = 50;                        // Set x coordinate
position.y = 100;                       // Set y coordinate
velocity.isZero();                      // Check if zero vector
```

### 2. Component Basics

```dart
class MyComponent extends PositionComponent {
  
  MyComponent() : super(
    position: Vector2(100, 100),  // Position in world
    size: Vector2(50, 50),         // Size in pixels
    anchor: Anchor.center,          // Rotation/position anchor point
  );
  
  @override
  Future<void> onLoad() async {
    // Load assets, initialize
    final image = await game.images.load('sprite.png');
    // Add child components
    add(OtherComponent());
  }
  
  @override
  void update(double dt) {
    // Update every frame
    position.x += 100 * dt;  // Move 100 pixels/second
  }
  
  @override
  void render(Canvas canvas) {
    // Custom drawing
    final paint = Paint()..color = Colors.red;
    canvas.drawRect(size.toRect(), paint);
  }
}
```

### 3. Component Tree

```dart
// Adding components to game
class Gitfield extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Method 1: Direct add
    add(Player());
    
    // Method 2: Add with priority (render order)
    add(Background()..priority = 0);
    add(Player()..priority = 10);
    add(UI()..priority = 100);  // Higher = rendered on top
    
    // Method 3: Add children to components
    final land = Land();
    land.add(Tree(position: Vector2(50, 50)));
    add(land);
  }
}

// Finding components
final player = findByType<Player>();
final plots = children.whereType<Plot>();
```

---

## Step-by-Step Development

### Step 1: Understanding the Current Player Component

**File:** `lib/components/player.dart`

The player component demonstrates several Flame patterns:

```dart
// 1. SpriteAnimationGroupComponent - Manages multiple animations
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with KeyboardHandler, HasGameReference {
      
  // 2. HasGameReference - Gives access to parent game
  // Use: game.images, game.findByType(), etc.
  
  // 3. KeyboardHandler - Receives keyboard input
  // Method: onKeyEvent() called on every key press
  
  // 4. Animation states - Different sprites for different states
  // Currently: 8 directions + idle
}
```

**Key Implementation Details:**

```dart
// Loading a sprite sheet (grid of sprites)
final image = await game.images.load('player.png');
final sheet = SpriteSheet(
  image: image,
  srcSize: Vector2(image.width / 8, image.height / 3), // 8 cols, 3 rows
);

// Creating an animation from 3 sprites in column 4
SpriteAnimation getColAnim(int col) => SpriteAnimation.spriteList([
  sheet.getSprite(0, col),  // Row 0, Column col
  sheet.getSprite(1, col),  // Row 1, Column col
  sheet.getSprite(2, col),  // Row 2, Column col
], stepTime: 0.1);  // 0.1 seconds per frame

// Assigning animations to states
animations = {
  PlayerState.down: getColAnim(4),
  PlayerState.idle: SpriteAnimation.spriteList([sheet.getSprite(0, 4)], stepTime: 0.1),
};
```

### Step 2: Creating Farm Plots

Let's implement the empty `plot.dart` file:

```dart
// lib/components/plot.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

enum PlotState {
  empty,      // No crop planted
  planted,    // Seed planted, not growing yet
  growing,    // Crop is growing
  ready,      // Crop ready to harvest
  withered,   // Crop died (optional mechanic)
}

enum CropType {
  carrot,
  tomato,
  wheat,
  corn,
  pumpkin,
}

class Plot extends PositionComponent with HasGameReference {
  PlotState state = PlotState.empty;
  CropType? cropType;
  
  // Growth tracking
  double growthProgress = 0.0;  // 0.0 to 1.0
  double growthTime = 0.0;      // Time in growing state
  final double timeToMature = 10.0; // Seconds to grow (adjust as needed)
  
  // Visuals
  late SpriteComponent soilSprite;
  SpriteComponent? cropSprite;
  
  Plot({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(48),  // 48x48 pixel plots
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load soil/empty plot sprite
    final soilImage = await game.images.load('images/Tileset/spring grass.png');
    soilSprite = SpriteComponent(
      sprite: Sprite(soilImage),
      size: size,
    );
    add(soilSprite);
    
    // Add interaction hitbox
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle crop growth
    if (state == PlotState.growing) {
      growthTime += dt;
      growthProgress = growthTime / timeToMature;
      
      if (growthProgress >= 1.0) {
        state = PlotState.ready;
        _updateCropVisual();
      } else {
        _updateCropVisual(); // Update growth stage sprite
      }
    }
  }

  /// Plant a crop in this plot
  bool plant(CropType type) {
    if (state != PlotState.empty) return false; // Already has crop
    
    cropType = type;
    state = PlotState.planted;
    growthProgress = 0.0;
    growthTime = 0.0;
    
    // Transition to growing immediately (or add a delay)
    state = PlotState.growing;
    _updateCropVisual();
    
    return true;
  }

  /// Harvest the crop
  CropType? harvest() {
    if (state != PlotState.ready) return null;
    
    final harvested = cropType;
    
    // Reset plot
    state = PlotState.empty;
    cropType = null;
    growthProgress = 0.0;
    growthTime = 0.0;
    _updateCropVisual();
    
    return harvested;
  }

  void _updateCropVisual() {
    // Remove old crop sprite
    cropSprite?.removeFromParent();
    cropSprite = null;
    
    if (cropType == null || state == PlotState.empty) return;
    
    // Determine which sprite to show based on state and growth
    String spritePath;
    if (state == PlotState.planted || state == PlotState.growing) {
      // Show growth stage based on progress
      if (growthProgress < 0.33) {
        spritePath = 'images/Plants/${cropType!.name}_stage1.png';
      } else if (growthProgress < 0.66) {
        spritePath = 'images/Plants/${cropType!.name}_stage2.png';
      } else {
        spritePath = 'images/Plants/${cropType!.name}_stage3.png';
      }
    } else {
      // Ready to harvest - full grown
      spritePath = 'images/Plants/${cropType!.name}_mature.png';
    }
    
    // Load and add sprite (handle missing assets gracefully)
    try {
      final image = game.images.fromCache(spritePath);
      cropSprite = SpriteComponent(
        sprite: Sprite(image),
        size: size,
        position: Vector2(0, -10), // Slight offset above soil
      );
      add(cropSprite!);
    } catch (e) {
      // Asset not loaded yet - you may need to preload
      print('Sprite not found: $spritePath');
    }
  }
}
```

### Step 3: Integrating Plots into the Game

```dart
// lib/game/gitfield.dart
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/land.dart';
import '../components/plot.dart';

class Gitfield extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
      
  late DynamicMap map;
  late Player player;
  final List<Plot> plots = [];
  
  @override
  Future<void> onLoad() async {
    // Load all assets first
    await _preloadAssets();
    
    // Create map
    map = DynamicMap(gridSize: 20);  // Larger map
    add(map);
    
    // Create plots in the center area
    _createFarmPlots();
    
    // Spawn player
    final spawn = Vector2.all(
      map.gridSize * map.tileSize * map.renderScale / 2,
    );
    player = Player(position: spawn, map: map);
    add(player);
    
    // Set camera to follow player (optional but recommended)
    camera.follow(player);
  }
  
  Future<void> _preloadAssets() async {
    // Preload images to avoid loading during gameplay
    await images.loadAll([
      'player.png',
      'tiles.png',
      // Add crop sprites here
      'images/Plants/carrot_stage1.png',
      'images/Plants/carrot_stage2.png',
      'images/Plants/carrot_stage3.png',
      'images/Plants/carrot_mature.png',
    ]);
  }
  
  void _createFarmPlots() {
    // Create a 5x5 grid of farm plots in the center
    final plotSpacing = 48.0 * 3.0; // size * scale
    final startX = (map.gridSize * map.tileSize * map.renderScale) / 2 
                   - (2 * plotSpacing);
    final startY = (map.gridSize * map.tileSize * map.renderScale) / 2 
                   - (2 * plotSpacing);
    
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final plot = Plot(
          position: Vector2(
            startX + col * plotSpacing,
            startY + row * plotSpacing,
          ),
        );
        plots.add(plot);
        add(plot);
      }
    }
  }
  
  @override
  Color backgroundColor() => Colors.blue;
}
```

### Step 4: Adding Player-Plot Interaction

Update the player to interact with plots when pressing space:

```dart
// Add to lib/components/player.dart

import 'package:flame/collisions.dart';
import 'plot.dart';

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with KeyboardHandler, HasGameReference, CollisionCallbacks {
  
  // ... existing code ...
  
  // Track nearby plots
  Plot? nearbyPlot;
  
  // Inventory (simple example)
  Map<CropType, int> inventory = {};
  CropType? selectedSeed = CropType.carrot;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // ... existing code ...
    
    // Add hitbox for interaction detection
    add(RectangleHitbox(
      size: Vector2.all(32),
      anchor: Anchor.center,
    )..collisionType = CollisionType.passive);
  }
  
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // ... existing movement code ...
    
    // Plant/Harvest with Space key
    if (event is KeyDownEvent && 
        event.logicalKey == LogicalKeyboardKey.space) {
      _interactWithPlot();
    }
    
    return true;
  }
  
  void _interactWithPlot() {
    if (nearbyPlot == null) return;
    
    switch (nearbyPlot!.state) {
      case PlotState.empty:
        // Plant a seed
        if (selectedSeed != null) {
          if (nearbyPlot!.plant(selectedSeed!)) {
            print('Planted ${selectedSeed!.name}');
          }
        }
        break;
        
      case PlotState.ready:
        // Harvest
        final harvested = nearbyPlot!.harvest();
        if (harvested != null) {
          inventory[harvested] = (inventory[harvested] ?? 0) + 1;
          print('Harvested ${harvested.name}! Inventory: $inventory');
        }
        break;
        
      case PlotState.planted:
      case PlotState.growing:
      case PlotState.withered:
        // Could add watering mechanics here
        print('Crop is still growing...');
        break;
    }
  }
  
  // Detect when near a plot
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Plot) {
      nearbyPlot = other;
    }
  }
  
  @override
  void onCollisionEnd(PositionComponent other) {
    if (other == nearbyPlot) {
      nearbyPlot = null;
    }
  }
}
```

---

## Component System

### Component Types Reference

```dart
// POSITION COMPONENTS (have position, size, rotation)
PositionComponent          // Base class
SpriteComponent           // Single sprite
SpriteAnimationComponent  // Animated sprite
SpriteGroupComponent      // Multiple sprites
SpriteAnimationGroupComponent<T>  // Animated with states
TextComponent             // Render text
RectangleComponent        // Simple rectangle
CircleComponent           // Simple circle
PolygonComponent          // Custom shape

// OTHER COMPONENTS
ParallaxComponent         // Scrolling backgrounds
ParticleSystemComponent   // Particle effects
JoystickComponent         // Mobile joystick
ButtonComponent           // Touchable button

// CUSTOM COMPONENT TEMPLATE
class MyComponent extends PositionComponent with 
    HasGameReference,
    CollisionCallbacks {
  // Your implementation
}
```

### Component Mixins

```dart
// HasGameReference - Access to parent game
class MyComp extends Component with HasGameReference {
  void someMethod() {
    game.findByType<Player>();  // Find other components
    game.images.load('...');    // Access asset cache
    game.camera;                // Access camera
  }
}

// CollisionCallbacks - Handle collisions
class MyComp extends PositionComponent with CollisionCallbacks {
  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {}
  
  @override
  void onCollisionEnd(PositionComponent other) {}
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}
}

// Tappable / Dragable - Touch input
class MyComp extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {}
  
  @override
  void onTapUp(TapUpEvent event) {}
  
  @override
  void onTapCancel(TapCancelEvent event) {}
}

// Hoverable - Mouse hover
class MyComp extends PositionComponent with HoverCallbacks {
  @override
  void onHoverEnter() {}
  
  @override
  void onHoverLeave() {}
}
```

---

## Input Handling

### Keyboard Input

```dart
// Method 1: Component-level (current implementation)
class Player extends Component with KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // keysPressed contains ALL currently held keys
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      // Move up
    }
    if (event is KeyDownEvent) {
      // Handle single key press
    }
    return true; // Event handled
  }
}

// Method 2: Game-level
class Gitfield extends FlameGame with HasKeyboardHandlerComponents {
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keys) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Open menu
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

// Common keyboard keys
LogicalKeyboardKey.keyA       // A key
LogicalKeyboardKey.keyB       // B key
LogicalKeyboardKey.digit1     // 1 key
LogicalKeyboardKey.space      // Space
LogicalKeyboardKey.enter      // Enter
LogicalKeyboardKey.escape     // Escape
LogicalKeyboardKey.shiftLeft  // Left Shift
LogicalKeyboardKey.controlLeft // Left Ctrl
LogicalKeyboardKey.arrowUp    // Arrow keys
```

### Touch/Mouse Input

```dart
class MyComponent extends PositionComponent with TapCallbacks, DragCallbacks {
  
  // Single tap
  @override
  void onTapDown(TapDownEvent event) {
    print('Tapped at: ${event.localPosition}');
  }
  
  // Dragging
  @override
  void onDragStart(DragStartEvent event) {}
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;  // Move with drag
  }
  
  @override
  void onDragEnd(DragEndEvent event) {}
}

// Global gesture detection
class Gitfield extends FlameGame with PanDetector {
  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Handle pan gesture
  }
}
```

---

## Animations

### Sprite Animation

```dart
// From sprite sheet (like current player)
final image = await game.images.load('sheet.png');
final sheet = SpriteSheet(
  image: image,
  srcSize: Vector2(32, 32),  // Each frame is 32x32
);

final animation = SpriteAnimation.fromFrameData(
  image,
  SpriteAnimationData.sequenced(
    amount: 8,           // 8 frames
    stepTime: 0.1,       // 0.1s per frame
    textureSize: Vector2(32, 32),
    loop: true,
  ),
);

// Using the animation
final animComponent = SpriteAnimationComponent(
  animation: animation,
  position: Vector2(100, 100),
  size: Vector2(64, 64),
);
```

### Animation States

```dart
enum CropState { seedling, growing, mature }

class Crop extends SpriteAnimationGroupComponent<CropState> {
  @override
  Future<void> onLoad() async {
    animations = {
      CropState.seedling: await _loadAnimation('seedling.png', 4),
      CropState.growing: await _loadAnimation('growing.png', 4),
      CropState.mature: await _loadAnimation('mature.png', 1),
    };
    current = CropState.seedling;
  }
  
  void grow() {
    current = CropState.growing;
  }
}
```

### Tween Animations

```dart
import 'package:flame/effects.dart';

// Move with animation
player.add(MoveEffect.to(
  Vector2(100, 100),
  EffectController(duration: 1.0, curve: Curves.easeInOut),
));

// Scale animation
component.add(ScaleEffect.to(
  Vector2.all(1.5),
  EffectController(duration: 0.5),
));

// Rotate
component.add(RotateEffect.by(
  tau,  // One full rotation (from math package)
  EffectController(duration: 2.0),
));

// Sequence of effects
component.add(SequenceEffect([
  MoveEffect.by(Vector2(0, -20), EffectController(duration: 0.2)),
  MoveEffect.by(Vector2(0, 20), EffectController(duration: 0.2)),
]));
```

---

## Collision Detection

### Setup

```dart
// Enable collision detection in game
class Gitfield extends FlameGame with HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    // Collision detection is now active
  }
}
```

### Adding Hitboxes

```dart
class Player extends PositionComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    // Rectangle hitbox (default: fills entire component)
    add(RectangleHitbox());
    
    // Custom size hitbox
    add(RectangleHitbox(
      size: Vector2(32, 48),
      position: Vector2(16, 8), // Offset from component origin
    ));
    
    // Circle hitbox
    add(CircleHitbox(radius: 20));
    
    // Polygon hitbox
    add(PolygonHitbox([
      Vector2(0, 0),
      Vector2(50, 0),
      Vector2(25, 50),
    ]));
  }
}
```

### Collision Types

```dart
// Define collision behavior
enum GameObjectType { player, enemy, plot, item }

class Player extends PositionComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.active);
    // Types: active, passive, inactive
    // active - can collide with everything
    // passive - receives collisions but doesn't cause them
    // inactive - no collision detection
  }
}
```

### Handling Collisions

```dart
class Player extends PositionComponent with CollisionCallbacks {
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Plot) {
      // Player entered plot area
      nearbyPlot = other;
    } else if (other is Enemy) {
      // Take damage
      health -= 10;
    }
  }
  
  @override
  void onCollisionEnd(PositionComponent other) {
    if (other == nearbyPlot) {
      nearbyPlot = null;
    }
  }
  
  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // Called every frame while colliding
    // Use for continuous collision effects
  }
}
```

---

## UI & HUD

### OverlayBuilderWidget

```dart
// main.dart - Wrap GameWidget with UI
void main() {
  final game = Gitfield();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            GameUI(game: game),  // Your Flutter UI overlay
          ],
        ),
      ),
    ),
  );
}

// Flutter UI overlay
class GameUI extends StatelessWidget {
  final Gitfield game;
  
  const GameUI({required this.game});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar - Resources
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _resourceIcon(Icons.eco, 'Seeds: 10'),
                _resourceIcon(Icons.grass, 'Crops: 5'),
                _resourceIcon(Icons.attach_money, 'Money: 100'),
              ],
            ),
          ),
          Spacer(),
          // Bottom bar - Tools
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolButton(Icons.handshake, 'Harvest', () {}),
                _toolButton(Icons.water, 'Water', () {}),
                _toolButton(Icons.local_florist, 'Plant', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _resourceIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white)),
      ],
    );
  }
  
  Widget _toolButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
```

### Flame UI Components

```dart
// In-game UI using Flame components
class HUD extends PositionComponent with HasGameReference {
  late TextComponent moneyText;
  late TextComponent staminaText;
  
  @override
  Future<void> onLoad() async {
    position = Vector2(10, 10);
    
    moneyText = TextComponent(
      text: 'Money: 100',
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      position: Vector2(0, 0),
    );
    add(moneyText);
    
    staminaText = TextComponent(
      text: 'Stamina: 100',
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.green, fontSize: 20),
      ),
      position: Vector2(0, 30),
    );
    add(staminaText);
  }
  
  void updateMoney(int amount) {
    moneyText.text = 'Money: $amount';
  }
  
  void updateStamina(double stamina) {
    staminaText.text = 'Stamina: ${stamina.toInt()}';
    staminaText.textRenderer = TextPaint(
      style: TextStyle(
        color: stamina > 30 ? Colors.green : Colors.red,
        fontSize: 20,
      ),
    );
  }
}
```

---

## Asset Management

### Asset Structure

```
assets/
├── images/
│   ├── Character/
│   │   ├── Idle.png
│   │   └── Walk.png
│   ├── Farm Animals/
│   │   ├── Chicken/
│   │   ├── Cow/
│   │   └── Pig/
│   ├── Objects/
│   │   ├── Chests/
│   │   ├── Fence/
│   │   └── House/
│   ├── Tileset/
│   │   ├── Spring/
│   │   ├── Winter/
│   │   └── Birch.png
│   ├── Plants/
│   │   ├── carrot_stage1.png
│   │   ├── carrot_stage2.png
│   │   ├── carrot_stage3.png
│   │   └── carrot_mature.png
│   └── UI/
│       ├── inventory_bg.png
│       └── button.png
└── audio/
    ├── bgm/
    │   ├── farm_theme.mp3
    │   └── night_theme.mp3
    └── sfx/
        ├── plant.wav
        ├── harvest.wav
        └── water.wav
```

### pubspec.yaml Configuration

```yaml
flutter:
  uses-material-design: true
  assets:
    # Directories (includes all subdirectories)
    - assets/images/
    - assets/audio/
    
    # Or specify individual files
    - assets/images/player.png
    - assets/audio/sfx/plant.wav

  # Fonts
  fonts:
    - family: PixelFont
      fonts:
        - asset: assets/fonts/pixel.ttf
```

### Loading Assets

```dart
class Gitfield extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Method 1: Load single image
    final playerImage = await images.load('player.png');
    
    // Method 2: Load multiple at once
    await images.loadAll([
      'player.png',
      'tiles.png',
      'crops/carrot.png',
      'crops/wheat.png',
    ]);
    
    // Method 3: Load from cache (must be preloaded)
    final cached = images.fromCache('player.png');
    
    // Audio (requires flame_audio package)
    // await FlameAudio.audioCache.load('sfx/plant.wav');
    // FlameAudio.play('sfx/plant.wav');
  }
}
```

---

## Networking (Client-Side Prep)

### Structure for Future Server Integration

```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'http://your-server.com/api';
  
  // Future: Save game state
  Future<void> saveGameState(GameState state) async {
    // POST /api/save
  }
  
  // Future: Load game state
  Future<GameState> loadGameState(String playerId) async {
    // GET /api/load/$playerId
    return GameState();
  }
  
  // Future: Sync crop growth
  Future<void> syncCrops(String playerId) async {
    // GET /api/crops/$playerId
  }
  
  // Future: Plant crop on server
  Future<bool> serverPlant(String playerId, int plotIndex, CropType type) async {
    // POST /api/plant
    return true;
  }
  
  // Future: Harvest on server
  Future<CropType?> serverHarvest(String playerId, int plotIndex) async {
    // POST /api/harvest
    return CropType.carrot;
  }
}

// lib/models/game_state.dart
class GameState {
  final String playerId;
  final int money;
  final Map<String, int> inventory;
  final List<PlotStateData> plots;
  final DateTime lastSync;
  
  GameState({
    required this.playerId,
    this.money = 0,
    this.inventory = const {},
    this.plots = const [],
    required this.lastSync,
  });
  
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      playerId: json['playerId'],
      money: json['money'],
      inventory: Map<String, int>.from(json['inventory']),
      plots: (json['plots'] as List).map((p) => PlotStateData.fromJson(p)).toList(),
      lastSync: DateTime.parse(json['lastSync']),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'money': money,
    'inventory': inventory,
    'plots': plots.map((p) => p.toJson()).toList(),
    'lastSync': lastSync.toIso8601String(),
  };
}

class PlotStateData {
  final int index;
  final String state;
  final String? cropType;
  final double growthProgress;
  
  PlotStateData({
    required this.index,
    required this.state,
    this.cropType,
    required this.growthProgress,
  });
  
  factory PlotStateData.fromJson(Map<String, dynamic> json) => PlotStateData(
    index: json['index'],
    state: json['state'],
    cropType: json['cropType'],
    growthProgress: json['growthProgress'],
  );
  
  Map<String, dynamic> toJson() => {
    'index': index,
    'state': state,
    'cropType': cropType,
    'growthProgress': growthProgress,
  };
}
```

---

## Common Patterns

### Game Loop Pattern

```dart
class Gitfield extends FlameGame {
  // Systems
  late TimeSystem timeSystem;
  late WeatherSystem weatherSystem;
  late EconomySystem economySystem;
  
  @override
  Future<void> onLoad() async {
    // Initialize all systems
    timeSystem = TimeSystem();
    weatherSystem = WeatherSystem();
    economySystem = EconomySystem();
    
    // Add to game for update loop
    add(timeSystem);
    add(weatherSystem);
    add(economySystem);
  }
}

class TimeSystem extends Component {
  double gameTime = 0;
  int day = 1;
  double timeOfDay = 6; // 6 AM
  
  @override
  void update(double dt) {
    gameTime += dt;
    timeOfDay += dt / 60; // 1 real sec = 1 game minute
    
    if (timeOfDay >= 24) {
      timeOfDay = 0;
      day++;
      onNewDay();
    }
  }
  
  void onNewDay() {
    // Trigger daily events
  }
}
```

### Object Pooling

```dart
class CropParticlePool extends Component {
  final List<CropParticle> _available = [];
  final List<CropParticle> _inUse = [];
  
  CropParticle acquire() {
    if (_available.isEmpty) {
      final particle = CropParticle();
      _inUse.add(particle);
      return particle;
    }
    final particle = _available.removeLast();
    _inUse.add(particle);
    return particle;
  }
  
  void release(CropParticle particle) {
    _inUse.remove(particle);
    _available.add(particle);
    particle.reset();
  }
}
```

### State Machine

```dart
class Crop extends PositionComponent {
  late StateMachine<CropState> _stateMachine;
  
  @override
  Future<void> onLoad() async {
    _stateMachine = StateMachine<CropState>(
      initialState: CropState.seed,
      states: {
        CropState.seed: SeedState(this),
        CropState.growing: GrowingState(this),
        CropState.mature: MatureState(this),
      },
    );
  }
  
  @override
  void update(double dt) {
    _stateMachine.update(dt);
  }
  
  void transitionTo(CropState state) {
    _stateMachine.transitionTo(state);
  }
}

abstract class State<T> {
  T owner;
  State(this.owner);
  void enter() {}
  void update(double dt) {}
  void exit() {}
}

class GrowingState extends State<Crop> {
  GrowingState(Crop owner) : super(owner);
  
  @override
  void update(double dt) {
    owner.growthProgress += dt;
    if (owner.growthProgress >= owner.timeToMature) {
      owner.transitionTo(CropState.mature);
    }
  }
}
```

---

## Debugging & Testing

### Debug Features

```dart
class Gitfield extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Show hitboxes (collision areas)
    debugMode = true;  // Shows component outlines
    
    // Add FPS counter
    add(FpsTextComponent(position: Vector2(10, 10)));
    
    // Add debug info panel
    add(DebugInfo());
  }
}

// Custom debug component
class DebugInfo extends TextComponent with HasGameReference {
  @override
  Future<void> onLoad() async {
    position = Vector2(10, 40);
    textRenderer = TextPaint(
      style: TextStyle(color: Colors.white, fontSize: 14),
    );
  }
  
  @override
  void update(double dt) {
    text = '''
      FPS: ${(1 / dt).toStringAsFixed(1)}
      Entities: ${game.children.length}
      Player: ${game.findByType<Player>().position}
    ''';
  }
}
```

### Testing Components

```dart
// test/player_test.dart
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitfield/components/player.dart';

void main() {
  final flameTester = FlameTester(() => Gitfield());
  
  group('Player', () {
    flameTester.test('moves on key press', (game) async {
      final player = Player(position: Vector2.zero(), map: mockMap);
      await game.ensureAdd(player);
      
      // Simulate key press
      player.onKeyEvent(
        KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyD,
          logicalKey: LogicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyD},
      );
      
      // Update for 1 second
      game.update(1.0);
      
      // Should have moved right
      expect(player.position.x, greaterThan(0));
    });
    
    flameTester.test('sprinting consumes stamina', (game) async {
      final player = Player(position: Vector2.zero(), map: mockMap);
      await game.ensureAdd(player);
      
      final initialStamina = player.stamina;
      
      // Start sprinting
      player.isSprinting = true;
      game.update(1.0);
      
      expect(player.stamina, lessThan(initialStamina));
    });
  });
}
```

### Performance Tips

```dart
// 1. Use SpriteBatch for many static sprites
final batch = SpriteBatch(image);
for (final tile in tiles) {
  batch.add(source: tile.src, offset: tile.position);
}
add(SpriteBatchComponent(spriteBatch: batch));

// 2. Remove off-screen components
@override
void update(double dt) {
  super.update(dt);
  
  final cameraRect = game.camera.visibleWorldRect;
  if (!cameraRect.overlaps(toRect())) {
    // Component is off-screen
    // Either remove or reduce update frequency
  }
}

// 3. Use collision type wisely
add(RectangleHitbox()..collisionType = CollisionType.passive);
// passive = check collisions but don't cause them (good for items, plots)
// active = full collision detection (player, enemies)
// inactive = no collision detection

// 4. Preload assets
Future<void> onLoad() async {
  await images.loadAll([
    'player.png',
    'tiles.png',
    // Load all needed assets upfront
  ]);
}
```

---

## Quick Reference

### Common Flame Classes

| Class | Purpose |
|-------|---------|
| `FlameGame` | Main game class |
| `PositionComponent` | Base for positioned objects |
| `SpriteComponent` | Static sprite |
| `SpriteAnimationComponent` | Animated sprite |
| `TextComponent` | Text rendering |
| `RectangleHitbox` | Rectangular collision |
| `CircleHitbox` | Circular collision |
| `Vector2` | 2D vector (position, size, etc.) |
| `SpriteSheet` | Grid-based sprite animation |

### Common Methods

```dart
// Game
add(Component)              // Add component to game
remove(Component)           // Remove component
findByType<T>()             // Find first component of type
camera.follow(component)    // Camera follows component

// Component
onLoad()                    // Called when added to game
update(dt)                  // Called every frame
render(canvas)              // Called every frame (custom drawing)
removeFromParent()          // Remove self from parent

// PositionComponent
position = Vector2(x, y)    // Set position
angle = 3.14                // Set rotation (radians)
scale = Vector2(2, 2)       // Set scale
```

---

## Additional Resources

- **Flame Documentation**: https://docs.flame-engine.org/
- **Flame Examples**: https://github.com/flame-engine/flame/tree/main/examples
- **Flutter Cookbook**: https://docs.flutter.dev/cookbook
- **Dart Language**: https://dart.dev/guides

---

## Next Steps Checklist

- [ ] Implement Plot component with crop planting
- [ ] Add inventory system
- [ ] Create farming tools (hoe, watering can, seeds)
- [ ] Implement crop growth over time
- [ ] Add day/night cycle
- [ ] Create shop/trading system
- [ ] Add animal husbandry (chickens, cows)
- [ ] Implement buildings and decoration
- [ ] Add save/load functionality
- [ ] Connect to server API
- [ ] Add multiplayer features

---

*Happy Farming with Flame! 🚜🌾*
