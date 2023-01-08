import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flametest/harvester_game.dart';
import 'package:flametest/map_object.dart';

class WheatChunk {
  static final _paint = Paint();

  final int size;
  final Vector2 position;
  final List<List<MapObject?>> mapObjects;

  WheatChunk(
      {required this.size,
      required this.position,
      MapObjectCreator? initialObjectCreator})
      : mapObjects = List.generate(size,
            (_) => List.generate(size, (__) => initialObjectCreator?.call()));

  void render(Canvas canvas) {
    for (int i = 0; i < mapObjects.length; i++) {
      for (int j = 0; j < mapObjects[i].length; j++) {
        if (mapObjects[i][j] == null) {
          continue;
        }

        // TODO maybe drawAtlas is suitable here

        final mapObject = mapObjects[i][j]!;
        final additionalSize = Vector2(0.01, 0.01);
        canvas.drawImageRect(
            mapObject.image,
            Rect.fromLTWH(0, 0, mapObject.image.width.toDouble(),
                mapObject.image.height.toDouble()),
            Rect.fromLTWH(
                position.x * size + i,
                position.y * size + j,
                mapObject.size.x + additionalSize.x,
                mapObject.size.y + additionalSize.y),
            _paint);
      }
    }
  }

  void tryCollect(Vector2 gamePos, HarvesterGame gameRef) {
    final innerPosX = (gamePos.x % size + size).floor() % size;
    final innerPosY = (gamePos.y % size + size).floor() % size;

    if (mapObjects[innerPosX][innerPosY] != null) {
      gameRef.increaseScore(1);
    }

    mapObjects[innerPosX][innerPosY] = null;
  }
}
