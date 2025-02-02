import 'dart:math';

import 'package:geocibus/models/event.dart';

const _maximumPopulationGrowthRate = 0.1;
const _foodPerPerson = 2.2;

sealed class Region {
  Region({
    required this.name,
    required this.character,
    required this.startPopulation,
    required this.defaultPopulationGrowthRate,
    required this.waterPerPerson,
    required this.foodGenerationRate,
    required this.waterGenerationRate,
  });

  final String name;
  final String character;

  final int startPopulation;
  late int population = startPopulation;
  final double defaultPopulationGrowthRate;

  late int food = generatedFood;
  late int water = generatedWater;
  final double waterPerPerson;
  double foodGenerationRate;
  double waterGenerationRate;

  Set<Event> exportBlockingEvents = {};
  bool get isExportBlocked => exportBlockingEvents.isNotEmpty;

  int get requiredWater => (population * waterPerPerson).ceil();
  int get requiredFood => (population * _foodPerPerson).ceil();
  int get maximumWater => (population * (1 + _maximumPopulationGrowthRate) * waterPerPerson).ceil();
  int get maximumFood => (population * (1 + _maximumPopulationGrowthRate) * _foodPerPerson).ceil();

  int get generatedWater => (waterGenerationRate * population).floor();
  int get generatedFood => (log(population / startPopulation + 1) * startPopulation * foodGenerationRate).floor();

  ResourceState get waterState => switch (water / requiredWater) {
        >= 1.1 => ResourceState.good,
        >= 0.9 => ResourceState.normal,
        >= 0.5 => ResourceState.bad,
        _ => ResourceState.panic,
      };
  ResourceState get foodState => switch (food / requiredFood) {
        >= 1.1 => ResourceState.good,
        >= 0.9 => ResourceState.normal,
        >= 0.5 => ResourceState.bad,
        _ => ResourceState.panic,
      };

  ResourceTrend waterTrend = ResourceTrend.stable;
  ResourceTrend foodTrend = ResourceTrend.stable;

  void finishRound() {
    population = (min(population * (1 + _maximumPopulationGrowthRate), min(food / _foodPerPerson, water / waterPerPerson)) * (1 + defaultPopulationGrowthRate)).floor();

    final newWater = water - requiredWater + generatedWater;
    final newFood = food - requiredFood + generatedFood;

    waterTrend = switch (newWater / water) {
      > 1.1 => ResourceTrend.rising,
      > 0.9 => ResourceTrend.stable,
      _ => ResourceTrend.falling,
    };
    foodTrend = switch (newFood / food) {
      > 1.1 => ResourceTrend.rising,
      > 0.9 => ResourceTrend.stable,
      _ => ResourceTrend.falling,
    };

    water = newWater;
    food = newFood;
  }
}

enum ResourceState { good, normal, bad, panic }

enum ResourceTrend { rising, stable, falling }

class Europe extends Region {
  Europe()
      : super(
          name: 'Europa',
          character: 'europe.png',
          startPopulation: 746,
          defaultPopulationGrowthRate: -0.001,
          waterPerPerson: 5,
          waterGenerationRate: 7,
          foodGenerationRate: 3.555,
        );
}

class Asia extends Region {
  Asia()
      : super(
          name: 'Asien',
          character: 'asia.png',
          startPopulation: 4778,
          defaultPopulationGrowthRate: 0.0058,
          waterPerPerson: 8,
          waterGenerationRate: 6,
          foodGenerationRate: 2.944,
        );
}

class NorthAmerica extends Region {
  NorthAmerica()
      : super(
          name: 'Nordamerika',
          character: 'north-america.png',
          startPopulation: 383,
          defaultPopulationGrowthRate: 0.0056,
          waterPerPerson: 10,
          waterGenerationRate: 15,
          foodGenerationRate: 3.881,
        );
}

class SouthAmerica extends Region {
  SouthAmerica()
      : super(
          name: 'Südamerika',
          character: 'south-america.png',
          startPopulation: 659,
          defaultPopulationGrowthRate: 0.0065,
          waterPerPerson: 5,
          waterGenerationRate: 7,
          foodGenerationRate: 3.111,
        );
}

class Africa extends Region {
  Africa()
      : super(
          name: 'Afrika',
          character: 'africa.png',
          startPopulation: 1481,
          defaultPopulationGrowthRate: 0.0226,
          waterPerPerson: 10,
          waterGenerationRate: 6,
          foodGenerationRate: 2.567,
        );
}

class Australia extends Region {
  Australia()
      : super(
          name: 'Australien',
          character: 'australia.png',
          startPopulation: 46,
          defaultPopulationGrowthRate: 0.0111,
          waterPerPerson: 9,
          waterGenerationRate: 5,
          foodGenerationRate: 3.6,
        );
}
