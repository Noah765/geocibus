import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/logic/disaster.dart';
import 'package:sowi/logic/game.dart';
import 'package:sowi/widgets/elevation.dart';

class RoundBeginningOverlay extends StatelessWidget {
  const RoundBeginningOverlay(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.7,
          child: Column(
            children: [
              Elevation(
                symmetricalPadding: false,
                child: Text('RUNDE ${game.round}', style: theme.textTheme.displaySmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const Gap(16),
              Expanded(
                child: Elevation(
                  child: Row(
                    children: [
                      Expanded(child: _DisasterColumn(text: 'NEUE EVENTS:', disasters: game.newDisasters)),
                      const Gap(16),
                      Expanded(child: _DisasterColumn(text: 'ABGELAUFENE EVENTS:', disasters: game.finishedDisasters)),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Runde starten'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisasterColumn extends StatelessWidget {
  const _DisasterColumn({required this.text, required this.disasters});

  final String text;
  final Set<Disaster> disasters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text),
        const Gap(8),
        Expanded(
          child: Elevation(
            child: Column(
              children: [
                for (final disaster in disasters) ...[
                  _DisasterCard(disaster),
                  if (disaster != disasters.last) const Gap(4),
                ],
                if (disasters.isEmpty) const SizedBox(width: double.infinity, child: Text('Leer...', textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DisasterCard extends StatelessWidget {
  const _DisasterCard(this.disaster);

  final Disaster disaster;

  @override
  Widget build(BuildContext context) {
    return Elevation(
      child: Row(
        children: [
          Icon(disaster.icon),
          const Gap(4),
          Text(disaster.name),
          const Spacer(),
          Text('(STF. ${disaster.level})'),
        ],
      ),
    );
  }
}
