import 'dart:math';
import 'dart:ui';

import 'package:another_harvester_game/time_bonus.dart';
import 'package:flame/components.dart';
import 'package:another_harvester_game/boulder.dart';
import 'package:another_harvester_game/wheat_chunk.dart';
import 'package:another_harvester_game/harvester_game.dart';
import 'package:another_harvester_game/map_object.dart';

class WheatField extends Component with HasGameRef<HarvesterGame> {
  final int renderDistance;
  final int chunkSize;

  Vector2? renderCenter;
  MapObjectCreator? initialObjectCreator;

  final Map<Vector2, WheatChunk> chunksMap = {};

  late final _spawnPositionUtilityList =
      List.generate(chunkSize * chunkSize, (index) => index);

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
        final chunkPos = Vector2(i.toDouble(), j.toDouble());
        if (!chunksMap.containsKey(chunkPos)) {
          chunksMap[chunkPos] = WheatChunk(
              size: chunkSize,
              position: chunkPos,
              initialObjectCreator: initialObjectCreator);

          _spawnBoldersAndBonuses(chunksMap[chunkPos]!);
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

  void _spawnBoldersAndBonuses(WheatChunk chunk) {
    // TODO remove boulders when chunk is not rendered
    //  (and save there position in chunk data)

    final maxBoulders = chunkSize / 4;

    _spawnPositionUtilityList.shuffle();
    final bouldersCount =
        min(max(chunk.position.x.abs(), chunk.position.y.abs()), maxBoulders);
    for (int i = 0; i < bouldersCount; i++) {
      add(Boulder(
          position: chunk.position * chunkSize.toDouble() +
              Vector2((_spawnPositionUtilityList[i] % chunkSize).toDouble(),
                  (_spawnPositionUtilityList[i] ~/ chunkSize).toDouble())));
    }

    if (bouldersCount <= 1 || Random().nextDouble() < 1.0 / bouldersCount) {
      add(TimeBonus(
          position: chunk.position * chunkSize.toDouble() +
              Vector2(
                  (_spawnPositionUtilityList[bouldersCount.toInt()] % chunkSize)
                      .toDouble(),
                  (_spawnPositionUtilityList[bouldersCount.toInt()] ~/
                          chunkSize)
                      .toDouble())));
    }
  }
}
