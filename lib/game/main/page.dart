import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/game/finish/page.dart';
import 'package:geocibus/game/main/events.dart';
import 'package:geocibus/game/main/exchange.dart';
import 'package:geocibus/game/main/map.dart';
import 'package:geocibus/game/main/resources.dart';
import 'package:geocibus/game/main/round_beginning_overlay.dart';
import 'package:geocibus/game/main/top.dart';
import 'package:geocibus/models/game.dart';
import 'package:provider/provider.dart';

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
              final navigator = Navigator.of(context);
              if (game.round == 10) {
                navigator.pushReplacement(MaterialPageRoute(builder: (context) => FinishPage(_game)));
              } else {
                if (navigator.canPop()) navigator.pop();
                showDialog(context: context, barrierDismissible: false, builder: (context) => RoundBeginningOverlay(game));
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
                      ElevatedButton(
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
