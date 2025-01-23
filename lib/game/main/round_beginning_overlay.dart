import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/icon_span.dart';

class RoundBeginningOverlay extends StatelessWidget {
  const RoundBeginningOverlay(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text('Jahr ${game.round + 1}', style: theme.textTheme.displayMedium),
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
                        Expanded(child: _EventColumn(text: 'Neue Events', events: game.newEvents)),
                        const Gap(16),
                        Expanded(child: _EventColumn(text: 'Abgelaufene Events', events: game.finishedEvents)),
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
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(theme.textTheme.titleLarge),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outline, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                visualDensity: const VisualDensity(horizontal: 2, vertical: 2),
              ),
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
        Text(text, style: textTheme.titleLarge),
        const Gap(8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  for (final event in events) ...[
                    _EventCard(event),
                    if (event != events.last) const Gap(12 - 3),
                  ],
                  if (events.isEmpty) const Expanded(child: Center(child: Text('Leer...'))),
                ],
              ),
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
    final titleStyle = Theme.of(context).textTheme.titleLarge!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text.rich(
              TextSpan(children: [IconSpan(icon: event.icon), TextSpan(text: ' ${event.name} (Lvl. ${event.level})')]),
              style: titleStyle,
            ),
            const Gap(4),
            Text(event.description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
