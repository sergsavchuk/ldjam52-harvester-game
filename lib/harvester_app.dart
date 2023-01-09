import 'package:another_harvester_game/harvester_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'harvester_menu.dart';

class HarvesterApp extends StatelessWidget {
  const HarvesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AnotherHarvesterGame',
        home: GameWidget<HarvesterGame>(
          game: HarvesterGame(),
          loadingBuilder: (context) => const Center(child: Text('Loading...')),
          overlayBuilderMap: {'menu': (_, game) => HarvesterMenu(game)},
          initialActiveOverlays: const ['menu'],
        ));
  }
}
