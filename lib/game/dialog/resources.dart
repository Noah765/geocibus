import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sowi/constants.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/models/region.dart';
import 'package:sowi/widgets/elevation.dart';

class DialogResources extends StatelessWidget {
  const DialogResources(this.region, {super.key});

  final Region region;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();

    return Elevation(
      child: Row(
        children: [
          Column(
            children: [
              Text(region.name),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: region.water.toString()),
                    const WidgetSpan(child: FaIcon(waterIcon)),
                    TextSpan(text: region.maximumFood.toString()),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: region.food.toString()),
                    const WidgetSpan(child: FaIcon(foodIcon)),
                    TextSpan(text: region.maximumWater.toString()),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Column(
            children: [
              const Text('Du'),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: game.water.toString()),
                    const WidgetSpan(child: FaIcon(waterIcon)),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: game.food.toString()),
                    const WidgetSpan(child: FaIcon(foodIcon)),
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
