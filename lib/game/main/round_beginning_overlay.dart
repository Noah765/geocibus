import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';

class RoundBeginningOverlay extends StatelessWidget {
  const RoundBeginningOverlay(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text('Jahr ${game.round + 1}', style: textTheme.displaySmall!.copyWith()),
              ),
            ),
            const Gap(16),
            if (game.newEvents.isNotEmpty || game.finishedEvents.isNotEmpty) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(child: _EventColumn(text: 'Neue Events:', events: game.newEvents)),
                        const Gap(16),
                        Expanded(child: _EventColumn(text: 'Abgelaufene Events:', events: game.finishedEvents)),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(16),
            ],
            ElevatedButton(
              onPressed: () {
                game.startRound();
                Navigator.of(context).pop();
              },
              child: const Text('Jahr starten'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventColumn extends StatelessWidget {
  const _EventColumn({required this.text, required this.events});

  final String text;
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(text, style: textTheme.titleMedium),
        const Gap(8),
        Expanded(
          child: Card(
            child: Column(
              children: [
                for (final event in events) ...[
                  _EventCard(event),
                  if (event != events.last) const Gap(4),
                ],
                if (events.isEmpty) const Text('Leer...'),
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
    return Card(
      child: Row(
        children: [
          Icon(event.icon),
          const Gap(4),
          Text(event.name),
          const Spacer(),
          Text('(Lvl. ${event.level})'),
        ],
      ),
    );
  }
}
