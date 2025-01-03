import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sowi/game/finish/page.dart';
import 'package:sowi/game/main/events.dart';
import 'package:sowi/game/main/exchange.dart';
import 'package:sowi/game/main/map.dart';
import 'package:sowi/game/main/resources.dart';
import 'package:sowi/game/main/round_beginning_overlay.dart';
import 'package:sowi/game/main/top.dart';
import 'package:sowi/models/game.dart';

// TODO Intro story for a tutorial

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
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (game.round == 10) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => FinishPage(_game)));
              } else {
                showDialog(context: context, builder: (context) => RoundBeginningOverlay(game));
              }
            });
          }

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // TODO Restructure (layout stays in page.dart, parts get extracted into different widgets)
                  const MainTop(),
                  const Expanded(
                    child: Row(
                      children: [
                        MainEvents(),
                        Expanded(child: MainMap()),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MainResources(),
                      const Gap(8),
                      const MainExchange(),
                      const Gap(8),
                      OutlinedButton(
                        onPressed: game.finishRound,
                        child: const Text('Jahr beenden'),
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
