import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sowi/game.dart';

class InteractPage extends StatefulWidget {
  const InteractPage(this.region, {super.key});

  final Region region;

  @override
  State<InteractPage> createState() => _InteractPageState();
}

class _InteractPageState extends State<InteractPage> {
  var _foodSliderValue = 0.0;
  var _waterSliderValue = 0.0;

  void _submit() {
    context.read<Game>().distributeResources(widget.region, _foodSliderValue.round(), _waterSliderValue.round());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();

    return Scaffold(
      appBar: AppBar(title: Text('Interaktion. Runde ${game.round}')),
      body: Row(
        children: [
          const Placeholder(),
          Text('Du besitzt ${game.food} Essen und ${game.water} Wasser'),
          SliderTheme(
            data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
            child: Column(
              children: [
                const Text('Essen'),
                Slider(
                  value: _foodSliderValue,
                  onChanged: (value) => setState(() => _foodSliderValue = value),
                  max: game.food.toDouble(),
                  label: _foodSliderValue.round().toString(),
                ),
                const Text('Wasser'),
                Slider(
                  value: _waterSliderValue,
                  onChanged: (value) => setState(() => _waterSliderValue = value),
                  max: game.water.toDouble(),
                  label: _waterSliderValue.round().toString(),
                ),
                ElevatedButton(onPressed: _submit, child: const Text('Absenden')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
