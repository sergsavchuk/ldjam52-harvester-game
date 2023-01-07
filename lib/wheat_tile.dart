import 'package:flame/components.dart';

class WheatTile extends SpriteComponent with HasGameRef {
  WheatTile({required super.position});

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite('dummy_wheat.jpg');

    // make size a tiny bit larger so there is no gap between tiles
    size = Vector2(1.01, 1.01);
  }
}
