import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/land.dart';

class Gitfield extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  Gitfield({super.children});
  @override
  Future<void> onLoad() async {
    final map = DynamicMap(gridSize: 15);
    add(map);
    final spawn = Vector2.all(
      map.gridSize * map.tileSize * map.renderScale / 2,
    );
    add(Player(position: spawn, map: map));
  }

  @override
  Color backgroundColor() {
    return Colors.blue;
  }
}
