import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:geocibus/widgets/icon_span.dart';
import 'package:geocibus/widgets/resource_indicator.dart';
import 'package:provider/provider.dart';

class InteractResources extends StatelessWidget {
  const InteractResources({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();
    final region = context.read<Region>();
    final textTheme = Theme.of(context).textTheme;

    return ContainerCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(region.name, style: textTheme.headlineSmall),
              ResourceIndicator(region),
            ],
          ),
          const Gap(32),
          Column(
            children: [
              Text('Du', style: textTheme.headlineSmall),
              Text.rich(
                style: textTheme.titleLarge!.copyWith(color: Colors.blue),
                TextSpan(
                  children: [
                    TextSpan(text: game.water.toString()),
                    IconSpan(icon: FontAwesomeIcons.glassWater),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: textTheme.titleLarge!.copyWith(color: Colors.green),
                  children: [
                    TextSpan(text: game.food.toString()),
                    IconSpan(icon: FontAwesomeIcons.bowlFood, removedTop: 4, removedBottom: 5),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
