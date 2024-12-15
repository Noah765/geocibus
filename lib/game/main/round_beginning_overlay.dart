import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/models/event.dart';
import 'package:sowi/models/game.dart';
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
                child: Text('RUNDE ${game.round + 1}', style: theme.textTheme.displaySmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const Gap(16),
              Expanded(
                child: Elevation(
                  child: Row(
                    children: [
                      Expanded(child: _EventColumn(text: 'NEUE EVENTS:', events: game.newEvents)),
                      const Gap(16),
                      Expanded(child: _EventColumn(text: 'ABGELAUFENE EVENTS:', events: game.finishedEvents)),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: () {
                  game.startRound();
                  Navigator.of(context).pop();
                },
                child: const Text('Runde starten'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventColumn extends StatelessWidget {
  const _EventColumn({required this.text, required this.events});

  final String text;
  final Set<Event> events;

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
                for (final event in events) ...[
                  _EventCard(event),
                  if (event != events.last) const Gap(4),
                ],
                if (events.isEmpty) const SizedBox(width: double.infinity, child: Text('Leer...', textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard(this.event);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Elevation(
      child: Row(
        children: [
          Icon(event.icon),
          const Gap(4),
          Text(event.name),
          const Spacer(),
          Text('(STF. ${event.level})'),
        ],
      ),
    );
  }
}
