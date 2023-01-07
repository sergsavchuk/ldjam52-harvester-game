import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/harvester.dart';
import 'package:flametest/wheat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const zoom = 100.0;

final screenSize = Vector2(1920, 1080);
final worldSize = screenSize / zoom;

final blackPaint = Paint()..color = Colors.black;

const fieldSize = 20;

final List<LogicalKeyboardKey> controls = [
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyS,
];

class HarvesterGame extends Forge2DGame
    with PanDetector, ScaleDetector, KeyboardEvents {
  late Harvester harvester;
  late TextComponent scoreComponent;

  late final Set<LogicalKeyboardKey> pressedKeySet = {};

  int _currentScore = 0;

  HarvesterGame() : super(gravity: Vector2.zero(), zoom: zoom);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(screenSize);

    add(_Background(size: screenSize)..positionType = PositionType.viewport);

    addAll(List.generate(
        fieldSize * fieldSize,
        (index) => WheatTile(
            // TODO consider tile size in calculation
            position: Vector2((index % fieldSize).toDouble(),
                (index ~/ fieldSize).toDouble()))));

    await add(harvester = Harvester());
    camera.followVector2(harvester.body.position);

    add(scoreComponent = TextComponent(
        textRenderer: TextPaint(
            style: const TextStyle(fontSize: 50, color: Colors.white)),
        anchor: Anchor.topRight,
        position: Vector2(screenSize.x - 30, 30))
      ..positionType = PositionType.viewport);
    increaseScore(0);

    add(FpsTextComponent(
      anchor: Anchor.topLeft,
    ));
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    pressedKeySet.clear();

    for (var key in keysPressed) {
      if (controls.contains(key)) {
        pressedKeySet.add(key);
      }
    }

    return KeyEventResult.handled;
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

  void increaseScore(int value) {
    _currentScore += value;
    scoreComponent.text = "Score: $_currentScore";
  }
}

class _Background extends PositionComponent {
  _Background({super.size});

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), blackPaint);
  }
}
