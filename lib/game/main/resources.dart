import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/icon_span.dart';
import 'package:provider/provider.dart';

class MainResources extends StatelessWidget {
  const MainResources({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();
    final textStyle = Theme.of(context).textTheme.headlineMedium!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Tooltip(
              message: 'Geld',
              child: Text.rich(
                TextSpan(
                  text: game.money.toString(),
                  children: [IconSpan(icon: FontAwesomeIcons.dollarSign)],
                  style: textStyle.copyWith(color: Colors.red),
                ),
              ),
            ),
            const Gap(16),
            Tooltip(
              message: 'Wasser',
              child: Text.rich(
                TextSpan(
                  text: game.water.toString(),
                  children: [IconSpan(icon: FontAwesomeIcons.glassWater)],
                  style: textStyle.copyWith(color: Colors.blue),
                ),
              ),
            ),
            const Gap(16),
            Tooltip(
              message: 'Essen',
              child: Text.rich(
                TextSpan(
                  text: game.food.toString(),
                  children: [IconSpan(icon: FontAwesomeIcons.bowlFood, removedTop: 4, removedBottom: 5)],
                  style: textStyle.copyWith(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
