import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/player.dart';
import 'package:flametest/wheat_tile.dart';
import 'package:flutter/material.dart';

const zoom = 100.0;

final screenSize = Vector2(1920, 1080);
final worldSize = screenSize / zoom;

final blackPaint = Paint()..color = Colors.black;

const fieldSize = 20;

class HarvesterGame extends Forge2DGame with PanDetector, ScaleDetector {
  late Harvester player;

  HarvesterGame() : super(zoom: zoom);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(screenSize);

    add(_Background(size: screenSize)..positionType = PositionType.viewport);

    // add(player = Player());

    addAll(List.generate(
        fieldSize * fieldSize,
        (index) => WheatTile( // TODO consider tile size int calculation
            position: Vector2((index % fieldSize).toDouble(),
                (index ~/ fieldSize).toDouble()))));
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // TODO: implement onScaleUpdate
    super.onScaleUpdate(info);
  }

  @override
  Color backgroundColor() {
    return Colors.red; // TODO pick more suitable color
  }
}

class _Background extends PositionComponent {
  _Background({super.size});

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), blackPaint);
  }
}
