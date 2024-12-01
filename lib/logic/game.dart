import 'dart:math';

import 'package:sowi/constants.dart';
import 'package:sowi/logic/disaster.dart';
import 'package:sowi/logic/region.dart';

class Game {
  Game() {
    food = calculateTotalRequiredFood();
    water = calculateTotalRequiredWater();
  }

  final regions = [
    Europe(),
    Asia(),
    NorthAmerica(),
    SouthAmerica(),
    Africa(),
    Australia(),
  ];

  int round = 1;
  int movesLeft = numberOfMoves;

  late int food;
  late int water;
  int money = 500;

  double foodExchangeRate = 1;
  double waterExchangeRate = 1;

  int generatedFood = 10;
  int generatedWater = 10;
  int generatedMoney = 10;
  double moneyMultiplicationRate = 1.1;

  final activeDisasters = <Disaster>{};
  final newDisasters = <Disaster>{};
  final finishedDisasters = <Disaster>{};

  int calculateTotalRequiredFood() => regions.fold(0, (sum, x) => sum + x.requiredFood);
  int calculateTotalRequiredWater() => regions.fold(0, (sum, x) => sum + x.requiredWater);

  Region selectRandomRegion() => regions[Random().nextInt(regions.length)];

  void distributeResources(Region region, int food, int water) {
    this.food -= food;
    this.water -= water;

    region.food += food;
    region.water += water;
  }

  void exchangeResources(int buyFood, int sellFood, int buyWater, int sellWater) {
    food = food + buyFood - sellFood;
    water = water + buyWater - sellWater;
    money = money - (buyFood / foodExchangeRate).round() + (sellFood / foodExchangeRate).round() - (buyWater / waterExchangeRate).round() + (sellWater / waterExchangeRate).round();
  }

  void finishRound() {
    round++;

    food += generatedFood;
    water += generatedWater;
    money += generatedMoney;
    money = (money * moneyMultiplicationRate).round();

    newDisasters.clear();
    finishedDisasters.clear();

    for (final disaster in activeDisasters) {
      disaster.round++;
      if (disaster.duration < disaster.round) {
        activeDisasters.remove(disaster);
        finishedDisasters.add(disaster);
      } else {
        disaster.apply(this);
      }
    }

    final random = Random();
    if (random.nextBool()) {
      final disaster = [NatureDisaster(1), InflationDisaster(1)][random.nextInt(2)];
      newDisasters.add(disaster);
      activeDisasters.add(disaster);
      disaster.apply(this);
    }
  }
}
