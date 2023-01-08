import 'dart:ui';

import 'package:flame/components.dart';

typedef MapObjectCreator = MapObject Function();

class MapObject {
  final Image image;
  final Vector2 size;

  MapObject({required this.image, required this.size});
}