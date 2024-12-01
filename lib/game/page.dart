import 'package:flutter/material.dart';
import 'package:sowi/game/bottom.dart';
import 'package:sowi/game/disaster_display.dart';
import 'package:sowi/game/map.dart';
import 'package:sowi/game/round_beginning_overlay.dart';
import 'package:sowi/game/top.dart';
import 'package:sowi/logic/game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final game = Game();
  var _showIntro = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(context: context, builder: (context) => RoundBeginningOverlay(game));
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                GameTop(round: game.round, movesLeft: game.movesLeft),
                Expanded(
                  child: Row(
                    children: [
                      GameDisasterDisplay(game.activeDisasters),
                      Expanded(child: GameMap(regions: game.regions)),
                    ],
                  ),
                ),
                GameBottom(money: game.money, water: game.water, food: game.food, allowTrading: !_showIntro),
              ],
            );
          },
        ),
      ),
    );
  }
}
