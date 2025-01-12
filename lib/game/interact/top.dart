import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/settings_button.dart';
import 'package:provider/provider.dart';

class InteractTop extends StatelessWidget {
  const InteractTop({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();

    return Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: Navigator.of(context).pop,
          tooltip: 'Zurück zur Karte',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text('${game.month} des Jahres ${game.round}/10'),
          ),
        ),
        const Spacer(),
        const SettingsButton(),
      ],
    );
  }
}
