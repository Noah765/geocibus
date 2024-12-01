import 'package:sowi/constants.dart';

sealed class Region {
  Region({
    required this.name,
    required int startPopulation,
    required this.defaultPopulationGrowthRate,
    required this.foodPerPerson,
    required this.waterPerPerson,
  }) : population = startPopulation;

  final String name;

  int population;
  final double defaultPopulationGrowthRate;

  int food = 0;
  int water = 0;
  final double foodPerPerson;
  final double waterPerPerson;

  int get requiredFood => (population * foodPerPerson).round();
  int get requiredWater => (population * waterPerPerson).round();
  int get maximumFood => (population * (1 + maximumPopulationGrowthRate) * foodPerPerson).round();
  int get maximumWater => (population * (1 + maximumPopulationGrowthRate) * waterPerPerson).round();

  String reactTo(int food, int water);
}

class Europe extends Region {
  Europe() : super(name: 'Europa', startPopulation: 746, defaultPopulationGrowthRate: -0.001, foodPerPerson: 3.555, waterPerPerson: 3.555);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Asia extends Region {
  Asia() : super(name: 'Asien', startPopulation: 4778, defaultPopulationGrowthRate: 0.0058, foodPerPerson: 2.944, waterPerPerson: 2.944);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class NorthAmerica extends Region {
  NorthAmerica() : super(name: 'Nordamerika', startPopulation: 383, defaultPopulationGrowthRate: 0.0056, foodPerPerson: 3.881, waterPerPerson: 3.881);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class SouthAmerica extends Region {
  SouthAmerica() : super(name: 'Südamerika', startPopulation: 659, defaultPopulationGrowthRate: 0.0065, foodPerPerson: 3.111, waterPerPerson: 3.111);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Africa extends Region {
  Africa() : super(name: 'Afrika', startPopulation: 1481, defaultPopulationGrowthRate: 0.0226, foodPerPerson: 2.567, waterPerPerson: 2.567);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Australia extends Region {
  // TODO Missing actual numbers for food and water per person
  Australia() : super(name: 'Australien', startPopulation: 46, defaultPopulationGrowthRate: 0.0111, foodPerPerson: 3.6, waterPerPerson: 3.6);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}
