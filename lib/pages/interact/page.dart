import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/pages/interact/chat.dart';
import 'package:geocibus/pages/interact/resources.dart';
import 'package:geocibus/pages/interact/top.dart';
import 'package:provider/provider.dart';

const _characterAspectRatio = 258 / 607;

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
              const InteractTop(),
              const Gap(8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    children: [
                      if (constraints.maxWidth - constraints.maxHeight * _characterAspectRatio > 750) ...[
                        AspectRatio(
                          aspectRatio: _characterAspectRatio,
                          child: Image.asset('assets/characters/${context.read<Region>().character}', fit: BoxFit.fitHeight),
                        ),
                        const Gap(16),
                      ],
                      Expanded(
                        child: Flex(
                          direction: constraints.maxWidth - constraints.maxHeight * _characterAspectRatio < 1050 ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InteractResources(direction: constraints.maxWidth - constraints.maxHeight * _characterAspectRatio < 1050 ? Axis.horizontal : Axis.vertical),
                            const Gap(16),
                            const Expanded(child: Chat()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
