import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/harvester.dart';
import 'package:flametest/harvester_game.dart';
import 'package:forge2d/src/dynamics/body.dart';

class WheatTile extends BodyComponent<HarvesterGame> with ContactCallbacks {
  final _baseSize = Vector2(1.0, 1.0);

  bool collected = false;

  final Vector2 position;

  WheatTile({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(
        anchor: Anchor.center,
        // make size a tiny bit larger so there is no gap between tiles
        size: _baseSize + Vector2(0.01, 0.01),
        sprite: await gameRef.loadSprite('dummy_wheat.jpg')));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = CircleShape()..radius = 0.5;
    final fixtureDef = FixtureDef(shape)..isSensor = true;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (collected) {
      world.destroyBody(body);
      gameRef.remove(this);
      gameRef.increaseScore(1);
    }
  }

  @override
  void render(Canvas canvas) {}

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Harvester) {
      collected = true;
    }
  }
}
