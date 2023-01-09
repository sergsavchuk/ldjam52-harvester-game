import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:another_harvester_game/harvester_game.dart';
import 'package:flutter/services.dart';

class Harvester extends BodyComponent<HarvesterGame> {
  final _size = Vector2(1, 1.52);

  late final SpriteComponent sprite;

  late final vertices = <Vector2>[
    Vector2(-_size.x / 2, -_size.y / 2),
    Vector2(_size.x / 2, -_size.y / 2),
    Vector2(_size.x / 2, _size.y / 2),
    Vector2(-_size.x / 2, _size.y / 2),
  ];

  static const speedMultiplier = 1;

  final _maxForwardSpeed = 8.0 * speedMultiplier;
  final _maxBackwardSpeed = -3.5 * speedMultiplier;
  final _maxDriveForce = 8.0 * speedMultiplier;
  final _speedUpgradeValue = 4.0;

  final _torque = 1.0;

  late final _maxLateralImpulse = 7.5;
  final double _currentTraction = 1.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(sprite = SpriteComponent(
        anchor: Anchor.center,
        size: _size,
        sprite: await gameRef.loadSprite('harvester_sprite.png')));
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.dynamic
      ..position = gameRef.size / 2;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

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

    if (!body.isAwake && gameRef.pressedKeySet.isEmpty) {
      return;
    }

    _updateTurn(dt);
    _updateFriction();

    final currentForwardNormal = body.worldVector(Vector2(0.0, -1.0));
    final currentSpeed = _forwardVelocity.dot(currentForwardNormal);
    var force = 0.0;
    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyW) &&
        currentSpeed < _maxForwardSpeed + (gameRef.speedUpgrades * _speedUpgradeValue)) {
      force = _maxDriveForce + (gameRef.speedUpgrades * _speedUpgradeValue) / 2;
    }
    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyS) &&
        currentSpeed > _maxBackwardSpeed - (gameRef.speedUpgrades * _speedUpgradeValue)) {
      force = -_maxDriveForce - (gameRef.speedUpgrades * _speedUpgradeValue) / 2;
    }

    if (force.abs() > 0) {
      body.applyForce(currentForwardNormal..scale(_currentTraction * force));
    }
  }

  void _updateTurn(double dt) {
    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyA)) {
      body.applyTorque(-_torque - gameRef.torqueUpgrades / 2);
    }

    if (gameRef.pressedKeySet.contains(LogicalKeyboardKey.keyD)) {
      body.applyTorque(_torque + gameRef.torqueUpgrades / 2);
    }
  }

  void _updateFriction() {
    final impulse = _lateralVelocity
      ..scale(-body.mass)
      ..clampScalar(-_maxLateralImpulse, _maxLateralImpulse)
      ..scale(_currentTraction);

    body.applyLinearImpulse(impulse);
    body.applyAngularImpulse(
      0.1 * _currentTraction * body.getInertia() * -body.angularVelocity,
    );

    final currentForwardNormal = _forwardVelocity;
    final currentForwardSpeed = currentForwardNormal.length;
    currentForwardNormal.normalize();

    final dragForceMagnitute = -2 * currentForwardSpeed;
    body.applyForce(
        currentForwardNormal..scale(_currentTraction * dragForceMagnitute));
  }

  @override
  void render(Canvas canvas) {
    // keep it empty to not draw white rect of BodyComponent
  }

  // TODO maybe move it up ? or move to game class ?
  final Vector2 _worldLeft = Vector2(-1.0, 0);
  final Vector2 _worldUp = Vector2(0, -1.0);

  Vector2 get _lateralVelocity {
    final currentRightNormal = body.worldVector(_worldLeft);
    return currentRightNormal
      ..scale(currentRightNormal.dot(body.linearVelocity));
  }

  Vector2 get _forwardVelocity {
    final currentForwardNormal = body.worldVector(_worldUp);
    return currentForwardNormal
      ..scale(currentForwardNormal.dot(body.linearVelocity));
  }
}
