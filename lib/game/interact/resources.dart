import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/constants.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/resource_indicator.dart';
import 'package:provider/provider.dart';

class InteractResources extends StatelessWidget {
  const InteractResources({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();
    final region = context.read<Region>();
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  style: textTheme.titleLarge!.copyWith(color: waterColor),
                  TextSpan(
                    children: [
                      TextSpan(text: game.water.toString()),
                      WidgetSpan(
                        child: FaIcon(waterIcon, size: textTheme.titleLarge!.fontSize, color: waterColor),
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: textTheme.titleLarge!.copyWith(color: foodColor),
                    children: [
                      TextSpan(text: game.food.toString()),
                      WidgetSpan(
                        child: FaIcon(foodIcon, size: textTheme.titleLarge!.fontSize, color: foodColor),
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
