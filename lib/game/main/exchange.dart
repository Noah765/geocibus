import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/bidirectional_slider.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:provider/provider.dart';

class MainExchange extends StatelessWidget {
  const MainExchange({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();

    return Popup(
      direction: Direction.up,
      builder: (context, data) => _Popup(game),
      child: IconButton(
        onPressed: () {},
        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(14))),
        icon: const Icon(FontAwesomeIcons.arrowRightArrowLeft, size: 24),
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

  bool get _isExchangePossible => (_water.round() * widget.game.waterPrice).ceil() + (_food.round() * widget.game.foodPrice).ceil() <= widget.game.money;

  void _exchange() {
    widget.game.exchangeResources(_water.round(), _food.round());
    setState(() {
      _water = 0;
      _food = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sliderHeight = MediaQuery.textScalerOf(context).scale(24) + 20;

    const resourceDisplay = Column(
      children: [
        Card(child: Padding(padding: EdgeInsets.all(10), child: Icon(FontAwesomeIcons.glassWater, size: 24))),
        Gap(8),
        Card(child: Padding(padding: EdgeInsets.all(10), child: Icon(FontAwesomeIcons.bowlFood, size: 24))),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Markt', style: textTheme.headlineMedium),
        const Gap(8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            resourceDisplay,
            const Gap(16),
            Expanded(
              child: Column(
                children: [
                  const Row(children: [Text('Verkaufen'), Spacer(), Text('Kaufen')]),
                  SizedBox(
                    height: sliderHeight,
                    child: BidirectionalSlider(
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
                    child: BidirectionalSlider(
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
            resourceDisplay,
          ],
        ),
        const Gap(16),
        ElevatedButton(
          onPressed: _isExchangePossible ? _exchange : null,
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(textTheme.titleMedium),
            visualDensity: VisualDensity.standard,
          ),
          child: const Text('Handeln'),
        ),
      ],
    );
  }
}
