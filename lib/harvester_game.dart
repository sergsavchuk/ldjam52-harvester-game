import 'dart:math';

import 'package:another_harvester_game/components/wheat_field_component.dart';
import 'package:another_harvester_game/game_save.dart';
import 'package:another_harvester_game/harvester_app.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:another_harvester_game/components/harvester_component.dart';
import 'package:another_harvester_game/components/hay_component.dart';
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

final Map<LogicalKeyboardKey, LogicalKeyboardKey> keyMap = {
  LogicalKeyboardKey.arrowUp: LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.arrowLeft: LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.arrowRight: LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.arrowDown: LogicalKeyboardKey.keyS,
  const LogicalKeyboardKey(0x00000446): LogicalKeyboardKey.keyW,
  const LogicalKeyboardKey(0x00000444): LogicalKeyboardKey.keyA,
  const LogicalKeyboardKey(0x00000432): LogicalKeyboardKey.keyD,
  const LogicalKeyboardKey(0x0000044b): LogicalKeyboardKey.keyS,
};

class HarvesterGame extends Forge2DGame
    with PanDetector, ScrollDetector, KeyboardEvents {
  late HarvesterComponent harvester;
  late WheatFieldComponent wheatField;
  late final TextComponent _scoreComponent;
  late final TextComponent _timeComponent;
  late final TextComponent _controlsComponent;

  late final Set<LogicalKeyboardKey> pressedKeySet = {};

  final int _pointsToSpawHay = 5;

  final double _minCameraZoom = 50;
  final double _maxCameraZoom = 100;

  // TODO different scroll modifier for different platforms
  final double _cameraGlobalScrollModifier = 10;

  late final Sprite wheatSprite;
  late final Sprite haySprite;
  late final Sprite plusTimeSprite;
  late final Sprite groundSprite;

  late final AudioPool _popSoundPool;

  bool started = false;
  bool running = false;

  double _levelTime = 30;
  double _timePassed = 0;

  int score = 0;

  late final GameSave save;

  HarvesterGame() : super(gravity: Vector2.zero(), zoom: zoom);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(screenSize);

    wheatSprite = await loadSprite('cute_wheat.png');
    haySprite = await loadSprite('hay_bale.png');
    plusTimeSprite = await loadSprite('plus_time.png');
    groundSprite = await loadSprite('ground_tile.png');

    save = GameSave(await SharedPreferences.getInstance());

    add(_scoreComponent = TextComponent(
        textRenderer: TextPaint(
            style: GoogleFonts.rubikBubbles(fontSize: 60, color: Colors.white)),
        anchor: Anchor.topRight,
        position: Vector2(screenSize.x - 30, 30))
      ..positionType = PositionType.viewport
      ..priority = double.maxFinite.toInt());
    _increaseScore(0);

    add(_timeComponent = TextComponent(
        textRenderer: TextPaint(
            style: GoogleFonts.rubikBubbles(fontSize: 60, color: Colors.white)),
        anchor: Anchor.topLeft,
        position: Vector2(30, 30))
      ..positionType = PositionType.viewport
      ..priority = double.maxFinite.toInt());

    _controlsComponent = TextComponent(
        text:
            "WASD/arrow keys to move\n Mouse wheel to zoom in/out\n Space to hide/show this message",
        textRenderer: TextPaint(
            style: GoogleFonts.rubikBubbles(fontSize: 60, color: Colors.white)),
        anchor: Anchor.center,
        position: screenSize / 2)
      ..positionType = PositionType.viewport
      ..priority = double.maxFinite.toInt();
    if (save.showControls) {
      add(_controlsComponent);
    }

    add(FpsTextComponent(
      position: Vector2(0, screenSize.y),
      anchor: Anchor.bottomLeft,
    ));

    await spawn();

    _popSoundPool = await FlameAudio.createPool('sounds/pop2.flac',
        minPlayers: 1, maxPlayers: 4);
  }

  void start() async {
    // if (!FlameAudio.bgm.isPlaying) {
    //   FlameAudio.bgm.play('sounds/country-loop.wav');
    // }

    _timePassed = 0;
    score = 0;
    _levelTime = 30;
    overlays.clear();

    started = true;
    running = true;
  }

  void pause() {
    if (running) {
      pressedKeySet.clear();

      running = false;
      overlays.add(HarvesterApp.menuOverlay);
    } else {
      start();
    }
  }

  void gameover() {
    pressedKeySet.clear();

    running = false;
    started = false;

    save.updateHighScore(score);
    save.addMoney(score ~/ _pointsToSpawHay);

    despawn();
    spawn();

    overlays.add(HarvesterApp.gameOverOverlay);
  }

  Future<void> spawn() async {
    wheatField = WheatFieldComponent(renderDistance: 2, chunkSize: 20);
    add(wheatField);

    await add(harvester = HarvesterComponent()..priority = 1000);
    camera.followVector2(harvester.body.position);
    wheatField.renderCenter = harvester.body.position;
  }

  void despawn() {
    remove(wheatField);
    remove(harvester);
    removeWhere((component) => component is HayComponent);
  }

  int speedUpgradeCost() {
    return pow(3, 3 + save.speedUpgrades).toInt();
  }

  int torqueUpgradeCost() {
    return pow(3, 3 + save.torqueUpgrades).toInt();
  }

  void buySpeedUpgrade() {
    final upgradeCost = speedUpgradeCost();
    if (save.money >= upgradeCost) {
      save.addMoney(-upgradeCost);
      save.increaseSpeedUpgrades();
    }
  }

  void buyTorqueUpgrade() {
    final upgradeCost = torqueUpgradeCost();
    if (save.money >= upgradeCost) {
      save.addMoney(-upgradeCost);
      save.increaseTorqueUpgrades();
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    if (keysPressed.contains(LogicalKeyboardKey.escape) && started) {
      pause();
    }

    if (keysPressed.contains(LogicalKeyboardKey.space) && started) {
      save.invertShowControls();
      if (save.showControls) {
        add(_controlsComponent);
      } else {
        remove(_controlsComponent);
      }
    }

    if (!running) {
      return KeyEventResult.ignored;
    }

    pressedKeySet.clear();

    for (var key in keysPressed) {
      if (keyMap.containsKey(key)) {
        key = keyMap[key]!;
      }

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

  void wheatCollected() {
    _increaseScore(1);
  }

  void _increaseScore(int value) {
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
    add(HayComponent(sprite: haySprite, position: harvester.body.position));
    _popSoundPool.start();
  }

  @override
  void onRemove() {
    super.onRemove();

    FlameAudio.bgm.dispose();
  }

  void timeBonus() {
    _levelTime += 5;
  }
}
