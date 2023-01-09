import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:another_harvester_game/harvester.dart';
import 'package:another_harvester_game/hay.dart';
import 'package:another_harvester_game/wheat_field.dart';
import 'package:another_harvester_game/map_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late WheatField wheatField;
  late final TextComponent _scoreComponent;
  late final TextComponent _timeComponent;

  late final Set<LogicalKeyboardKey> pressedKeySet = {};

  final int _pointsToSpawHay = 5;

  final double _minCameraZoom = 50;
  final double _maxCameraZoom = 100;

  // TODO different scroll modifier for different platforms
  final double _cameraGlobalScrollModifier = 10;

  late final Sprite wheatSprite;
  late final Sprite haySprite;

  late final AudioPool _popSoundPool;
  late final SharedPreferences _sharedPrefs;

  bool started = false;
  bool running = false;

  double _levelTime = 30;
  double _timePassed = 0;

  int score = 0;
  int highScore = 0;
  int money = 0;

  HarvesterGame() : super(gravity: Vector2.zero(), zoom: zoom);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(screenSize);

    wheatSprite = await loadSprite('cute_wheat.png');
    haySprite = await loadSprite('hay.png');

    _popSoundPool = await FlameAudio.createPool('sounds/pop.mp3',
        minPlayers: 1, maxPlayers: 4);
    _sharedPrefs = await SharedPreferences.getInstance();

    money = _sharedPrefs.getInt('money') ?? 0;
    highScore = _sharedPrefs.getInt('highScore') ?? 0;

    add(_Background(size: screenSize)..positionType = PositionType.viewport);

    add(_scoreComponent = TextComponent(
        textRenderer: TextPaint(
            style: GoogleFonts.rubikBubbles(fontSize: 60, color: Colors.white)),
        anchor: Anchor.topRight,
        position: Vector2(screenSize.x - 30, 30))
      ..positionType = PositionType.viewport
      ..priority = double.maxFinite.toInt());
    increaseScore(0);

    add(_timeComponent = TextComponent(
        textRenderer: TextPaint(
            style: GoogleFonts.rubikBubbles(fontSize: 60, color: Colors.white)),
        anchor: Anchor.topLeft,
        position: Vector2(30, 30))
      ..positionType = PositionType.viewport
      ..priority = double.maxFinite.toInt());

    add(FpsTextComponent(
      position: Vector2(0, screenSize.y),
      anchor: Anchor.bottomLeft,
    ));

    await spawn();
  }

  void start() async {
    _timePassed = 0;
    score = 0;
    overlays.clear();

    started = true;
    running = true;
  }

  void pause() {
    if (running) {
      pressedKeySet.clear();

      running = false;
      overlays.add('menu');
    } else {
      start();
    }
  }

  void gameover() {
    pressedKeySet.clear();

    running = false;
    started = false;
    highScore = max(score, highScore);
    money += score ~/ _pointsToSpawHay;

    _sharedPrefs.setInt('money', money);
    _sharedPrefs.setInt('highScore', highScore);

    despawn();
    spawn();

    overlays.add('gameover');
  }

  Future<void> spawn() async {
    wheatField = WheatField(
        renderDistance: 2,
        chunkSize: 20,
        initialObjectCreator: () =>
            MapObject(image: wheatSprite.image, size: Vector2(1.0, 1.16)));
    add(wheatField);

    await add(harvester = Harvester()..priority = 1000);
    camera.followVector2(harvester.body.position);
    wheatField.renderCenter = harvester.body.position;
  }

  void despawn() {
    remove(wheatField);
    remove(harvester);
    removeWhere((component) => component is Hay);
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    if (keysPressed.contains(LogicalKeyboardKey.escape) && started) {
      pause();
    }

    if (!running) {
      return KeyEventResult.ignored;
    }

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
  void update(double dt) {
    super.update(dt);
    if (!running) {
      return;
    }

    _timePassed += dt;

    _timeComponent.text = "Time: ${max((_levelTime - _timePassed).floor(), 0)}";

    if (_timePassed >= _levelTime) {
      gameover();
    }
  }

  @override
  Color backgroundColor() {
    return Colors.black; // TODO pick more suitable color
  }

  void increaseScore(int value) {
    if (!started) {
      return;
    }

    score += value;
    _scoreComponent.text = "Score: $score";

    if (score > 0 && score % _pointsToSpawHay == 0) {
      _spawnHay();
    }
  }

  void _spawnHay() {
    add(Hay(sprite: haySprite, position: harvester.body.position));
    _popSoundPool.start();
  }
}

class _Background extends PositionComponent {
  _Background({super.size});

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), blackPaint);
  }
}
