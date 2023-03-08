import 'dart:io';

import 'package:another_harvester_game/harvester_game.dart';
import 'package:another_harvester_game/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef IntFunction = int Function();

class MenuOverlay extends StatelessWidget {
  final HarvesterGame game;

  const MenuOverlay(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isMobile ? MobileMenuOverlay(game) : DesktopMenuOverlay(game);
  }
}

class MobileMenuOverlay extends StatefulWidget {
  const MobileMenuOverlay(this.game, {Key? key}) : super(key: key);

  final HarvesterGame game;

  @override
  State<MobileMenuOverlay> createState() => _MobileMenuOverlayState();
}

class _MobileMenuOverlayState extends State<MobileMenuOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Another harvester game"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Spacer(),
                Stack(
                  children: [
                    Image.asset('assets/images/hay_bale.png'),
                  ],
                ),
                // Spacer(),
                const Icon(
                  Icons.play_circle_outline_rounded,
                  size: 200,
                ),
                // Spacer(),
                Stack(
                  children: [
                    Image.asset('assets/images/harvester_new.png'),
                  ],
                ),
                // Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopMenuOverlay extends StatefulWidget {
  final HarvesterGame game;

  const DesktopMenuOverlay(this.game, {super.key});

  @override
  State<StatefulWidget> createState() => DesktopMenuOverlayState();
}

class DesktopMenuOverlayState extends State<DesktopMenuOverlay> {
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
                          fontSize: 32,
                          color: Colors.black,
                          fontStyle: FontStyle.normal,
                          decoration: TextDecoration.none)),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  TextButton(
                      onPressed: () => widget.game.start(),
                      child: Text(widget.game.started ? "Continue" : "Play",
                          style: GoogleFonts.rubikBubbles(fontSize: 24))),
                  TextButton(
                      onPressed: () {
                        widget.game.save.resetProgress();
                        setState(() {});
                      },
                      child: Text("Reset progress",
                          style: GoogleFonts.rubikBubbles(fontSize: 24))),
                  TextButton(
                      onPressed: () => exit(0),
                      child: Text("Exit",
                          style: GoogleFonts.rubikBubbles(fontSize: 24))),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _upgradeButton(
                          "Speed",
                          () => widget.game.speedUpgradeCost(),
                          () => widget.game.save.money,
                          Image.asset('assets/icon/speed.png'),
                          widget.game.buySpeedUpgrade),
                      _upgradeButton(
                          "Torque",
                          () => widget.game.torqueUpgradeCost(),
                          () => widget.game.save.money,
                          Image.asset('assets/icon/torque.png'),
                          widget.game.buyTorqueUpgrade),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Visibility(
                      visible: upgradeInfoVisible,
                      child: Text(upgradeInfoText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubikBubbles())),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          alignment: Alignment.bottomCenter,
                          child: Text(
                              "Highscore: ${widget.game.save.highScore}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubikBubbles(
                                  color: Colors.white, fontSize: 24))))
                ]))));
  }

  Widget _upgradeButton(String upgradeName, IntFunction upgradeCostProvider,
      IntFunction currentMoneyProvider, Image icon, VoidCallback onPress) {
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
            iconSize: 70,
            onPressed: () {
              onPress();
              setState(() {
                upgradeInfoText =
                    "$upgradeName upgrade Cost: ${upgradeCostProvider()}  Your money: ${currentMoneyProvider()}";
              });
            },
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
