import 'package:another_harvester_game/harvester_app.dart';
import 'package:another_harvester_game/harvester_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOver extends StatelessWidget {
  final HarvesterGame game;

  const GameOver(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
            child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                elevation: 6,
                shadowColor: Colors.black,
                borderOnForeground: true,
                color: Colors.deepOrange.shade200,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('Your score: ${game.score}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubikBubbles(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontStyle: FontStyle.normal,
                                  decoration: TextDecoration.none))),
                      TextButton(
                          onPressed: () {
                            game.overlays.clear();
                            game.overlays.add(HarvesterApp.menuOverlay);
                          },
                          child: Text("OK",
                              style: GoogleFonts.rubikBubbles(fontSize: 18))),
                    ]))));
  }
}
