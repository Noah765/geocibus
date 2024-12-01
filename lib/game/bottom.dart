import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/widgets/elevation.dart';

class GameBottom extends StatelessWidget {
  const GameBottom({
    super.key,
    required this.money,
    required this.water,
    required this.food,
    this.allowTrading = false,
  });

  final int money;
  final int water;
  final int food;
  final bool allowTrading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Elevation(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: money.toString()),
                const WidgetSpan(child: Icon(Icons.money, color: Colors.black)),
                TextSpan(text: water.toString()),
                const WidgetSpan(child: Icon(Icons.water)),
                TextSpan(text: food.toString()),
                const WidgetSpan(child: Icon(Icons.food_bank)),
              ],
            ),
          ),
        ),
        if (allowTrading) ...[
          const Gap(8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.currency_exchange),
          ),
        ],
      ],
    );
  }
}
