import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/gitfield.dart';

void main() {
  final game = Gitfield();
  runApp(GameWidget(game: game));
}
