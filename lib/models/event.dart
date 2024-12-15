import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sowi/constants.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/models/region.dart';

sealed class Event {
  Event({required this.game, required this.level});

  Game game;

  int get minimumRound => 1;
  int get maximumRound => numberOfRounds;

  int get duration => 1;
  int round = 1;

  final int level;

  String get name;
  IconData get icon;

  void onInitialize(Game game) {}

  void apply(Game game) {}

  void onFinished(Game game) {}
}

class PandemicEvent extends Event {
  PandemicEvent({required super.game, required super.level});

  @override
  int get duration => 2;

  @override
  String get name => 'Pandemie';
  @override
  IconData get icon => FontAwesomeIcons.virus;

  final _affectedRegions = <Region>{};

  @override
  void onInitialize(Game game) {
    game.foodPrice *= 1.218;
    final outbreakRegion = game.selectRandomRegion();
    _affectedRegions.add(outbreakRegion);
    outbreakRegion.tradeBlockingEvents.add(this);
  }

  @override
  void apply(Game game) {
    for (var i = 0; i < Random().nextInt(level); i++) {
      final region = game.selectRandomRegion();
      _affectedRegions.add(region);
      region.tradeBlockingEvents.add(this);
    }
  }

  @override
  void onFinished(Game game) {
    game.foodPrice /= 1.218;
    for (final region in _affectedRegions) {
      region.tradeBlockingEvents.remove(this);
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
  void apply(Game game) {
    game.foodPrice *= 1.1 * level;
    game.waterPrice *= 1.1 * level;
  }
}

class WarEvent extends Event {
  WarEvent({required super.game, required super.level});

  @override
  int get duration => 2;

  @override
  String get name => 'Krieg';
  @override
  IconData get icon => FontAwesomeIcons.personMilitaryRifle;

  final _regions = <Region>{};

  @override
  void onInitialize(Game game) {
    game.scheduledEvents.add(InflationEvent(game: game, level: level));

    for (var i = 0; i <= Random().nextInt(level); i++) {
      final region = game.selectRandomRegion();
      _regions.add(region);
      region.tradeBlockingEvents.add(this);
    }
  }

  @override
  void onFinished(Game game) {
    for (final region in _regions) {
      region.tradeBlockingEvents.remove(this);
    }
  }
}

class NatureEvent extends Event {
  NatureEvent({required super.game, required super.level});

  @override
  String get name => switch (level) {
        1 => 'Taifun',
        2 => 'Tsunami',
        3 => 'Tornado',
        _ => throw StateError('No name defined for a level $level nature event.'),
      };

  @override
  IconData get icon => switch (level) {
        1 => Icons.tsunami,
        2 => Icons.tsunami,
        3 => Icons.tornado,
        _ => throw StateError('No icon defined for a level $level nature event.'),
      };

  @override
  void apply(Game game) => game.money -= game.money * (0.1 * level).round();
}

class PlantDiseaseEvent extends Event {
  PlantDiseaseEvent({required super.game, required super.level});

  @override
  String get name => 'Pflanzenkrankheit';

  @override
  IconData get icon => FontAwesomeIcons.plantWilt;

  @override
  void apply(Game game) => game.food -= game.food * (0.1 * level).round();
}

class WaterPollutionEvent extends Event {
  WaterPollutionEvent({required super.game, required super.level});

  @override
  String get name => 'Wasserverschmutzung';

  @override
  IconData get icon => FontAwesomeIcons.handHoldingDroplet;

  @override
  void apply(Game game) => game.water -= game.water * (0.1 * level).round();
}
