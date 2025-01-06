import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/constants.dart';
import 'package:geocibus/models/game.dart';
import 'package:provider/provider.dart';

class MainResources extends StatelessWidget {
  const MainResources({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();
    final textStyle = Theme.of(context).textTheme.titleLarge!;

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text.rich(
          // TODO Tooltips on hover resources
          // TODO Dollar icon for money
          // TODO Bigger bottom
          TextSpan(
            children: [
              TextSpan(text: game.money.toString(), style: textStyle.copyWith(color: moneyColor)),
              WidgetSpan(
                child: FaIcon(moneyIcon, size: textStyle.fontSize, color: moneyColor),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              ),
              TextSpan(text: ' ${game.water}', style: textStyle.copyWith(color: waterColor)),
              WidgetSpan(
                child: FaIcon(waterIcon, size: textStyle.fontSize, color: waterColor),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              ),
              TextSpan(text: ' ${game.food}', style: textStyle.copyWith(color: foodColor)),
              WidgetSpan(
                child: FaIcon(foodIcon, size: textStyle.fontSize, color: foodColor),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
