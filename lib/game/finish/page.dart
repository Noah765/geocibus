import 'package:flutter/material.dart';
import 'package:sowi/models/game.dart';

class FinishPage extends StatelessWidget {
  const FinishPage(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text('Score: ${game.score}', style: textTheme.displayLarge),
        OutlinedButton(onPressed: Navigator.of(context).pop, child: const Text('Zurück zum Hauptmenü')),
      ],
    );
  }
}
