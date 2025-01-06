import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/resource_sliders.dart';

class InteractDistribute extends StatefulWidget {
  const InteractDistribute({super.key, required this.region});

  final Region region;

  @override
  State<InteractDistribute> createState() => _InteractDistributeState();
}

class _InteractDistributeState extends State<InteractDistribute> {
  var _water = 0;
  var _food = 0;

  void _onConfirm() {}

  void _onCancel() {}

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();

    return Column(
      children: [
        ResourceSliders(
          leftText: 'Anfragen',
          rightText: 'Abgeben',
          waterLeftMax: widget.region.water,
          waterRightMax: game.water,
          onWaterChanged: (value) => _water = value,
          foodLeftMax: widget.region.food,
          foodRightMax: game.food,
          onFoodChanged: (value) => _food = value,
        ),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: _onConfirm, child: const Text('Abschließen'))),
            Expanded(child: OutlinedButton(onPressed: _onCancel, child: const Text('Abbrechen'))),
          ],
        ),
      ],
    );
  }
}
