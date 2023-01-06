import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flametest/player.dart';

class MyGame extends Forge2DGame with PanDetector {
  late Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(player = Player());
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game);
  }
}