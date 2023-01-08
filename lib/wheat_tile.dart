import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/harvester.dart';
import 'package:flametest/harvester_game.dart';

class WheatTile extends BodyComponent<HarvesterGame> with ContactCallbacks {
  final _baseSize = Vector2(1.0, 1.16);
  final _bottomRadius = 0.5;

  bool collected = false;

  final Vector2 position;

  WheatTile({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(
        anchor: Anchor.bottomCenter,
        // make size a tiny bit larger so there is no gap between tiles
        size: _baseSize + Vector2(0.01, 0.01),
        position: Vector2(0, _bottomRadius),
        sprite: await gameRef.loadSprite('cute_wheat.png')));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = CircleShape()..radius = _bottomRadius;
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
