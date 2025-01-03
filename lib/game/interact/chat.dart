import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sowi/models/event.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/models/region.dart';

// TODO Other message for starting a new interaction

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _interactions = <_Interaction>[];

  @override
  void initState() {
    super.initState();
    _interactions.add(_Interaction(context.read<Game>(), context.read<Region>()));
  }

  void _distribute(Game game, Region region, _Interaction interaction) {
    game.distributeResources(
      region,
      switch (interaction.request) { _Request.requestWater => -interaction.requestValue, _Request.distributeWater => interaction.requestValue, _ => 0 },
      switch (interaction.request) { _Request.requestFood => -interaction.requestValue, _Request.distributeFood => interaction.requestValue, _ => 0 },
    );
    _resetInteraction(game, region);
  }

  void _resetInteraction(Game game, Region region) => setState(() => _interactions.add(_Interaction(game, region)));

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();
    final region = context.read<Region>();

    final lastInteraction = _interactions.last;

    return Column(
      children: [
        for (final interaction in _interactions) ...[
          _RegionMessage(interaction.state),
          if (interaction.forshadowing != null) _RegionMessage(interaction.forshadowing!),
          if (interaction.request != null) _YourMessage(interaction.request!.message),
          if (interaction.response != null) _RegionMessage(interaction.response!),
        ],
        const Spacer(),
        if (lastInteraction.request == null)
          Row(
            children: [
              ActionChip(label: const Text('Wasser anfragen'), onPressed: () => setState(() => lastInteraction.requestResources(region, _Request.requestWater))),
              const Gap(8),
              ActionChip(label: const Text('Essen anfragen'), onPressed: () => setState(() => lastInteraction.requestResources(region, _Request.requestFood))),
              const Gap(8),
              ActionChip(label: const Text('Wasser abgeben'), onPressed: game.water == 0 ? null : () => setState(() => lastInteraction.distributeResources(_Request.distributeWater))),
              const Gap(8),
              ActionChip(label: const Text('Essen abgeben'), onPressed: game.food == 0 ? null : () => setState(() => lastInteraction.distributeResources(_Request.distributeFood))),
            ],
          )
        else if (lastInteraction.isRequestSuccessful == false)
          OutlinedButton(onPressed: () => _resetInteraction(game, region), child: const Text('Zurück'))
        else if (lastInteraction.isRequestSuccessful == true)
          Row(
            children: [
              Text(lastInteraction.requestValue.toString()),
              // TODO
              Slider(
                value: lastInteraction.requestValue.toDouble(),
                onChanged: (newValue) => setState(() => lastInteraction.requestValue = newValue.round()),
                min: 1,
                max: switch (lastInteraction.request!) {
                  _Request.requestWater => region.water.toDouble(),
                  _Request.requestFood => region.food.toDouble(),
                  _Request.distributeWater => game.water.toDouble(),
                  _Request.distributeFood => game.food.toDouble(),
                },
              ),
              OutlinedButton(onPressed: () => _distribute(game, region, lastInteraction), child: const Text('Senden')),
              // TODO Restart chat instead of exiting (restart instead of exiting when finishing?, only when resourcestate changes?)
              OutlinedButton(onPressed: () => _resetInteraction(game, region), child: const Text('Zurück')),
            ],
          ),
      ],
    );
  }
}

class _Interaction {
  _Interaction(Game game, Region region) {
    event = _chooseEventBasedOnLevel(region.exportBlockingEvents.isEmpty ? game.activeEvents : region.exportBlockingEvents);
    state = _generateStateMessage(region);
    forshadowing = _generateForshadowingMessage(game, region);
  }

  late final Event? event;
  late final String state;
  late final String? forshadowing;
  _Request? request;
  String? response;
  bool? isRequestSuccessful;
  int requestValue = 1;

  Event? _chooseEventBasedOnLevel(Iterable<Event> events) {
    // TODO Improve algorithm (non-linear distribution)
    if (events.isEmpty) return null;

    final levelSum = events.fold(0, (sum, event) => sum + event.level);
    var current = Random().nextInt(levelSum) + 1;
    for (final event in events) {
      current -= event.level;
      if (current <= 0) return event;
    }

    throw Error();
  }

  String _generateStateMessage(Region region) {
    if (region.waterState == ResourceState.panic || region.foodState == ResourceState.panic) return 'Bei uns werden reihenweise Menschen sterben! Helfen Sie uns!';

    if ((region.waterState == ResourceState.normal || region.waterState == ResourceState.good) && (region.foodState == ResourceState.normal || region.foodState == ResourceState.good)) {
      if (region.waterState == ResourceState.good && region.foodState == ResourceState.good) {
        return 'Wir haben mehr als genug Wasser und Essen. Was wünschen Sie?';
      } else {
        return 'Aktuell geht es uns recht gut. Was wünschen Sie?';
      }
    }

    if (event == null) {
      return switch ((region.waterState, region.waterTrend, region.foodState, region.foodTrend)) {
        (ResourceState.bad, ResourceTrend.falling, _, _) => 'Unsere Wasserbestände werden immer knapper! Wir benötigen Hilfe.',
        (_, _, ResourceState.bad, ResourceTrend.falling) => 'Unsere Lebensmittelbestände werden immer knapper! Wir benötigen Hilfe.',
        (ResourceState.bad, _, _, _) => 'Die Trinkwassersituation bei uns sieht nicht gut aus. Wir brauchen mehr Wasser.',
        (_, _, ResourceState.bad, _) => 'Die Nahrungsmittelsituation bei uns sieht nicht gut aus. Wir brauchen mehr Essen.',
        _ => throw Error(),
      };
    }

    return switch (event!) {
      PandemicEvent(level: 1) => 'Wir brauchen unbedingt Hilfe. Aufgrund einer Epidemie in einigen unserer Länder sind viele unserer Lieferketten eingeschränkt. Können Sie uns helfen?',
      PandemicEvent() =>
        'Einige meiner Länder stecken gerade in einer tiefen Krise. Zu viele Menschen stecken gerade in Quarantäne und die Wirtschaft fährt herunter. Sie sind auf Waren von außen angewiesen. Helft uns!',
      InflationEvent() => 'Durch die hohe Inflation herrscht bei uns gerade eine Verknappung an Nahrungsmittel. Unsere Büger*innen können sich die Preise nicht leisten. Wir brauchen Hilfe.',
      WarEvent() when region.exportBlockingEvents.contains(event) =>
        'Handelsblockaden verhindern den Import von lebenswichtigen Nahrungsmitteln. Unsere Bevölkerung hungert. Wir brauchen dringend Hilfspakete.',
      WarEvent() => 'Wir haben viele Geflüchtete aufgenommen und die Preissteigerungen aufgrund des Krieges setzen uns sehr zu. Können Sie uns helfen?',
      NatureEvent(level: 1) => 'Wir haben durch die großen Überflutungen in vielen Ländern kaum sauberes Wasser mehr. Wir können Hilfspakete gut gebrauchen.',
      NatureEvent(level: 2) => 'Tsunamis haben Teile unseres Kontinentes komplett flachgelegt. Wir können Hilfe gut gebrauchen.',
      NatureEvent() => 'Die Folgen des Klimawandels treffen uns sehr hart. Viele Länder hier leiden an starken Dürren und Nahrungsknappheit durch extreme Hitze. Können Sie uns Hilfe leisten?',
      PlantDiseaseEvent(level: 1) => 'Eine Insektenplage hat viele unsere Felder befallen, weswegen wir mit Nahrungsknappheit kämpfen müssen.',
      PlantDiseaseEvent() =>
        'Eine Krankheit hat sich in vielen unserer Viehfarmen verbreitet. Fleisch ist teurer denn je, doch es herrscht noch eine hohe Nachfrage. Wäre es möglich, ein wenig Hilfe zu bekommen?',
      WaterPollutionEvent() => 'Ein Chemiekonzernunfall hat ein Teil der Wasserversorgung im Osten unseres Kontinents flachgelegt. Können Sie uns helfen?',
    };
  }

  String? _generateForshadowingMessage(Game game, Region region) {
    if (game.round == 10 || game.events[game.round].isEmpty) return null;

    final event = _chooseEventBasedOnLevel(game.events[game.round])!;
    return switch (event) {
      final PandemicEvent event when event.regions.contains(region) =>
        'Eine neue Grippe wurde bei uns entdeckt. Vielleicht sollten wir dies näher auf den Grund gehen, aber es ist noch zu früh für Maßnahmen. Aber das soll unsere Sorge sein.',
      InflationEvent() => 'Weltweit gibt es gerade einen Trend, dass es zu viele Exporte gibt und zu wenig importiert wird. Mal sehen, wie hart es die Wirtschaft trifft.',
      final WarEvent event when event.regions.contains(region) => 'Die Spannungen in einigen Regionen bei uns intensivieren sich. Ich hoffe, dass es nicht weiter eskaliert.',
      NatureEvent() when Random().nextBool() =>
        'Die extremen Wetterlagen, die durch den Klimawandel hervorgerufen werden sind besorgniserregend, auch im Hinblick auf die bevorstehende Ernte. Mehr als präventive Maßnahmen können wir aber auch nicht veranlassen.',
      NatureEvent() => 'Wussten Sie das dieses Jahr das heißeste Jahr seit Aufzeichnung der Wetterdaten ist? Da kann mir keiner sagen, dass der Klimawandel nicht existiert.',
      _ => null,
      // TODO Improve messages, add more
      //PlantDiseaseEvent() => ,
      //WaterPollutionEvent() => ,
    };
  }

  void requestResources(Region region, _Request type) {
    // TODO Write proper responses for rejecting because of one resource
    isRequestSuccessful = !region.isExportBlocked &&
        region.waterState != ResourceState.bad &&
        region.waterState != ResourceState.panic &&
        region.foodState != ResourceState.bad &&
        region.foodState != ResourceState.panic;
    if (isRequestSuccessful!) {
      response = switch (event) {
        null => 'Wir geben gerne etwas ab.',
        PandemicEvent() when Random().nextBool() => 'Wir sind dazu verdammt alle auf einen Planeten zu leben. Früher oder später kommt der Virus auch zu uns. Wir können Hilfe leisten.',
        PandemicEvent() => 'Wir geben gerne etwas ab. Noch haben wir genug und sind nicht betroffen.',
        InflationEvent() => 'Wir stecken gerade selber in einer Wirtschaftskrise. Wir können gerne Hilfspakete liefern, aber sie kommen mit bestimmten Kosten, wenn Sie verstehen.',
        WarEvent() => 'Wir sind vom Krieg nicht betroffen und helfen gerne.',
        NatureEvent() => 'Es ist unsere Pflicht, Hilfesuchende zu unterstützen. Wir werden helfen, die zerstörten Regionen wieder aufzubauen und Lebensmittel zu spenden.',
        PlantDiseaseEvent(level: 1) => 'Aktuell habe wir trotz reduzierter Ernte noch genug, also unterstützen wir gerne.',
        PlantDiseaseEvent() => 'Aktuell haben wir noch genug. Wir helfen gerne.',
        WaterPollutionEvent() => 'Natürlich, wir haben ja schon genug.',
      };
    } else {
      response = switch (event) {
        null when region.waterTrend == ResourceTrend.rising || region.foodTrend == ResourceTrend.rising =>
          'Gerade erholen sich unsere Lagerbestände. Jetzt können wir nichts abgeben. Wir brauchen es selber.',
        null => 'Nein, tut uns leid.',
        PandemicEvent(level: 1) when region.exportBlockingEvents.contains(event) =>
          'Es tut uns leid, aber wegen einer Epidemie, die mehrere Länder umspannt, können wir keine Waren entbehren. Wir haben gerade keine Kapazitäten, um uns um Probleme anderer zu kümmern.',
        PandemicEvent(level: 1) => 'Sie haben eine Epidemie? Die Armen. Aber ich will nicht riskieren, dass die Krankheit zu uns kommt.',
        PandemicEvent() => 'Wir gehen gerade in einen länderweiten Lockdown. Tut uns leid, aber die Globalisierung hat ihre Schattenseiten. Nicht, dass der Virus zu uns kommt.',
        InflationEvent() when Random().nextBool() => 'Die Inflation macht uns auch gerade zu schaffen. Jeder ist gerade auf sich alleine gestellt.',
        InflationEvent() => 'Viele unserer Bürger*innen können sich auch die Sachen kaum leisten und reihenweise Schränke von unseren Supermärkten sind leer. Wir brauchen alles, was wir haben.',
        WarEvent() when region.exportBlockingEvents.contains(event) => 'Wir befinden uns aktuell im Krieg! Wir haben keine Kapazitäten, uns um andere zu kümmern.',
        WarEvent() => 'Wir brauchen die Sachen selber.',
        NatureEvent() => 'Wir leiden momentan auch. Unsere Population geht vor.',
        PlantDiseaseEvent(level: 1) => 'Wir können leider keine Hilfe anbieten, denn unsere Ernte läuft selber gerade sehr schlecht.',
        PlantDiseaseEvent() => 'Wir können aktuell leider keine Hilfe anbieten.',
        WaterPollutionEvent() => 'Ein Chemiekonzernunfall hat ein Teil der Wasserversorgung im Osten unseres Kontinents flachgelegt. Wir können leider nicht helfen. Unser Land geht vor.',
      };
    }

    request = type;
  }

  void distributeResources(_Request type) {
    request = type;
    // TODO Write more varied responses
    isRequestSuccessful = true;
    response = 'Danke für die Unterstützung! Wie viel ${type == _Request.distributeWater ? 'Wasser' : 'Essen'} möchten Sie uns geben?';
  }
}

enum _Request {
  requestWater('Ich würde gerne Wasser anfragen.'),
  requestFood('Ich würde gerne Essen anfragen.'),
  distributeWater('Ich würde gerne Wasser verteilen.'),
  distributeFood('Ich würde gerne Essen verteilen.');

  const _Request(this.message);
  final String message;
}

class _RegionMessage extends StatelessWidget {
  const _RegionMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(text),
        ),
      ),
    );
  }
}

class _YourMessage extends StatelessWidget {
  const _YourMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(text),
        ),
      ),
    );
  }
}
