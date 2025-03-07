import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:geocibus/widgets/icon_span.dart';

class RoundBeginningOverlay extends StatelessWidget {
  const RoundBeginningOverlay(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SizedBox(
            width: 1200,
            height: 800,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextCard(text: 'Jahr ${game.round + 1}', style: theme.textTheme.displayMedium),
                const Gap(16),
                if (game.newEvents.isNotEmpty || game.finishedEvents.isNotEmpty) ...[
                  Expanded(
                    child: ContainerCard(
                      size: ContainerCardSize.large,
                      child: Row(
                        children: [
                          Expanded(child: _EventColumn(text: 'Neue Events', emptyText: 'Es sind keine neuen Events dazugekommen', events: game.newEvents)),
                          const Gap(24),
                          Expanded(child: _EventColumn(text: 'Abgelaufene Events', emptyText: 'Es sind keine Events abgelaufen', events: game.finishedEvents)),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                ],
                Button(
                  text: 'Jahr starten',
                  style: theme.textTheme.headlineMedium,
                  onPressed: () {
                    game.startRound();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventColumn extends StatelessWidget {
  const _EventColumn({required this.text, required this.emptyText, required this.events});

  final String text;
  final String emptyText;
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(text, style: textTheme.titleLarge),
        const Gap(12),
        Expanded(
          child: ContainerCard(
            size: ContainerCardSize.medium,
            child: events.isEmpty
                ? Center(child: Text(emptyText, textAlign: TextAlign.center))
                : ListView(
                    children: [
                      for (final event in events) ...[
                        _EventCard(event),
                        if (event != events.last) const Gap(12 - 3),
                      ],
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
    final textTheme = Theme.of(context).textTheme;

    return ContainerCard(
      size: ContainerCardSize.small,
      child: Column(
        children: [
          Text.rich(
            TextSpan(children: [IconSpan(icon: event.icon), TextSpan(text: ' ${event.name} (Lvl. ${event.level})')]),
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(event.description, textAlign: TextAlign.center),
          const Gap(8),
          Text(event.effects, style: textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
