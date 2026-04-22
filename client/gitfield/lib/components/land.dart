import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class DynamicMap extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  final int gridSize;
  final double tileSize = 16.0;
  final double renderScale = 3.0;

  DynamicMap({required this.gridSize});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = await game.images.load('tiles.png');

    // 1. Create a SpriteBatch for better performance
    final batch = SpriteBatch(image);

    // 2. Map the grid logic
    // We still need to iterate, but we are "mapping" into a batch list
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        // Find the source rect in the tileset (x, y, width, height)
        final src = _getSourceRect(x, y, gridSize);

        // Map it to the destination position in the game world
        batch.add(source: src, offset: Vector2(x * tileSize, y * tileSize));
      }
    }

    // 3. Add the final "stamped" map as a single component
    add(SpriteBatchComponent(spriteBatch: batch));

    size = Vector2.all(gridSize * tileSize);
    const wallThickness = 1.0;
    add(
      RectangleHitbox(
        position: Vector2(0, 0),
        size: Vector2(size.x, wallThickness),
      ),
    );
    add(
      RectangleHitbox(
        position: Vector2(0, size.y - wallThickness),
        size: Vector2(size.x, wallThickness),
      ),
    );
    add(
      RectangleHitbox(
        position: Vector2(0, 0),
        size: Vector2(wallThickness, size.y),
      ),
    );
    add(
      RectangleHitbox(
        position: Vector2(size.x - wallThickness, 0),
        size: Vector2(wallThickness, size.y),
      ),
    );
    scale = Vector2.all(renderScale);
  }

  // This maps the Grid Position -> Tileset Coordinates
  Rect _getSourceRect(int x, int y, int max) {
    double row, col;

    // 3x3 tiles: row 0=top, 1=middle, 2=bottom; col 0=left, 1=middle, 2=right.
    row = (y == 0)
        ? 0
        : (y == max - 1)
        ? 2
        : 1;
    col = (x == 0)
        ? 0
        : (x == max - 1)
        ? 2
        : 1;

    return Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);
  }
}
