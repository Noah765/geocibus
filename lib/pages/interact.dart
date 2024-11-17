import 'package:flutter/material.dart';
import 'package:sowi/logic/game.dart';
import 'package:sowi/logic/region.dart';
import 'package:sowi/pages/map.dart';

class InteractPage extends StatefulWidget {
  const InteractPage(this.region, {super.key});

  final Region region;

  @override
  State<InteractPage> createState() => _InteractPageState();
}

class _InteractPageState extends State<InteractPage> {
  var _foodSliderValue = 0.0;
  var _waterSliderValue = 0.0;

  void _submit() => game.distributeResources(widget.region, _foodSliderValue.round(), _waterSliderValue.round());

  void _gotoMapPage() => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MapPage()));

  @override
  Widget build(BuildContext context) {
    final region = widget.region;

    return Scaffold(
      appBar: AppBar(title: Text('Interaktion. Runde ${game.round}')),
      body: Row(
        children: [
          const Placeholder(),
          Text('Du besitzt ${game.food} Essen und ${game.water} Wasser'),
          Text('${region.name} besitzt ${region.food} Essen und ${game.water} Wasser'),
          SliderTheme(
            data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
            child: Column(
              children: [
                const Text('Essen'),
                Slider(
                  value: _foodSliderValue,
                  onChanged: (value) => setState(() => _foodSliderValue = value),
                  min: -region.food.toDouble(),
                  max: game.food.toDouble(),
                  label: _foodSliderValue.round().toString(),
                ),
                const Text('Wasser'),
                Slider(
                  value: _waterSliderValue,
                  onChanged: (value) => setState(() => _waterSliderValue = value),
                  min: -region.water.toDouble(),
                  max: game.water.toDouble(),
                  label: _waterSliderValue.round().toString(),
                ),
                ElevatedButton(onPressed: _submit, child: const Text('Absenden')),
                ElevatedButton(onPressed: _gotoMapPage, child: const Text('Abbrechen')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
