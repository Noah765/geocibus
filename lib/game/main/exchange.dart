import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:geocibus/widgets/resource_sliders.dart';
import 'package:provider/provider.dart';

class MainExchange extends StatelessWidget {
  const MainExchange({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();

    return Popup(
      direction: Direction.up,
      builder: (context, data) => _Popup(game),
      child: IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.arrowRightArrowLeft)),
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
  late final ResourceSlidersController _controller;
  late final WidgetStatesController _finishButtonController;

  @override
  void initState() {
    super.initState();
    _controller = ResourceSlidersController();
    _finishButtonController = WidgetStatesController();
    _controller.water.addListener(() => _finishButtonController.update(WidgetState.disabled, !isTradePossible));
    _controller.food.addListener(() => _finishButtonController.update(WidgetState.disabled, !isTradePossible));
  }

  @override
  void dispose() {
    _controller.dispose();
    _finishButtonController.dispose();
    super.dispose();
  }

  bool get isTradePossible => (_controller.water.value * widget.game.waterPrice).round() + (_controller.food.value * widget.game.foodPrice).round() <= widget.game.money;

  void _onFinish() {
    widget.game.exchangeResources(_controller.water.value, _controller.food.value);
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Markt'),
        ResourceSliders(
          controller: _controller,
          leftText: 'Verkaufen',
          rightText: 'Kaufen',
          waterLeftMax: widget.game.water,
          waterRightMax: (widget.game.money / widget.game.waterPrice).round(),
          foodLeftMax: widget.game.food,
          foodRightMax: (widget.game.money / widget.game.foodPrice).round(),
        ),
        if (!isTradePossible) const Text('Handel nicht möglich'),
        ElevatedButton(
          onPressed: _onFinish,
          statesController: _finishButtonController,
          child: const Text('Fertig'),
        ),
      ],
    );
  }
}
