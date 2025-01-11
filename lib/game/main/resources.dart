import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          // TODO Bigger bottom
          TextSpan(
            children: [
              TextSpan(text: game.money.toString(), style: textStyle.copyWith(color: Colors.red)),
              WidgetSpan(
                child: FaIcon(FontAwesomeIcons.dollarSign, size: textStyle.fontSize, color: Colors.red),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              ),
              TextSpan(text: ' ${game.water}', style: textStyle.copyWith(color: Colors.blue)),
              WidgetSpan(
                child: FaIcon(FontAwesomeIcons.glassWater, size: textStyle.fontSize, color: Colors.blue),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              ),
              TextSpan(text: ' ${game.food}', style: textStyle.copyWith(color: Colors.green)),
              WidgetSpan(
                child: FaIcon(FontAwesomeIcons.bowlFood, size: textStyle.fontSize, color: Colors.green),
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
