import 'package:flutter/material.dart';
import 'package:sowi/constants.dart';
import 'package:sowi/logic/game.dart';

sealed class Disaster {
  Disaster(this.level);

  int get minimumRound => 1;
  int get maximumRound => numberOfRounds;

  int get duration => 1;
  int round = 1;

  final int level;

  void apply(Game game);

  String get name;
  IconData get icon;
}

class NatureDisaster extends Disaster {
  NatureDisaster(super.level);

  @override
  void apply(Game game) {
    final region = game.selectRandomRegion();
    region.food = (0.75 * region.food).round();
    region.water = (0.75 * region.water).round();
  }

  @override
  String get name => switch (level) {
        1 => 'Taifun',
        2 => 'Tsunami',
        3 => 'Tornado',
        _ => throw StateError('No name defined for a level $level nature disaster.'),
      };

  @override
  IconData get icon => switch (level) {
        1 => Icons.tsunami,
        2 => Icons.tsunami,
        3 => Icons.tornado,
        _ => throw StateError('No icon defined for a level $level nature disaster.'),
      };
}

class InflationDisaster extends Disaster {
  InflationDisaster(super.level);

  @override
  int get maximumRound => 7;

  @override
  int get duration => 3;

  @override
  void apply(Game game) {
    game.foodExchangeRate *= 1.1;
    game.waterExchangeRate *= 1.1;
  }

  @override
  String get name => 'Inflation';

  @override
  IconData get icon => Icons.money;
}
