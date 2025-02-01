import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/game/interact/character.dart';
import 'package:geocibus/game/interact/chat.dart';
import 'package:geocibus/game/interact/resources.dart';
import 'package:geocibus/game/interact/top.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:provider/provider.dart';

class InteractPage extends StatelessWidget {
  const InteractPage({super.key, required this.game, required this.region});

  final Game game;
  final Region region;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: game), Provider.value(value: region)],
      child: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              InteractTop(),
              Gap(8),
              Expanded(
                child: Row(
                  children: [
                    InteractCharacter(),
                    Gap(16),
                    InteractResources(),
                    Gap(16),
                    Expanded(child: Chat()),
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
