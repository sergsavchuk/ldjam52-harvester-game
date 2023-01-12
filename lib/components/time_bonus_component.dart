import 'dart:ui';

import 'package:another_harvester_game/components/harvester_component.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:another_harvester_game/harvester_game.dart';

class TimeBonusComponent extends BodyComponent<HarvesterGame>
    with ContactCallbacks {
  final Vector2 position;

  bool collected = false;

  TimeBonusComponent({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(SpriteComponent(
        anchor: Anchor.center,
        sprite: gameRef.plusTimeSprite,
        size: Vector2(0.5, 0.5)));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
    );

    final shape = CircleShape()..radius = .25;
    final fixtureDef = FixtureDef(shape)..isSensor = true;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (collected) {
      world.destroyBody(body);
      removeFromParent();
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is HarvesterComponent) {
      gameRef.timeBonus();
      collected = true;
    }
  }

  @override
  void render(Canvas canvas) {
    // keep it empty to not draw white rect of BodyComponent
  }
}
