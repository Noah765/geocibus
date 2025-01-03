import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/widgets/resource_sliders.dart';

class MainExchange extends StatelessWidget {
  const MainExchange({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();

    return IconButton(
      icon: const FaIcon(FontAwesomeIcons.arrowRightArrowLeft),
      onPressed: () => showPopover(context: context, bodyBuilder: (context) => _Popover(game)),
      tooltip: 'Handeln',
    );
  }
}

class _Popover extends StatefulWidget {
  const _Popover(this.game);

  final Game game;

  @override
  State<_Popover> createState() => _PopoverState();
}

class _PopoverState extends State<_Popover> {
  var _water = 0;
  var _food = 0;

  late final WidgetStatesController _finishButtonController;

  @override
  void initState() {
    super.initState();
    _finishButtonController = WidgetStatesController();
  }

  @override
  void dispose() {
    _finishButtonController.dispose();
    super.dispose();
  }

  bool get isTradePossible => (_water * widget.game.waterPrice).round() + (_food * widget.game.foodPrice).round() <= widget.game.money;
  void _onWaterChanged(int value) {
    _water = value;
    setState(() => _finishButtonController.update(WidgetState.disabled, !isTradePossible));
  }

  void _onFoodChanged(int value) {
    _food = value;
    setState(() => _finishButtonController.update(WidgetState.disabled, !isTradePossible));
  }

  void _onFinish() {
    widget.game.exchangeResources(_water, _food);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(color: Colors.black),
      child: IconTheme.merge(
        data: const IconThemeData(color: Colors.black),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Markt'),
            ResourceSliders(
              leftText: 'Verkaufen',
              rightText: 'Kaufen',
              waterLeftMax: widget.game.water,
              waterRightMax: (widget.game.money / widget.game.waterPrice).round(),
              onWaterChanged: _onWaterChanged,
              foodLeftMax: widget.game.food,
              foodRightMax: (widget.game.money / widget.game.foodPrice).round(),
              onFoodChanged: _onFoodChanged,
            ),
            if (!isTradePossible) const Text('Handel nicht möglich'),
            OutlinedButton(
              onPressed: _onFinish,
              statesController: _finishButtonController,
              child: const Text('Fertig'),
            ),
          ],
        ),
      ),
    );
  }
}
