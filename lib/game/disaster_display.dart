import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/logic/disaster.dart';
import 'package:sowi/widgets/elevation.dart';

class GameDisasterDisplay extends StatelessWidget {
  const GameDisasterDisplay(this.disasters, {super.key});

  final Set<Disaster> disasters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final disaster in disasters) ...[
          Elevation(child: Icon(disaster.icon)),
          if (disaster != disasters.last) const Gap(8),
        ],
      ],
    );
  }
}
