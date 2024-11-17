final regions = [Europe(), Asia(), NorthAmerica(), SouthAmerica(), Africa(), Australia(), Oceania(), Antarctica()];

sealed class Region {
  Region({required this.name, required int startFood, required this.preferredFood, required int startWater, required this.preferredWater})
      : food = startFood,
        water = startWater;

  final String name;

  int food;
  final int preferredFood;

  int water;
  final int preferredWater;

  String reactTo(int food, int water);
}

class Europe extends Region {
  Europe() : super(name: 'Europa', startFood: 75, preferredFood: 745, startWater: 75, preferredWater: 745);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Asia extends Region {
  Asia() : super(name: 'Asien', startFood: 470, preferredFood: 4695, startWater: 470, preferredWater: 4695);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class NorthAmerica extends Region {
  NorthAmerica() : super(name: 'Nordamerika', startFood: 60, preferredFood: 595, startWater: 60, preferredWater: 595);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class SouthAmerica extends Region {
  SouthAmerica() : super(name: 'Südamerika', startFood: 43, preferredFood: 434, startWater: 43, preferredWater: 434);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Africa extends Region {
  Africa() : super(name: 'Afrika', startFood: 139, preferredFood: 1394, startWater: 139, preferredWater: 1394);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Australia extends Region {
  Australia() : super(name: 'Australien', startFood: 2, preferredFood: 26, startWater: 2, preferredWater: 26);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Oceania extends Region {
  Oceania() : super(name: 'Ozeanien', startFood: 1, preferredFood: 18, startWater: 1, preferredWater: 18);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}

class Antarctica extends Region {
  Antarctica() : super(name: 'Antarktis', startFood: 0, preferredFood: 1, startWater: 0, preferredWater: 1);

  @override
  String reactTo(int food, int water) => 'Reaktion';
}
