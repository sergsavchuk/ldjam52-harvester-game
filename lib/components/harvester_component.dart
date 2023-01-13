import 'dart:async';
import 'dart:ui';

import 'package:another_harvester_game/utils.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:another_harvester_game/harvester_game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HarvesterComponent extends BodyComponent<HarvesterGame> {
  final _size = Vector2(1, 1.556);

  late final vertices = <Vector2>[
    Vector2(-_size.x / 2, -_size.y / 2),
    Vector2(_size.x / 2, -_size.y / 2),
    Vector2(_size.x / 2, _size.y / 2),
    Vector2(-_size.x / 2, _size.y / 2),
  ];

  final _torque = 1.0;
  final _forwardImpulse = 0.1;
  final _backwardImpulse = 0.05;

  final _streamSubscriptions = <StreamSubscription>[];

  double _accelerometerInput = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(
        anchor: Anchor.center,
        size: _size,
        sprite: await gameRef.loadSprite('harvester_new.png')));

    if (isMobile) {
      _streamSubscriptions.add(userAccelerometerEvents
          .listen((event) => _accelerometerInput = event.y));
    }
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = gameRef.size / 2;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 15.0
      ..linearDamping = 5.0;

    final shape = PolygonShape()..set(vertices);
    final fixtureDef = FixtureDef(shape)
      ..density = 0.2
      ..restitution = 0.1;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.running && gameRef.pressedKeySet.isEmpty) {
      return;
    }

    // Use lazy initialization to not calculate normal if there is no input.
    late final Vector2 currentForwardNormal =
        body.worldVector(Vector2(0.0, -1.0));
    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyW) ||
        (isMobile && !gameRef.pedalPressed)) {
      body.applyLinearImpulse(currentForwardNormal *
          _forwardImpulse *
          (gameRef.save.speedUpgrades + 1).toDouble());
    }

    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyS) ||
        gameRef.pedalPressed) {
      body.applyLinearImpulse(-currentForwardNormal *
          _backwardImpulse *
          (gameRef.save.speedUpgrades + 1).toDouble());
    }

    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyA)) {
      body.applyTorque(-_torque - gameRef.save.torqueUpgrades / 2);
    }

    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyD)) {
      body.applyTorque(_torque + gameRef.save.torqueUpgrades / 2);
    }

    if (isMobile) {
      body.applyTorque(_accelerometerInput * (5 + gameRef.save.torqueUpgrades));
    }
  }

  @override
  void render(Canvas canvas) {
    // keep it empty to not draw white rect of BodyComponent
  }

  @override
  void onRemove() {
    super.onRemove();

    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
