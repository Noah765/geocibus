import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sowi/game/dialog/actions.dart';
import 'package:sowi/game/dialog/resources.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/models/region.dart';
import 'package:sowi/widgets/resource_sliders.dart';
import 'package:sowi/widgets/settings_button.dart';

class DialogPage extends StatefulWidget {
  const DialogPage({super.key, required this.game, required this.region});

  final Game game;
  final Region region;

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  var _water = 0;
  var _food = 0;

  void _onConfirm() {
    widget.game.distributeResources(widget.region, _water, _food);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.game,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                    onPressed: Navigator.of(context).pop,
                    tooltip: 'Zurück zur Karte',
                  ),
                  const Spacer(),
                  const SettingsButton(),
                ],
              ),
              Row(
                children: [
                  const Placeholder(),
                  Expanded(
                    child: Column(
                      children: [
                        DialogResources(widget.region),
                        ResourceSliders(
                          leftText: 'Anfragen',
                          rightText: 'Abgeben',
                          waterLeftMax: widget.region.water,
                          waterRightMax: widget.game.water,
                          onWaterChanged: (value) => _water = value,
                          foodLeftMax: widget.region.food,
                          foodRightMax: widget.game.food,
                          onFoodChanged: (value) => _food = value,
                        ),
                        DialogActions(onContinueDialog: () {}, onConfirm: _onConfirm),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
