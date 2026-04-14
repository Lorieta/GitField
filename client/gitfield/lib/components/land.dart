import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class DynamicMap extends PositionComponent with HasGameReference {
  final int gridSize;
  final double tileSize = 16.0;
  final double renderScale = 3.0;

  DynamicMap({required this.gridSize});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = await game.images.load('tiles.png');
    final batch = SpriteBatch(image);

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        batch.add(
          source: _getSourceRect(x, y, gridSize),
          offset: Vector2(x * tileSize, y * tileSize),
        );
      }
    }

    add(SpriteBatchComponent(spriteBatch: batch));
    size = Vector2.all(gridSize * tileSize);
    scale = Vector2.all(renderScale);
  }

  Rect _getSourceRect(int x, int y, int max) {
    final col = x == 0
        ? 0.0
        : x == max - 1
        ? 2.0
        : 1.0;
    final row = y == 0
        ? 0.0
        : y == max - 1
        ? 2.0
        : 1.0;
    return Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);
  }
}
