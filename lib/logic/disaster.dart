import 'package:sowi/logic/game.dart';

sealed class Disaster {
  int get minimumRound => 1;
  int get maximumRound => numberOfRounds;

  int get duration => 1;

  int round = 1;

  void apply();
}

class NatureDisaster extends Disaster {
  @override
  void apply() {
    final region = game.selectRandomRegion();
    region.food = (0.75 * region.food).round();
    region.water = (0.75 * region.water).round();
  }
}

class InflationDisaster extends Disaster {
  @override
  int get maximumRound => 7;

  @override
  int get duration => 3;

  @override
  void apply() {
    game.foodExchangeRate *= 1.1;
    game.waterExchangeRate *= 1.1;
  }
}
