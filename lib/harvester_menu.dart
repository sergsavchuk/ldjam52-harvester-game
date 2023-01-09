import 'dart:io';

import 'package:another_harvester_game/harvester_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef IntFunction = int Function();

class HarvesterMenu extends StatefulWidget {
  final HarvesterGame game;

  const HarvesterMenu(this.game, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HarvesterMenuState();
  }
}

class HarvesterMenuState extends State<HarvesterMenu> {
  bool upgradeInfoVisible = false;
  String upgradeInfoText = "Speed upgrade Cost: 1  Your money: 0";

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
            child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                elevation: 6,
                shadowColor: Colors.black,
                borderOnForeground: true,
                color: Colors.deepOrange.shade200,
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                  ),
                  Text('Another harvester game',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubikBubbles(
                          fontSize: 36,
                          color: Colors.black,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none)),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  TextButton(
                      onPressed: () => widget.game.start(),
                      child: Text(
                          widget.game.started ? "Continue" : "Start Game",
                          style: GoogleFonts.rubikBubbles(fontSize: 18))),
                  TextButton(
                      onPressed: () => exit(0),
                      child: Text("Exit",
                          style: GoogleFonts.rubikBubbles(fontSize: 18))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _upgradeButton("Speed", () => 1, () => widget.game.money,
                          Image.asset('assets/icon/speed.png')),
                      _upgradeButton("Torque", () => 1, () => widget.game.money,
                          Image.asset('assets/icon/torque.png')),
                    ],
                  ),
                  Visibility(
                      visible: upgradeInfoVisible,
                      child: Text(upgradeInfoText,
                          style: GoogleFonts.rubikBubbles())),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          alignment: Alignment.bottomCenter,
                          child: Text("Highscore: ${widget.game.highScore}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubikBubbles(
                                  color: Colors.white, fontSize: 24))))
                ]))));
  }

  Widget _upgradeButton(String upgradeName, IntFunction upgradeCostProvider,
      IntFunction currentMoneyProvider, Image icon) {
    return MouseRegion(
      child: Container(
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            // border: Border.all(color: Colors.lightBlueAccent),
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                  blurStyle: BlurStyle.outer,
                  blurRadius: 3,
                  offset: Offset(2, 2))
            ],
          ),
          child: IconButton(
            iconSize: 80,
            onPressed: null,
            icon: icon,
          )),
      onEnter: (_) => {
        setState(() {
          upgradeInfoVisible = true;
          upgradeInfoText =
              "$upgradeName upgrade Cost: ${upgradeCostProvider()}  Your money: ${currentMoneyProvider()}";
        })
      },
      onExit: (_) => {
        setState(() {
          upgradeInfoVisible = false;
        })
      },
    );
  }
}
