import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';

sealed class Event {
  Event({required this.game, required this.level});

  Game game;

  int get duration => 1;
  int round = 1;

  final int level;

  String get name;
  IconData get icon;
  String get description;
  String get effects;

  void onInitialize(Game game) {}

  void apply(Game game) {}

  void onFinished(Game game) {}
}

extension on List<Region> {
  String displayNames() {
    if (length == 1) return first.name;
    return '${take(length - 1).map((e) => e.name).join(', ')} und ${last.name}';
  }
}

class PandemicEvent extends Event {
  PandemicEvent({required super.game, required super.level}) {
    regions.add(game.regions[Random().nextInt(game.regions.length)]);
  }

  @override
  int get duration => 3;

  @override
  String get name => switch (level) { 1 => 'Epidemie', _ => 'Pandemie' };
  @override
  IconData get icon => FontAwesomeIcons.virus;
  @override
  String get description =>
      'Eine Krankheit verbreitet sich ${level == 1 ? 'in ${regions[0].name}.' : 'auf der Welt.\n${regions.length == 1 ? '${regions[0].name} ist' : '${regions.displayNames()} sind'} bereits betroffen.'} Viele Grenzen machen dicht, weswegen der Handel ins Stocken gerät. Dazu kommt noch eine hohe Inflationsrate, die vielen Menschen durch hohe Lebensmittelpreise das Leben erschwert. Und das Schlimmste von allen ist: Es gibt kein Toilettenpapier mehr!';
  @override
  String get effects => '''
Dauer: 3 Jahre${level == 1 ? '' : '\nDie Pandemie kann sich jedes Jahr weiter ausbreiten'}
Löst eine Inflation der Stufe $level aus, solange noch keine Inflation aktiv ist
Die Lebensmittelpreise sind während des Events um 21,8% höher
Die betroffenen Regionen blockieren jegliche Exporte''';

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
  int get duration => 2;

  @override
  String get name => 'Inflation';
  @override
  IconData get icon => FontAwesomeIcons.moneyBillTrendUp;
  @override
  String get description =>
      'Aufgrund einer instabilen Wirtschaft steigt die Inflationsrate und damit auch die Lebensmittelpreise. Viele Teile der Bevölkerung muss darum bangen, ob sie noch genügend Nahrung auf ihren Teller bekommen.';
  @override
  String get effects => '''
Dauer: 2 Jahre
Die Wasser- und Lebensmittelproduktion jeder Region sinkt während des Events um ${(100 - 100 / (1 + level / 4)).round()}%
Die Preise für Wasser und Lebensmittel steigen jedes Jahr um ${10 * level}%
Du generierst jede Runde ${8 * level}% mehr Geld (unabhängig von der konstanten Geldvermehrungsrate von 10% pro Jahr)''';

  @override
  void onInitialize(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate /= 1 + level / 4;
      region.waterGenerationRate /= 1 + level / 4;
    }
  }

  @override
  void apply(Game game) {
    game.foodPrice *= 1 + 0.1 * level;
    game.waterPrice *= 1 + 0.1 * level;
    game.generatedMoney = (game.generatedMoney * 0.08 * level).floor();
  }

  @override
  void onFinished(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate *= 1 + level / 4;
      region.waterGenerationRate *= 1 + level / 4;
    }
  }
}

class WarEvent extends Event {
  WarEvent({required super.game, required super.level}) {
    final numberOfParties = min(game.regions.length, Random().nextInt(level) + 2);
    regions.addAll((game.regions.toList()..shuffle()).take(numberOfParties));
  }

  @override
  int get duration => 2;

  @override
  String get name => 'Krieg';
  @override
  IconData get icon => FontAwesomeIcons.personMilitaryRifle;
  @override
  String get description =>
      'Ein Krieg wird zwischen ${regions.displayNames()} ausgefochten. Doch das betrifft nicht nur die Kriegsparteien, dessen Populationen unter Nahrungs- und Wasserknappheit leiden. Die Inflation steigt. Und Handelembargos verhindern den reibungslosen Austausch von Gütern.';
  @override
  String get effects => '''
Dauer: 2 Jahre
Löst eine Inflation der Stufe $level aus, solange noch keine Inflation aktiv ist
Jedes Jahr verlieren die betroffenen Regionen ${(100 - 100 / (1 + level / 2)).round()}% ihrer Lebensmittel und ihres Wassers
Die betroffenen Regionen blockieren jegliche Exporte''';

  final regions = <Region>[];

  @override
  void onInitialize(Game game) {
    game.scheduleEvent(InflationEvent(game: game, level: level));

    for (final region in regions) {
      region.exportBlockingEvents.add(this);
    }
  }

  @override
  void apply(Game game) {
    for (final region in regions) {
      region.food = (region.food / (1 + level / 2)).floor();
      region.water = (region.water / (1 + level / 2)).floor();
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
        3 => 'Erdbeben',
        _ => 'Dürre',
      };
  @override
  IconData get icon => switch (level) {
        1 => FontAwesomeIcons.houseFloodWater,
        2 => FontAwesomeIcons.houseTsunami,
        3 => FontAwesomeIcons.houseCrack,
        _ => FontAwesomeIcons.sunPlantWilt,
      };
  @override
  String get description =>
      'Naturkatastrophen sind zwar natürlich, aber durch den Klimawandel werden sie immer stärker und kommen viel häufiger vor. Mangelnde Hygiene, die durch zerstörte Infrastruktur hervorgerufen wird, steuern zur Verbreitung von Krankheiten bei und die Nahrungs- und Wasserversorung leidet. Der Wiederaufbau dieser Infrastruktur kostet viel Geld.';
  @override
  String get effects => '''
Dauer: 1 Jahr${level == 1 ? '' : '\nKann eine ${level == 2 ? 'Epidemie' : 'Pandemie der Stufe ${level - 1}'} auslösen'}
Du verlierst ${10 * level}% deines Geldes
Die Wasser- und Lebensmittelproduktion jeder Region sinkt während des Events um ${(100 - 100 / (1 + level / 2)).round()}%''';

  @override
  void onInitialize(Game game) {
    print('init');
    if (level > 1 && Random().nextBool()) game.scheduleEvent(PandemicEvent(game: game, level: level - 1));
    game.money -= (game.money * 0.1 * level).ceil();

    for (final region in game.regions) {
      region.foodGenerationRate /= 1 + level / 2;
      region.waterGenerationRate /= 1 + level / 2;
    }
  }

  @override
  void apply(Game game) {
    print('apply');
  }

  @override
  void onFinished(Game game) {
    print('finish');
    for (final region in game.regions) {
      region.foodGenerationRate *= 1 + level / 2;
      region.waterGenerationRate *= 1 + level / 2;
    }
  }
}

class PlantDiseaseEvent extends Event {
  PlantDiseaseEvent({required super.game, required super.level});

  @override
  int get duration => 4;

  @override
  String get name => switch (level) { 1 => 'Pflanzenkrankheit', _ => 'Viehkrankheit' };
  @override
  IconData get icon => FontAwesomeIcons.plantWilt;
  @override
  String get description => switch (level) {
        <= 3 =>
          'Eine Pflanzenkrankheit geht herum. Es kommt zu Ernteausfällen, sodass bei vielen sowohl Essens- als auch Lebensgrundlage verloren geht. Durch das mangelnde Angebot aber hohe Nachfrage steigen die Lebensmittelpreise.',
        _ => 'Eine Viehkrankheit geht in Teilen der Welt herum. Reihenweise Tiere sterben. Man hat nicht mehr genug proteinreiche Nahrung, weswegen die Preise ansteigen.',
      };
  @override
  String get effects => '''
Dauer: 4 Jahre
Die Lebensmittelproduktion jeder Region sinkt während des Events um ${(100 - 100 / (1 + level / 4)).round()}%
Du verlierst jedes Jahr ${10 * level}% deines übrigen Essens
Die Lebensmittelpreise steigen jedes Jahr um ${10 * level}% und fallen nach dem Event um den gleichen Betrag''';

  @override
  void onInitialize(Game game) {
    for (final region in game.regions) {
      region.foodGenerationRate /= 1 + level / 4;
    }
  }

  @override
  void apply(Game game) {
    game.food -= (game.food * 0.1 * level).ceil();
    game.foodPrice *= 1 + 0.1 * level;
  }

  @override
  void onFinished(Game game) {
    game.foodPrice /= pow(1 + 0.1 * level, 4);
    for (final region in game.regions) {
      region.foodGenerationRate *= 1 + level / 4;
    }
  }
}

class WaterPollutionEvent extends Event {
  WaterPollutionEvent({required super.game, required super.level});

  @override
  int get duration => 4;

  @override
  String get name => 'Wasserverschmutzung';
  @override
  IconData get icon => FontAwesomeIcons.handHoldingDroplet;
  @override
  String get description =>
      'Wasserverschmutzung hat viele Ursachen. Zerstörte Infrastruktur durch Krieg oder Naturkatastrophen oder auch ein Unfall, welcher dazu führt, dass Chemikalien in die Wasserversorgung gelangen. So wird das Wasser immer knapper.';
  @override
  String get effects => '''
Dauer: 4 Jahre
Die Wasserproduktion jeder Region sinkt während des Events um ${(100 - 100 / (1 + level / 4)).round()}%
Du verlierst jedes Jahr ${10 * level}% deines übrigen Wassers
Die Wasserpreise steigen jedes Jahr um ${10 * level}% und fallen nach dem Event um den gleichen Betrag''';

  @override
  void onInitialize(Game game) {
    for (final region in game.regions) {
      region.waterGenerationRate /= 1 + level / 4;
    }
  }

  @override
  void apply(Game game) {
    game.water -= (game.water * 0.1 * level).ceil();
    game.waterPrice *= 1 + 0.1 * level;
  }

  @override
  void onFinished(Game game) {
    game.waterPrice /= pow(1 + 0.1 * level, 4);
    for (final region in game.regions) {
      region.waterGenerationRate *= 1 + level / 4;
    }
  }
}
