import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sowi/constants.dart';
import 'package:sowi/models/event.dart';
import 'package:sowi/models/region.dart';

class Game extends ChangeNotifier {
  final regions = [
    Europe(),
    Asia(),
    NorthAmerica(),
    SouthAmerica(),
    Africa(),
    Australia(),
  ];

  int round = 0;
  RoundState roundState = RoundState.beginning;
  int movesLeft = numberOfMoves;

  int food = 0;
  int water = 0;
  int money = 500;

  double foodPrice = 1;
  double waterPrice = 1;

  int generatedMoney = 10;
  double moneyMultiplicationRate = 1.1;

  final activeEvents = <Event>{};
  final newEvents = <Event>{};
  final finishedEvents = <Event>{};
  final scheduledEvents = <Event>{};

  Region selectRandomRegion() => regions[Random().nextInt(regions.length)];

  void distributeResources(Region region, int water, int food) {
    this.food -= food;
    this.water -= water;

    region.food += food;
    region.water += water;

    movesLeft--;

    notifyListeners();
  }

  void exchangeResources(int water, int food) {
    this.water += water;
    this.food += food;
    money -= (water * waterPrice).round() + (food * foodPrice).round();
    notifyListeners();
  }

  void finishRound() {
    for (final region in regions) {
      region.finishRound();
    }

    newEvents.clear();
    finishedEvents.clear();

    for (final event in activeEvents) {
      if (event.duration <= event.round) {
        finishedEvents.add(event);
      }
    }

    for (final event in scheduledEvents) {
      newEvents.add(event);
    }
    scheduledEvents.clear();

    final numberOfNewEvents = Random().nextInt(round ~/ 2 + 1);
    for (var i = 0; i < numberOfNewEvents; i++) {
      final level = Random().nextInt(round ~/ 2 + 1);

      final event = [
        PandemicEvent(game: this, level: level),
        InflationEvent(game: this, level: level),
        WarEvent(game: this, level: level),
        NatureEvent(game: this, level: level),
        PlantDiseaseEvent(game: this, level: level),
        WaterPollutionEvent(game: this, level: level),
      ][Random().nextInt(5)];
      newEvents.add(event);
    }

    roundState = RoundState.beginning;

    notifyListeners();
  }

  void startRound() {
    round++;

    money += generatedMoney;
    money = (money * moneyMultiplicationRate).round();

    final removedEvents = <Event>{};
    for (final event in activeEvents) {
      event.round++;
      if (event.duration < event.round) {
        removedEvents.add(event);
      } else {
        event.apply(this);
      }
    }
    for (final event in removedEvents) {
      activeEvents.remove(event);
    }

    for (final event in newEvents) {
      activeEvents.add(event);
      event.apply(this);
    }

    roundState = RoundState.running;

    notifyListeners();
  }
}

enum RoundState { beginning, running }
