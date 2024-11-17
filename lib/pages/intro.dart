import 'package:flutter/material.dart';
import 'package:sowi/logic/game.dart';
import 'package:sowi/pages/map.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Text('Runde ${game.round}', style: theme.textTheme.displayLarge),
          Text('Disaster: ${game.newDisaster}'),
          Text('Geld: ${game.money}, Essen: ${game.food}, Wasser: ${game.water}'),
          Text('Diese Runde generiert: ${game.generatedMoney} Geld, ${game.generatedFood} Essen, ${game.generatedWater} Wasser'),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MapPage())),
            child: const Text('Runde starten'),
          ),
        ],
      ),
    );
  }
}
