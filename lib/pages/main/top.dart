import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/pages/sources.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/pages/tutorial.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:provider/provider.dart';

class MainTop extends StatelessWidget {
  const MainTop({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();
    final textStyle = Theme.of(context).textTheme.titleMedium!;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Button.icon(
                icon: FontAwesomeIcons.rightFromBracket,
                tooltip: 'Zurück zum Hauptmenü',
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const StartPage())),
              ),
              const Gap(8),
              TextCard(text: '${game.month} des Jahres ${game.round}/10', style: textStyle),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextCard(text: 'Score: ${game.score}', style: textStyle),
              const Gap(8),
              if (kIsWeb || !Platform.isLinux) ...[
                Button.icon(
                  icon: FontAwesomeIcons.book,
                  tooltip: 'Tutorial',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TutorialPage(navigationTarget: TutorialNavigationTarget.back))),
                ),
                const Gap(8),
              ],
              Button.icon(icon: FontAwesomeIcons.info, tooltip: 'Quellen', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SourcesPage()))),
            ],
          ),
        ),
      ],
    );
  }
}
