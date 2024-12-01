import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/constants.dart';
import 'package:sowi/widgets/elevation.dart';

class GameTop extends StatelessWidget {
  const GameTop({super.key, required this.round, required this.movesLeft});

  final int round;
  final int movesLeft;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Zurück zum Hauptmenü',
              ),
              const Gap(8),
              Elevation(child: Text('RUNDE $round/$numberOfRounds')),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Elevation(child: Text('ÜBRIGE ZÜGE: $movesLeft')),
              const Gap(8),
              IconButton(
                onPressed: () {},
                tooltip: 'Einstellungen',
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
