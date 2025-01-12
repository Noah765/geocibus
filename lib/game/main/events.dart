import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:provider/provider.dart';

class MainEvents extends StatelessWidget {
  const MainEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // TODO Small shifts when events are shown (maybe icon sizes differ?)
        for (final event in game.activeEvents) ...[
          _Event(event),
          if (event != game.activeEvents.last) const Gap(8),
        ],
        if (game.activeEvents.isEmpty)
          Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: _Event(PandemicEvent(game: game, level: 1)),
          ),
      ],
    );
  }
}

class _Event extends StatelessWidget {
  const _Event(this.event);

  final Event event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Popup(
      direction: Direction.right,
      fixOnPressed: false,
      builder: (context, data) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO Size icon according to upper case letters
              FaIcon(event.icon, size: textTheme.titleLarge!.fontSize),
              const Gap(8),
              Text('${event.name} (Lvl. ${event.level})', style: textTheme.titleLarge),
            ],
          ),
          const Gap(4),
          Text(event.description, textAlign: TextAlign.center),
        ],
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FaIcon(event.icon),
        ),
      ),
    );
  }
}
