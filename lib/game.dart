import 'dart:math';

import 'package:flutter/material.dart';

const numberOfRounds = 10;

class Game extends ChangeNotifier {
  final regions = [
    Region(name: 'Europa', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Asien', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Nordamerika', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Südamerika', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Afrika', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Australien', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Ozeanien', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
    Region(name: 'Antarktis', startFood: 30, preferredFood: 100, startWater: 30, preferredWater: 100),
  ];

  int round = 1;

  int food = 100;
  int water = 100;
  int money = 100;

  final activeDisasters = <Disaster>{};

  Region selectRandomRegion() => regions[Random().nextInt(regions.length)];

  void distributeResources(Region region, int food, int water) {
    this.food -= food;
    this.water -= water;

    region
      ..food += food
      ..water += water;

    notifyListeners();
  }

  void finishRound() {
    round++;

    for (final disaster in activeDisasters) {
      disaster.round++;
      if (disaster.duration < disaster.round) {
        activeDisasters.remove(disaster);
      } else {
        disaster.apply(this);
      }
    }

    final random = Random();
    if (random.nextBool()) {
      final newDisaster = [NatureDisaster(), InflationDisaster()][random.nextInt(2)];
      activeDisasters.add(newDisaster);
      newDisaster.apply(this);
    }

    notifyListeners();
  }
}

class Region {
  Region({required this.name, required int startFood, required this.preferredFood, required int startWater, required this.preferredWater})
      : food = startFood,
        water = startWater;

  final String name;

  int food;
  final int preferredFood;

  int water;
  final int preferredWater;
}

sealed class Disaster {
  int get minimumRound => 1;
  int get maximumRound => numberOfRounds;

  int get duration => 1;

  int round = 1;

  void apply(Game game);
}

class NatureDisaster extends Disaster {
  @override
  void apply(Game game) {
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
  void apply(Game game) {}
}
