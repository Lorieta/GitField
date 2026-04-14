import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:gitfield/components/land.dart';

enum PlayerState {
  down,
  downLeft,
  left,
  upLeft,
  up,
  upRight,
  right,
  downRight,
  idle,
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with KeyboardHandler, HasGameReference {
  final DynamicMap map;

  double stamina = 100;
  bool isSprinting = false;
  double _playerSpeed = 100.0;
  final double renderScale = .5;
  Vector2 velocity = Vector2.zero();

  Player({required this.map, super.position})
    : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = await game.images.load('player.png');
    final sheet = SpriteSheet(
      image: image,
      srcSize: Vector2(image.width / 8, image.height / 3),
    );

    SpriteAnimation getColAnim(int col) => SpriteAnimation.spriteList([
      sheet.getSprite(0, col),
      sheet.getSprite(1, col),
      sheet.getSprite(2, col),
    ], stepTime: 0.1);

    animations = {
      PlayerState.down: getColAnim(4),
      PlayerState.downLeft: getColAnim(3),
      PlayerState.left: getColAnim(2),
      PlayerState.upLeft: getColAnim(1),
      PlayerState.up: getColAnim(0),
      PlayerState.upRight: getColAnim(7),
      PlayerState.right: getColAnim(6),
      PlayerState.downRight: getColAnim(5),
      PlayerState.idle: SpriteAnimation.spriteList([
        sheet.getSprite(0, 4),
      ], stepTime: 0.1),
    };

    scale = Vector2.all(renderScale);
    current = PlayerState.idle;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    isSprinting = keysPressed.contains(LogicalKeyboardKey.shiftLeft);
    velocity
      ..x =
          (keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0) -
          (keysPressed.contains(LogicalKeyboardKey.keyA) ? 1 : 0)
      ..y =
          (keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0) -
          (keysPressed.contains(LogicalKeyboardKey.keyW) ? 1 : 0);
    _updateAnimation(velocity);
    return true;
  }

  void _updateAnimation(Vector2 v) {
    if (v.x == 0 && v.y == 0) {
      current = PlayerState.idle;
      return;
    }
    if (v.x > 0 && v.y > 0) {
      current = PlayerState.downRight;
      return;
    }
    if (v.x < 0 && v.y > 0) {
      current = PlayerState.downLeft;
      return;
    }
    if (v.x > 0 && v.y < 0) {
      current = PlayerState.upRight;
      return;
    }
    if (v.x < 0 && v.y < 0) {
      current = PlayerState.upLeft;
      return;
    }
    if (v.x > 0) {
      current = PlayerState.right;
      return;
    }
    if (v.x < 0) {
      current = PlayerState.left;
      return;
    }
    current = v.y > 0 ? PlayerState.down : PlayerState.up;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!velocity.isZero()) {
      position += velocity.normalized() * _playerSpeed * dt;
    }

    _clampInsideMap();

    if (isSprinting && stamina > 0) {
      _playerSpeed = 150;
      stamina -= 20 * dt;
    } else {
      _playerSpeed = 100;
      if (stamina < 100) stamina += 5 * dt;
    }
  }

  void _clampInsideMap() {
    final halfW = (size.x * scale.x) / 2;
    final halfH = (size.y * scale.y) / 2;
    final wallX = map.scale.x;
    final wallY = map.scale.y;

    position.x = position.x.clamp(
      map.position.x + wallX + halfW,
      map.position.x + (map.size.x * map.scale.x) - wallX - halfW,
    );
    position.y = position.y.clamp(
      map.position.y + wallY + halfH,
      map.position.y + (map.size.y * map.scale.y) - wallY - halfH,
    );
  }
}
