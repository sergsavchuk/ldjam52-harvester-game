import 'dart:ui';

import 'package:flame/components.dart';

class WheatChunk {
  /// Additional size for each rendered sprite so there is no gap between tiles
  static final additionalRenderSize = Vector2(0.01, 0.01);

  final groundSize = Vector2(1.0, 1.0) + additionalRenderSize;
  final wheatSize = Vector2(1.0, 1.16) + additionalRenderSize;

  final Sprite groundSprite;
  final Sprite wheatSprite;

  final int size;
  final Vector2 position;

  // TODO maybe replace with Map or somethin' ?
  final List<List<bool>> wheatPresence;

  WheatChunk(
      {required this.size,
      required this.position,
      required this.groundSprite,
      required this.wheatSprite})
      : wheatPresence =
            List.generate(size, (_) => List.generate(size, (_) => true));

  // TODO maybe drawAtlas is suitable here
  void render(Canvas canvas) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (wheatPresence[i][j] == false) {
          groundSprite.render(canvas,
              position: Vector2(position.x * size + i, position.y * size + j),
              size: groundSize);
        }
      }
    }

    for (int i = 0; i < wheatPresence.length; i++) {
      for (int j = 0; j < wheatPresence[i].length; j++) {
        if (wheatPresence[i][j] == false) {
          continue;
        }

        wheatSprite.render(canvas,
            position: Vector2(position.x * size + i, position.y * size + j),
            size: wheatSize);
      }
    }
  }

  /// Returns true if there is wheat at {gamePos} and removes it.
  bool tryCollectWheat(Vector2 gamePos) {
    final innerPosX = (gamePos.x % size + size).floor() % size;
    final innerPosY = (gamePos.y % size + size).floor() % size;

    if (wheatPresence[innerPosX][innerPosY]) {
      wheatPresence[innerPosX][innerPosY] = false;
      return true;
    }

    return false;
  }
}
