import 'package:flame/components.dart';
import 'package:flametest/harvester_game.dart';

class Harvester extends SpriteComponent with HasGameRef<HarvesterGame> {

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite('player-sprite.png');
    position = gameRef.size / 2;
    width = 1;
    height = 2;
    anchor = Anchor.center;
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}
