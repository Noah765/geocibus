import 'package:flutter/material.dart';
import 'package:sowi/logic/game.dart';
import 'package:sowi/pages/map.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  var _buyFoodSliderValue = 0.0;
  var _sellFoodSliderValue = 0.0;
  var _buyWaterSliderValue = 0.0;
  var _sellWaterSliderValue = 0.0;

  void _submit() {
    setState(() {
      game.exchangeResources(_buyFoodSliderValue.round(), _sellFoodSliderValue.round(), _buyWaterSliderValue.round(), _sellWaterSliderValue.round());
      _buyFoodSliderValue = 0;
      _sellFoodSliderValue = 0;
      _buyWaterSliderValue = 0;
      _sellWaterSliderValue = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Du besitzt ${game.food} Essen, ${game.water} Wasser und ${game.money} Geld'),
          SliderTheme(
            data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
            child: Column(
              children: [
                Text('Essen kaufen (1 Geld zu ${game.foodExchangeRate} Essen)'),
                Slider(
                  value: _buyFoodSliderValue,
                  onChanged: (value) => setState(() => _buyFoodSliderValue = value),
                  max: (game.money * game.foodExchangeRate).roundToDouble(),
                  label: _buyFoodSliderValue.round().toString(),
                ),
                Text('Essen verkaufen (1 Essen zu ${1 / game.foodExchangeRate} Geld)'),
                Slider(
                  value: _sellFoodSliderValue,
                  onChanged: (value) => setState(() => _sellFoodSliderValue = value),
                  max: game.food.toDouble(),
                  label: _sellFoodSliderValue.round().toString(),
                ),
                Text('Wasser kaufen (1 zu ${game.waterExchangeRate})'),
                Slider(
                  value: _buyWaterSliderValue,
                  onChanged: (value) => setState(() => _buyWaterSliderValue = value),
                  max: (game.money * game.waterExchangeRate).roundToDouble(),
                  label: _buyWaterSliderValue.round().toString(),
                ),
                Text('Wasser verkaufen (1 Wasser zu ${1 / game.waterExchangeRate} Geld)'),
                Slider(
                  value: _sellWaterSliderValue,
                  onChanged: (value) => setState(() => _sellWaterSliderValue = value),
                  max: game.water.toDouble(),
                  label: _sellWaterSliderValue.round().toString(),
                ),
                ElevatedButton(
                  onPressed: _buyFoodSliderValue.round() / game.foodExchangeRate + _buyWaterSliderValue.round() / game.waterExchangeRate > game.money ? null : _submit,
                  child: const Text('Absenden'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MapPage())),
            child: const Text('Zurück zur Karte'),
          ),
        ],
      ),
    );
  }
}
