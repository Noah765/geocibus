import 'package:flutter/material.dart';

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

  void distributeResources(Region region, int food, int water) {
    this.food -= food;
    this.water -= water;

    region
      ..food += food
      ..water += water;

    notifyListeners();
  }
}
