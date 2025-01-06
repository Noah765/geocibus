import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:geocibus/game/interact/character.dart';
import 'package:geocibus/game/interact/chat.dart';
import 'package:geocibus/game/interact/resources.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/settings_button.dart';

class InteractPage extends StatelessWidget {
  const InteractPage({super.key, required this.game, required this.region});

  final Game game;
  final Region region;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: game), Provider.value(value: region)],
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                    onPressed: Navigator.of(context).pop,
                    tooltip: 'Zurück zur Karte',
                  ),
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Text('${game.month} des Jahres ${game.round}/10'),
                    ),
                  ),
                  const Spacer(),
                  const SettingsButton(),
                ],
              ),
              const Expanded(
                child: Row(
                  children: [
                    InteractCharacter(),
                    Expanded(
                      child: Column(
                        children: [
                          InteractResources(),
                          Gap(16),
                          Expanded(child: Chat()),
                        ],
                      ),
                      //child: Column(
                      //  children: [
                      //    const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: InteractMessage()), Gap(24), InteractResources()]),
                      //    if (!region.isTradeBlocked) InteractDistribute(region: region) else const Text('Handel blockiert'),
                      //  ],
                      //),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
