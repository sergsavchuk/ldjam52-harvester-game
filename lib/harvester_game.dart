import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/harvester.dart';
import 'package:flametest/wheat_field.dart';
import 'package:flametest/map_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const zoom = 100.0;

final screenSize = Vector2(1920, 1080);
final worldSize = screenSize / zoom;

final blackPaint = Paint()..color = Colors.black;

final List<LogicalKeyboardKey> controls = [
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyS,
];

class HarvesterGame extends Forge2DGame
    with PanDetector, ScrollDetector, KeyboardEvents {
  late Harvester harvester;
  late TextComponent scoreComponent;

  late final Set<LogicalKeyboardKey> pressedKeySet = {};

  int _currentScore = 0;

  final double _minCameraZoom = 50;
  final double _maxCameraZoom = 100;

  // TODO different scroll modifier for different platforms
  final double _cameraGlobalScrollModifier = 10;

  HarvesterGame() : super(gravity: Vector2.zero(), zoom: zoom);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(screenSize);

    add(_Background(size: screenSize)..positionType = PositionType.viewport);

    final wheatSprite = await loadSprite('cute_wheat.png');

    final mapComponent = WheatField(
        renderDistance: 2,
        chunkSize: 20,
        initialObjectCreator: () =>
            MapObject(image: wheatSprite.image, size: Vector2(1.0, 1.16)));
    add(mapComponent);

    await add(harvester = Harvester());
    camera.followVector2(harvester.body.position);
    mapComponent.renderCenter = harvester.body.position;

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
  void onScroll(PointerScrollInfo info) {
    super.onScroll(info);

    final zoomDelta = info.scrollDelta.global.y / _cameraGlobalScrollModifier;

    camera.zoom =
        max(min(camera.zoom - zoomDelta, _maxCameraZoom), _minCameraZoom);
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
