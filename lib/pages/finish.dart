import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/population_diagram.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final ThemeData(:textTheme, colorScheme: colors) = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.game.score.toString(),
                style: textTheme.displayLarge!.copyWith(color: colors.surfaceContainerLow, fontSize: textTheme.displayLarge!.fontSize! * 2),
              ),
              Text(
                widget.game.score > (_highScore ?? double.infinity) ? 'Neuer Highscore!' : 'Highscore: ${_highScore ?? 'Laden...'}',
                style: textTheme.displayMedium!.copyWith(color: colors.surfaceContainerLow),
              ),
              const Gap(24),
              Text(
                'Bevölkerungsentwicklung',
                style: textTheme.headlineMedium!.copyWith(color: colors.surfaceContainerLow),
              ),
              const Gap(8),
              Expanded(child: AspectRatio(aspectRatio: 1, child: PopulationDiagram(yearlyPopulation: widget.game.yearlyPopulation))),
              const Gap(40),
              Button(
                text: 'Zurück zum Hauptmenü',
                style: textTheme.headlineMedium,
                borderWidth: 3,
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const StartPage())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
