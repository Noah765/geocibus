import 'dart:math';

import 'package:sowi/logic/disaster.dart';
import 'package:sowi/logic/region.dart';

final game = Game();
const numberOfRounds = 10;

class Game {
  int round = 1;

  int food = 100;
  int water = 100;
  int money = 100;

  double foodExchangeRate = 1;
  double waterExchangeRate = 1;

  int generatedFood = 10;
  int generatedWater = 10;
  int generatedMoney = 10;
  double moneyMultiplicationRate = 1.1;

  Disaster? newDisaster;
  final activeDisasters = <Disaster>{};

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

    for (final disaster in activeDisasters) {
      disaster.round++;
      if (disaster.duration < disaster.round) {
        activeDisasters.remove(disaster);
      } else {
        disaster.apply();
      }
    }

    newDisaster = null;
    final random = Random();
    if (random.nextBool()) {
      final disaster = [NatureDisaster(), InflationDisaster()][random.nextInt(2)];
      newDisaster = disaster;
      activeDisasters.add(disaster);
      disaster.apply();
    }
  }
}
