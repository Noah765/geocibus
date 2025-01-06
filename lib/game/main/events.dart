import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:provider/provider.dart';

class MainEvents extends StatefulWidget {
  const MainEvents({super.key});

  @override
  State<MainEvents> createState() => _MainEventsState();
}

class _MainEventsState extends State<MainEvents> {
  final _columnKey = GlobalKey();

  RenderFlex _getColumnRenderFlex() => _columnKey.currentContext!.findRenderObject()! as RenderFlex;

  (int index, RenderBox renderBox) _getRenderBoxAt(Offset position) {
    final renderFlex = _getColumnRenderFlex();
    final globalPosition = renderFlex.localToGlobal(position);
    return renderFlex.getChildrenAsList().indexed.firstWhere((e) => e.$2.hitTest(BoxHitTestResult(), position: e.$2.globalToLocal(globalPosition)));
  }

  (Offset, Direction) _getPopupData(Offset position) {
    final (_, eventRenderBox) = _getRenderBoxAt(position);
    final globalOffset = eventRenderBox.localToGlobal(Offset.zero).translate(eventRenderBox.size.width, eventRenderBox.size.height / 2);
    return (_getColumnRenderFlex().globalToLocal(globalOffset), Direction.right);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();
    final textTheme = Theme.of(context).textTheme;

    return Popup(
      fixOnTap: false,
      getPopupData: _getPopupData,
      popupBuilder: (context, position) {
        final event = game.activeEvents[_getRenderBoxAt(position).$1 ~/ 2];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
        );
      },
      child: Column(
        key: _columnKey,
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
      ),
    );
  }
}

class _Event extends StatelessWidget {
  const _Event(this.event);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FaIcon(event.icon),
      ),
    );
  }
}
