import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sowi/constants.dart';
import 'package:sowi/game/main/exchange.dart';
import 'package:sowi/game/main/map_old.dart';
import 'package:sowi/game/main/round_beginning_overlay.dart';
import 'package:sowi/game/main/top.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/widgets/elevation.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _game = Game();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _game,
      child: Builder(
        builder: (context) {
          final game = context.watch<Game>();

          if (game.roundState == RoundState.beginning) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) => showDialog(context: context, builder: (context) => RoundBeginningOverlay(game)));
          }

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const MainTop(),
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final event in game.activeEvents) ...[
                              Elevation(child: Icon(event.icon)),
                              if (event != game.activeEvents.last) const Gap(8),
                            ],
                          ],
                        ),
                        const Expanded(child: GameMap()),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card.filled(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: game.money.toString()),
                                const WidgetSpan(child: FaIcon(moneyIcon)),
                                TextSpan(text: game.water.toString()),
                                const WidgetSpan(child: FaIcon(waterIcon)),
                                TextSpan(text: game.food.toString()),
                                const WidgetSpan(child: FaIcon(foodIcon)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      const GameExchange(),
                      const Gap(8),
                      OutlinedButton(
                        onPressed: game.finishRound,
                        child: const Text('Runde beenden'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
