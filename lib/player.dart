import 'package:flame/components.dart';
import 'package:flametest/space_shooter_game.dart';

class Player extends SpriteComponent with HasGameRef<SpaceShooterGame> {

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite('player-sprite.png');
    position = gameRef.size / 2;
    width = 50;
    height = 100;
    anchor = Anchor.center;
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}
