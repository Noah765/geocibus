import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/settings_button.dart';

class MainTop extends StatelessWidget {
  const MainTop({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
                onPressed: Navigator.of(context).pop,
                tooltip: 'Zurück zum Hauptmenü',
              ),
              const Gap(8),
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text('${game.month} des Jahres ${game.round}/10'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text('Score: ${game.score}'),
                ),
              ),
              const Gap(8),
              const SettingsButton(),
            ],
          ),
        ),
      ],
    );
  }
}
