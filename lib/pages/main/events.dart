import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:geocibus/widgets/icon_span.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:provider/provider.dart';

class MainEvents extends StatelessWidget {
  const MainEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<Game>().activeEvents;

    return SizedBox(
      width: Button.getDefaultIconButtonWidth(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final event in events) ...[
            _Event(event),
            if (event != events.last) const Gap(8),
          ],
        ],
      ),
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
      clickable: false,
      direction: Direction.right,
      builder: (context, data) => SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(children: [IconSpan(icon: event.icon), TextSpan(text: ' ${event.name} (Lvl. ${event.level})')]),
              style: textTheme.titleLarge,
            ),
            const Gap(8),
            Text(event.description, textAlign: TextAlign.center),
            const Gap(8),
            Text(event.effects, style: textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
      child: IconCard(icon: event.icon),
    );
  }
}
