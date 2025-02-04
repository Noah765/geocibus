import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/pages/sources.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:provider/provider.dart';

class InteractTop extends StatelessWidget {
  const InteractTop({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();

    return Row(
      children: [
        Button.icon(
          icon: FontAwesomeIcons.arrowLeft,
          tooltip: 'Zurück zur Karte',
          onPressed: Navigator.of(context).pop,
        ),
        const Gap(8),
        TextCard(text: '${game.month} des Jahres ${game.round}/10', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Button.icon(icon: FontAwesomeIcons.info, tooltip: 'Quellen', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SourcesPage()))),
      ],
    );
  }
}
