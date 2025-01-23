import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/region.dart';

class Game extends ChangeNotifier {
  final regions = [
    Europe(),
    Asia(),
    NorthAmerica(),
    SouthAmerica(),
    Africa(),
    Australia(),
  ];

  int score = 0;

  int round = 0;
  RoundState roundState = RoundState.beginning;
  int movesLeft = 6;

  String get month => switch (movesLeft) {
        6 => 'Januar',
        5 => 'März',
        4 => 'Mai',
        3 => 'Juli',
        2 => 'September',
        1 => 'November',
        0 => 'Dezember',
        _ => throw Error(),
      };

  int water = 0;
  double waterPrice = 1;
  int get additionalWaterMaximum => regions.map((e) => max(0, e.maximumWater - e.water)).sum;

  int food = 0;
  double foodPrice = 1;
  int get additionalFoodMaximum => regions.map((e) => max(0, e.maximumFood - e.food)).sum;

  int money = 5000;
  int generatedMoney = 100; // TODO Change based on events
  double moneyMultiplicationRate = 1.1;

  late final List<List<Event>> events = _generateEvents();
  final activeEvents = <Event>[];
  List<Event> newEvents = [];
  List<Event> finishedEvents = [];

  // TODO More sophisticated generator (same events in a row should be unlikely)
  List<List<Event>> _generateEvents() {
    final events = List.generate(10, (i) => <Event>[]);

    final activeEvents = <Event>[];
    for (var round = 1; round < 10; round++) {
      for (var i = 0; i < activeEvents.length; i++) {
        final event = activeEvents[i];
        event.round++;

        if (event.duration < event.round) {
          event.round = 1;
          activeEvents.remove(event);
          i--;
        }
      }

      final numberOfNewEvents = Random().nextInt(round ~/ 2 + 1);
      for (var i = 0; i < numberOfNewEvents; i++) {
        final level = Random().nextInt(round ~/ 2) + 1;

        final possibleEvents = [
          PandemicEvent(game: this, level: level),
          InflationEvent(game: this, level: level),
          WarEvent(game: this, level: level),
          NatureEvent(game: this, level: level),
          PlantDiseaseEvent(game: this, level: level),
          WaterPollutionEvent(game: this, level: level),
        ].where((e) => e.maximumRound >= round && !activeEvents.any((activeEvent) => e.runtimeType == activeEvent.runtimeType)).toList();

        if (possibleEvents.isEmpty) continue;

        final event = possibleEvents[Random().nextInt(possibleEvents.length)];

        events[round - 1].add(event);
        activeEvents.add(event);
      }
    }

    return events;
  }

  void scheduleEvent(Event event, {int waitRounds = 0}) => events[round + waitRounds].add(event);

  Region selectRandomRegion() => regions[Random().nextInt(regions.length)];

  void distributeResources(Region region, int water, int food) {
    this.food -= food;
    this.water -= water;

    region.food += food;
    region.water += water;

    movesLeft--;

    if (movesLeft == 0) finishRound();

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

    score += regions.fold(0, (sum, e) => sum + e.population);

    newEvents = round == 10 ? [] : events[round];
    finishedEvents = activeEvents.where((e) => e.duration == e.round).toList();

    roundState = RoundState.beginning;

    notifyListeners();
  }

  void startRound() {
    round++;
    movesLeft = 6;

    money += generatedMoney;
    money = (money * moneyMultiplicationRate).round();

    final removedEvents = <Event>[];
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
