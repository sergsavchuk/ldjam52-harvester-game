import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:another_harvester_game/harvester_game.dart';

class BoulderComponent extends BodyComponent<HarvesterGame> {
  final Vector2 position;

  BoulderComponent({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(
        anchor: Anchor.center,
        sprite: await gameRef.loadSprite('boulder.png'),
        size: Vector2(1.0, 1.16)));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = CircleShape()..radius = .4;
    final fixtureDef = FixtureDef(shape);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    // keep it empty to not draw white rect of BodyComponent
  }
}
