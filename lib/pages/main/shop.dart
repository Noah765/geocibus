import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/theme.dart';
import 'package:geocibus/widgets/bidirectional_slider.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:geocibus/widgets/icon_span.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:provider/provider.dart';

class MainShop extends StatelessWidget {
  const MainShop({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();

    final resourcesStyle = Theme.of(context).textTheme.headlineMedium!;
    final height = (MediaQuery.textScalerOf(context).scale(resourcesStyle.fontSize!) * resourcesStyle.height!).roundToDouble() + getTextPadding(context, resourcesStyle, 3, 2).vertical;

    return Popup(
      direction: Direction.up,
      builder: (context, data) => _Popup(game),
      child: Button.icon(
        icon: FontAwesomeIcons.arrowRightArrowLeft,
        size: (height + 14) / 3,
        onPressed: () {},
      ),
    );
  }
}

class _Popup extends StatefulWidget {
  const _Popup(this.game);

  final Game game;

  @override
  State<_Popup> createState() => _PopupState();
}

class _PopupState extends State<_Popup> {
  var _water = 0.0;
  var _food = 0.0;

  int get _waterMaxPossible => (widget.game.money - _food.round() * widget.game.foodPrice) ~/ widget.game.waterPrice;
  int get _foodMaxPossible => (widget.game.money - _water.round() * widget.game.waterPrice) ~/ widget.game.foodPrice;
  double get _waterMax => max(_waterMaxPossible.toDouble(), widget.game.additionalWaterMaximum.toDouble());
  double get _foodMax => max(_foodMaxPossible.toDouble(), widget.game.additionalFoodMaximum.toDouble());
  int get _waterForFoodMax => (-(widget.game.additionalFoodMaximum * widget.game.foodPrice - widget.game.money) / widget.game.waterPrice).ceil();
  int get _foodForWaterMax => (-(widget.game.additionalWaterMaximum * widget.game.waterPrice - widget.game.money) / widget.game.foodPrice).ceil();

  void _updateValue(VoidCallback callback) {
    setState(() => callback());
    _water = min(_water, _waterMax);
    _food = min(_food, _foodMax);
  }

  int get _costs => (_water.round() * widget.game.waterPrice).ceil() + (_food.round() * widget.game.foodPrice).ceil();

  void _trade() {
    widget.game.trade(_water.round(), _food.round());
    setState(() {
      _water = 0;
      _food = 0;
    });
  }

  String _formatMoney(double value) => value.toStringAsFixed(2).replaceFirst('.', ',');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconSize = MediaQuery.textScalerOf(context).scale(20);
    final sliderHeight = iconSize + getIconPadding(context, iconSize, 3).vertical;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Markt', style: textTheme.headlineLarge),
        const Gap(4),
        Text.rich(
          style: textTheme.titleMedium,
          TextSpan(
            children: [
              TextSpan(text: _formatMoney(widget.game.waterPrice), children: [IconSpan(icon: FontAwesomeIcons.dollarSign)], style: const TextStyle(color: Colors.red)),
              const TextSpan(text: ' ↔ '),
              TextSpan(text: '1', children: [IconSpan(icon: FontAwesomeIcons.glassWater)], style: const TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Text.rich(
          style: textTheme.titleMedium,
          TextSpan(
            children: [
              TextSpan(text: _formatMoney(widget.game.foodPrice), children: [IconSpan(icon: FontAwesomeIcons.dollarSign)], style: const TextStyle(color: Colors.red)),
              const TextSpan(text: ' ↔ '),
              TextSpan(text: '1', children: [IconSpan(icon: FontAwesomeIcons.bowlFood, removedTop: 4, removedBottom: 5)], style: const TextStyle(color: Colors.green)),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(children: [IconCard(icon: FontAwesomeIcons.glassWater, size: 20), Gap(8), IconCard(icon: FontAwesomeIcons.bowlFood, size: 20)]),
            const Gap(16),
            Expanded(
              child: Column(
                children: [
                  const Row(children: [Text('Verkaufen'), Spacer(), Text('Kaufen')]),
                  SizedBox(
                    height: sliderHeight,
                    child: SnappingSlider.bidirectional(
                      value: _water,
                      secondaryTrackValueRight: _waterMaxPossible.toDouble(),
                      onChanged: (value) => _updateValue(() => _water = value),
                      snapValues: [-widget.game.water.toDouble(), _waterForFoodMax.toDouble(), 0, _waterMaxPossible.toDouble(), widget.game.additionalWaterMaximum.toDouble()],
                      leftMax: widget.game.water.toDouble(),
                      rightMax: _waterMax,
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    height: sliderHeight,
                    child: SnappingSlider.bidirectional(
                      value: _food,
                      secondaryTrackValueRight: _foodMaxPossible.toDouble(),
                      onChanged: (value) => _updateValue(() => _food = value),
                      snapValues: [-widget.game.food.toDouble(), _foodForWaterMax.toDouble(), 0, _foodMaxPossible.toDouble(), widget.game.additionalFoodMaximum.toDouble()],
                      leftMax: widget.game.food.toDouble(),
                      rightMax: _foodMax,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            const Column(children: [IconCard(icon: FontAwesomeIcons.glassWater, size: 20), Gap(8), IconCard(icon: FontAwesomeIcons.bowlFood, size: 20)]),
          ],
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: _costs < 0 ? 'Profit: ' : 'Preis: '),
              TextSpan(text: _costs.abs().toString(), children: [IconSpan(icon: FontAwesomeIcons.dollarSign)], style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const Gap(24),
        Button(
          text: 'Handeln',
          style: textTheme.titleMedium,
          onPressed: _costs <= widget.game.money ? _trade : null,
        ),
      ],
    );
  }
}
