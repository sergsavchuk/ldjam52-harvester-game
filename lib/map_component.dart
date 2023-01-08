import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flametest/chunk.dart';
import 'package:flametest/harvester_game.dart';
import 'package:flametest/map_object.dart';

class WheatField extends Component with HasGameRef<HarvesterGame> {
  final int renderDistance;
  final int chunkSize;

  Vector2? renderCenter;
  MapObjectCreator? initialObjectCreator;

  final Map<Vector2, Chunk> chunksMap = {};

  WheatField(
      {required this.renderDistance,
      required this.chunkSize,
      this.initialObjectCreator});

  @override
  void update(double dt) {
    super.update(dt);

    if (renderCenter == null) {
      return;
    }

    final center = renderCenter!;

    final currentChunkX = center.x ~/ chunkSize - (center.x < 0 ? 1 : 0);
    final currentChunkY = center.y ~/ chunkSize - (center.y < 0 ? 1 : 0);

    for (int i = currentChunkX - renderDistance;
        i < currentChunkX + renderDistance;
        i++) {
      for (int j = currentChunkY - renderDistance;
          j < currentChunkY + renderDistance;
          j++) {
        final chunksPos = Vector2(i.toDouble(), j.toDouble());
        if (!chunksMap.containsKey(chunksPos)) {
          chunksMap[chunksPos] = Chunk(
              size: chunkSize,
              position: chunksPos,
              initialObjectCreator: initialObjectCreator);
        }
      }
    }

    chunksMap[Vector2(currentChunkX.toDouble(), currentChunkY.toDouble())]
        ?.tryCollect(center, gameRef);
  }

  @override
  void render(Canvas canvas) {
    // TODO do not sort every time on render
    final chunks = chunksMap.values.toList(growable: false);
    chunks.sort((a, b) {
      final heightCompare = a.position.y.compareTo(b.position.y);
      if (heightCompare != 0) {
        return heightCompare;
      }
      return a.position.x.compareTo(b.position.x);
    });

    if (renderCenter == null) {
      return;
    }

    final center = renderCenter!;
    final currentChunkX = center.x ~/ chunkSize;
    final currentChunkY = center.y ~/ chunkSize;

    for (final chunk in chunks) {
      if (chunk.position.x >= currentChunkX - renderDistance &&
          chunk.position.x <= currentChunkX + renderDistance &&
          chunk.position.y >= currentChunkY - renderDistance &&
          chunk.position.y <= currentChunkY + renderDistance) {
        chunk.render(canvas);
      }
    }
  }
}
