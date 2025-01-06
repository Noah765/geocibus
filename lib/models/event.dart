import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';

sealed class Event {
  Event({required this.game, required this.level});

  Game game;

  int get minimumRound => 1;
  int get maximumRound => 10;

  int get duration => 1;
  int round = 1;

  final int level;

  String get name;
  IconData get icon;
  String get description;

  void onInitialize(Game game) {}

  void apply(Game game) {}

  void onFinished(Game game) {}
}

// TODO Define appropriate names and icons for every event
// level

class PandemicEvent extends Event {
  PandemicEvent({required super.game, required super.level}) {
    regions.add(game.selectRandomRegion());
  }

  @override
  int get duration => 2;

  @override
  String get name => switch (level) { 1 => 'Epidemie', _ => 'Pandemie' };
  @override
  IconData get icon => FontAwesomeIcons.virus;
  @override
  String get description => '''
Eine Krankheit verbreitet sich ${level == 1 ? 'in der Region' : 'auf der Welt'}. Viele Grenzen
machen dicht, weswegen der Handel ins Stocken gerät.
Dazu kommt noch eine hohe Inflationsrate, die vielen
Menschen durch hohe Lebensmittelpreise das Leben
erschwert. Und das Schlimmste von allen ist: Es gibt
kein Toilettenpapier mehr!''';

  final regions = <Region>[];

  @override
  void onInitialize(Game game) {
    game.scheduleEvent(InflationEvent(game: game, level: level));

    game.foodPrice *= 1.218;

    regions[0].exportBlockingEvents.add(this);
  }

  @override
  void apply(Game game) {
    if (level == 1) return;

    final numberOfNewRegions = Random().nextInt(level - 1);
    final newRegions = (game.regions.toList()..shuffle()).take(numberOfNewRegions);
    for (final region in newRegions) {
      region.exportBlockingEvents.add(this);
    }
    regions.addAll(newRegions);
  }

  @override
  void onFinished(Game game) {
    game.foodPrice /= 1.218;
    for (final region in regions) {
      region.exportBlockingEvents.remove(this);
    }
  }
}

class InflationEvent extends Event {
  InflationEvent({required super.game, required super.level});

  @override
  int get maximumRound => 7;

  @override
  int get duration => 3;

  @override
  String get name => 'Inflation';
  @override
  IconData get icon => FontAwesomeIcons.moneyBillTrendUp;
  @override
  String get description => '''
Aufgrund einer instabilen Wirtschaft steigt die
Inflationsrate und damit auch die Lebensmittelpreise.
Viele Teile der Bevölkerung muss darum bangen, ob sie
noch genügend Nahrung auf ihren Teller bekommen.''';

  @override
  void onInitialize(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate /= level / 4;
      region.waterGenerationRate /= level / 4;
    }
  }

  @override
  void apply(Game game) {
    game.foodPrice *= 1.1 * level;
    game.waterPrice *= 1.1 * level;
  }

  @override
  void onFinished(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate *= level / 4;
      region.waterGenerationRate *= level / 4;
    }
  }
}

class WarEvent extends Event {
  WarEvent({required super.game, required super.level}) {
    final numberOfParties = min(game.regions.length, Random().nextInt(level) + 2);
    regions.addAll((game.regions.toList()..shuffle()).take(numberOfParties));
  }

  @override
  int get maximumRound => 9;
  @override
  int get duration => 2;

  @override
  String get name => 'Krieg';
  @override
  IconData get icon => FontAwesomeIcons.personMilitaryRifle;
  @override
  String get description => '''
Ein Krieg wird zwischen ${regions.take(regions.length - 1).map((e) => e.name).join(', ')} und ${regions.last.name} ausgefochten. Doch
das betrifft nicht nur die Kriegsparteien, dessen
Populationen unter Nahrungs- und Wasserknappheit leiden.
Die Inflation steigt. Und Handelembargos verhindern den
reibungslosen Austausch von Gütern.''';

  final regions = <Region>[];

  @override
  void onInitialize(Game game) {
    game.scheduleEvent(InflationEvent(game: game, level: level));

    for (final region in regions) {
      region.exportBlockingEvents.add(this);
    }
  }

  @override
  void onFinished(Game game) {
    for (final region in regions) {
      region.exportBlockingEvents.remove(this);
    }
  }
}

class NatureEvent extends Event {
  NatureEvent({required super.game, required super.level});

  @override
  String get name => switch (level) {
        1 => 'Überflutung',
        2 => 'Tsunami',
        _ => 'Dürre',
      };
  @override
  IconData get icon => switch (level) {
        1 => FontAwesomeIcons.houseFloodWater,
        2 => FontAwesomeIcons.houseTsunami,
        _ => FontAwesomeIcons.sunPlantWilt,
      };
  @override
  String get description => '''
Naturkatastrophen sind zwar natürlich, aber durch den
Klimawandel werden sie immer stärker und kommen viel
häufiger vor. Mangelnde Hygiene, die durch zerstörte
Infrastruktur hervorgerufen wird, steuern zur
Verbreitung von Krankheiten bei und die Nahrungs- und
Wasserversorung leidet. Der Wiederaufbau dieser
Infrastruktur kostet viel Geld.''';

  @override
  void onInitialize(Game game) {
    if (level > 1 && Random().nextBool()) game.scheduleEvent(PandemicEvent(game: game, level: level - 1));
    game.money -= game.money * (0.1 * level).round();

    if (level == 1) {
      for (final region in game.regions) {
        region.waterGenerationRate *= 0.8;
      }
    } else if (level != 2) {
      for (final region in game.regions) {
        region.foodGenerationRate *= 0.8;
      }
    }
  }

  @override
  void onFinished(Game game) {
    if (level == 1) {
      for (final region in game.regions) {
        region.waterGenerationRate /= 0.8;
      }
    } else if (level != 2) {
      for (final region in game.regions) {
        region.foodGenerationRate /= 0.8;
      }
    }
  }
}

class PlantDiseaseEvent extends Event {
  PlantDiseaseEvent({required super.game, required super.level});

  @override
  String get name => switch (level) { 1 => 'Pflanzenkrankheit', _ => 'Viehkrankheit' };
  @override
  IconData get icon => FontAwesomeIcons.plantWilt;
  @override
  String get description => switch (level) {
        1 => '''
Eine Pflanzenkrankheit geht herum. Es kommt zu
Ernteausfällen, sodass bei vielen sowohl Essens- als
auch Lebensgrundlage verloren geht. Durch das mangelnde
Angebot aber hohe Nachfrage steigen die
Lebensmittelpreise.''',
        _ => '''
Eine Viehkrankheit geht in Teilen der Welt herum.
Reihenweise Tiere sterben. Man hat nicht mehr genug
proteinreiche Nahrung, weswegen die Preise
ansteigen.''',
      };

  @override
  void onInitialize(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate /= level / 4;
    }
  }

  @override
  void apply(Game game) {
    game.food -= game.food * (0.1 * level).round();
    game.foodPrice *= 1.1 * level;
  }

  @override
  void onFinished(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate *= level / 4;
    }
  }
}

class WaterPollutionEvent extends Event {
  WaterPollutionEvent({required super.game, required super.level});

  @override
  String get name => 'Wasserverschmutzung';
  @override
  IconData get icon => FontAwesomeIcons.handHoldingDroplet;
  @override
  String get description => '''
Wasserverschmutzung hat viele Ursachen. Zerstörte
Infrastruktur durch Krieg oder Naturkatastrophen oder
auch ein Unfall, welcher dazu führt, dass Chemikalien in
die Wasserversorgung gelangen. So wird das Wasser immer
knapper.''';

  @override
  void onInitialize(Game game) {
    for (final region in game.regions) {
      region.waterGenerationRate /= level / 4;
    }
  }

  @override
  void apply(Game game) {
    game.water -= game.water * (0.1 * level).round();
    game.waterPrice *= 1.1 * level;
  }

  @override
  void onFinished(Game game) {
    for (final region in game.regions) {
      region.waterGenerationRate *= level / 4;
    }
  }
}
