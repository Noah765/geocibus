import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocibus/models/game.dart';

class FinishPage extends StatefulWidget {
  const FinishPage(this.game, {super.key});

  final Game game;

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  int? _highScore;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      setState(() => _highScore = value.getInt('highScore') ?? 0);
      if (widget.game.score > _highScore!) value.setInt('highScore', widget.game.score);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          Text('Score: ${widget.game.score}', style: textTheme.displayLarge),
          Text('High Score: ${_highScore ?? 'Laden...'}'),
          OutlinedButton(onPressed: Navigator.of(context).pop, child: const Text('Zurück zum Hauptmenü')),
        ],
      ),
    );
  }
}
