import 'package:another_harvester_game/game_over.dart';
import 'package:another_harvester_game/harvester_game.dart';
import 'package:another_harvester_game/harvester_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HarvesterApp extends StatelessWidget {
  static const String menuOverlay = 'menu';
  static const String gameOverOverlay = 'gameOver';

  const HarvesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AnotherHarvesterGame',
        home: GameWidget<HarvesterGame>(
          game: HarvesterGame(),
          loadingBuilder: (context) => Center(
              child: Text('Loading...',
                  style: GoogleFonts.rubikBubbles(
                      decoration: TextDecoration.none, color: Colors.white))),
          overlayBuilderMap: {
            menuOverlay: (_, game) => HarvesterMenu(game),
            gameOverOverlay: (_, game) => GameOver(game)
          },
          initialActiveOverlays: const [HarvesterApp.menuOverlay],
        ));
  }
}
