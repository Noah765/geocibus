import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/menus/main.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/settings_button.dart';
import 'package:provider/provider.dart';

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
                icon: const Icon(FontAwesomeIcons.rightFromBracket, size: 24),
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainMenu())),
                tooltip: 'Zurück zum Hauptmenü',
              ),
              const Gap(8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
