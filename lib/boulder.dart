import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/harvester_game.dart';

class Boulder extends BodyComponent<HarvesterGame> {
  final Vector2 position;

  Boulder({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(
        anchor: Anchor.center,
        sprite: await gameRef.loadSprite('dummy_boulder.png'),
        size: Vector2(1.54, 1)));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = CircleShape()..radius = .5;
    final fixtureDef = FixtureDef(shape);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    // keep it empty to not draw white rect of BodyComponent
  }
}
