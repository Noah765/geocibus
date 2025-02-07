import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/region.dart';

class Game extends ChangeNotifier {
  final regions = [
    Asia(),
    Africa(),
    Europe(),
    SouthAmerica(),
    NorthAmerica(),
    Australia(),
  ];

  late final yearlyPopulation = [
    {for (final region in regions) region: region.startPopulation},
  ];
  int get score => yearlyPopulation.skip(1).map((e) => e.values.sum).sum;

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
  int generatedMoney = 500;
  static const moneyMultiplicationRate = 1.1;

  late final List<List<Event>> events = _generateEvents();
  final activeEvents = <Event>[];
  List<Event> newEvents = [];
  List<Event> finishedEvents = [];

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
        ].where((e) => !activeEvents.any((activeEvent) => e.runtimeType == activeEvent.runtimeType)).toList();

        if (possibleEvents.isEmpty) continue;

        final event = possibleEvents[Random().nextInt(possibleEvents.length)];

        events[round - 1].add(event);
        activeEvents.add(event);
      }
    }

    return events;
  }

  void scheduleEvent(Event event) {
    if (round == 10 || events[round].where((e) => e.runtimeType == event.runtimeType).isNotEmpty) return;
    events[round].add(event);
    for (var i = round; i < round + event.duration; i++) {
      events.removeWhere((e) => e.runtimeType == event.runtimeType);
    }
  }

  void distributeResources(Region region, int water, int food) {
    this.water -= water;
    this.food -= food;

    region.updateResourceTrends(region.water + water, region.food + food);
    region.water += water;
    region.food += food;

    movesLeft--;

    if (movesLeft == 0) finishRound();

    notifyListeners();
  }

  void trade(int water, int food) {
    if (water == 0 && food == 0) return;
    this.water += water;
    this.food += food;
    money -= (water * waterPrice).ceil() + (food * foodPrice).ceil();
    notifyListeners();
  }

  void finishRound() {
    yearlyPopulation.add({for (final region in regions) region: region.expectedPopulation});

    newEvents = round == 10 ? [] : events[round];
    finishedEvents = activeEvents.where((e) => e.duration == e.round).toList();

    roundState = RoundState.beginning;

    notifyListeners();
  }

  void startRound() {
    round++;
    movesLeft = 6;

    for (final region in regions) {
      region.startRound();
    }

    money += generatedMoney;
    money = (money * moneyMultiplicationRate).floor();

    final removedEvents = <Event>[];
    for (final event in activeEvents) {
      event.round++;
      if (event.duration < event.round) {
        removedEvents.add(event);
        event.onFinished(this);
      } else {
        event.apply(this);
      }
    }
    for (final event in removedEvents) {
      activeEvents.remove(event);
    }

    for (final event in newEvents) {
      activeEvents.add(event);
      event.onInitialize(this);
      event.apply(this);
    }

    roundState = RoundState.running;

    notifyListeners();
  }
}

enum RoundState { beginning, running }
