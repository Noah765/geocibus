import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/icon_span.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:provider/provider.dart';

class MainEvents extends StatelessWidget {
  const MainEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<Game>().activeEvents;

    return SizedBox(
      width: IconButtonTheme.of(context).style!.padding!.resolve({})!.horizontal + MediaQuery.textScalerOf(context).scale(IconTheme.of(context).size!),
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
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Popup(
      direction: Direction.right,
      builder: (context, data) => SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      child: IconButton(onPressed: () {}, icon: Icon(event.icon)),
    );
  }
}
