import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _interactions = <_Interaction>[];
  late final ScrollController _messagesScrollController;

  @override
  void initState() {
    super.initState();
    _interactions.add(_Interaction(context.read<Game>(), context.read<Region>()));
    _messagesScrollController = ScrollController();
  }

  @override
  void dispose() {
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _messagesScrollController.jumpTo(_messagesScrollController.position.maxScrollExtent));

  void _distribute(Game game, Region region, _Interaction interaction) {
    game.distributeResources(
      region,
      switch (interaction.request) { _RequestWater() => -interaction.requestValue, _DistributeWater() => interaction.requestValue, _ => 0 },
      switch (interaction.request) { _RequestFood() => -interaction.requestValue, _DistributeFood() => interaction.requestValue, _ => 0 },
    );
    _resetInteraction(game, region);
  }

  void _resetInteraction(Game game, Region region) {
    setState(() => _interactions.add(_Interaction(game, region)));
    _scrollToBottom();
  }

  void _requestResources(_Request request) {
    setState(() => _interactions.last.requestResources(context.read<Region>(), request));
    _scrollToBottom();
  }

  void _distributeResources(_Request request) {
    setState(() => _interactions.last.distributeResources(request));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();
    final region = context.read<Region>();

    final lastInteraction = _interactions.last;

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _messagesScrollController,
            children: [
              for (final interaction in _interactions) ...[
                _RegionMessage(interaction.state),
                if (interaction.forshadowing != null) _RegionMessage(interaction.forshadowing!),
                if (interaction.request != null) _YourMessage(interaction.request!.message),
                if (interaction.response != null) _RegionMessage(interaction.response!),
              ],
            ],
          ),
        ),
        if (lastInteraction.request == null)
          Row(
            children: [
              ActionChip(label: const Text('Wasser anfragen'), onPressed: () => _requestResources(_RequestWater())),
              const Gap(8),
              ActionChip(label: const Text('Essen anfragen'), onPressed: () => _requestResources(_RequestFood())),
              const Gap(8),
              ActionChip(label: const Text('Wasser abgeben'), onPressed: game.water == 0 ? null : () => _distributeResources(_DistributeWater())),
              const Gap(8),
              ActionChip(label: const Text('Essen abgeben'), onPressed: game.food == 0 ? null : () => _distributeResources(_DistributeFood())),
            ],
          )
        else if (lastInteraction.isRequestSuccessful == false)
          Button(text: 'Zurück', onPressed: () => _resetInteraction(game, region))
        else if (lastInteraction.isRequestSuccessful == true)
          Row(
            children: [
              // TODO Adjust slider (padding, appearance, snapping to specific values), maybe add an additional input field
              Slider(
                value: lastInteraction.requestValue.toDouble(),
                onChanged: (newValue) => setState(() => lastInteraction.requestValue = newValue.round()),
                min: 1,
                max: switch (lastInteraction.request!) {
                  _RequestWater() => region.water.toDouble(),
                  _RequestFood() => region.food.toDouble(),
                  _DistributeWater() => game.water.toDouble(),
                  _DistributeFood() => game.food.toDouble(),
                },
              ),
              Text('(${lastInteraction.requestValue})'),
              const Gap(8),
              Button(text: 'Senden', onPressed: () => _distribute(game, region, lastInteraction)),
              const Gap(8),
              Button(text: 'Zurück', onPressed: () => _resetInteraction(game, region)),
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
    if (region.waterState == ResourceState.panic || region.foodState == ResourceState.panic) {
      if (Random().nextBool()) {
        return switch ((region.waterState == ResourceState.panic, region.foodState == ResourceState.panic)) {
          (true, true) when Random().nextBool() => 'Beide unsere Werte von Essen und Wasser sind knapp. Unsere Bevölkerung leidet! Was sollen wir tun?',
          (true, true) => 'Unsere Essens- und Wasservorräte neigen sich dem Ende zu! Wir würden ungern jetzt etwas abgeben.',
          (true, _) when Random().nextBool() => 'Wir haben kaum noch Wasser! Hilfe!',
          (true, _) => 'Wir benötigen dringend mehr Wasser! Unsere Bevölkerung ist am Verdursten!',
          (_, true) when Random().nextBool() => 'Wir haben kaum noch Essen! Hilfe!',
          (_, true) => 'Wir benötigen dringend mehr Nahrung! Unsere Bevölkerung ist aktiv am Verhungern!',
          _ => throw Error(),
        };
      }
      return [
        'Bei uns werden reihenweise Menschen sterben! Helfen Sie uns!',
        'Falls Sie etwas von uns wollen, bedenken Sie, dass unsere Lagerbestände auch knapp sind. Wir haben auch so schon genug Probleme.',
        'Wann wird uns endlich geholfen? Wir brauchen Ressourcen!',
        'Unsere Bevölkerung leidet. Wir können sie nicht adäquat versorgen! Wir sind wirklich auf Hilfe von außen angewiesen.',
      ][Random().nextInt(4)];
    }

    if ((region.waterState == ResourceState.normal || region.waterState == ResourceState.good) && (region.foodState == ResourceState.normal || region.foodState == ResourceState.good)) {
      if (region.waterState == ResourceState.good && region.foodState == ResourceState.good) {
        return [
          'Wir haben mehr als genug Wasser und Essen. Was wünschen Sie?',
          'Uns geht es besser denn je. Können wir Sie bei irgendetwas unterstützen?',
          'Wir haben genug Vorräte auf Lager. Ich schätze mal, dass Sie etwas davon haben wollen?',
          'Was können wir für Sie tun?',
          'Aktuell geht es unserer Bevölkerung sehr gut, was unsere Nahrungsmittel- und Wasserversorgung betrifft. Sind Sie gekommen, um dies zu ändern?',
        ][Random().nextInt(5)];
      } else {
        return [
          'Aktuell geht es uns recht gut. Was wünschen Sie?',
          'Können wir Ihnen behilflich sein?',
          'Momentan sind wir ganz in Ordnung versorgt. Hoffentlich bleibt es so.',
          'Sind Sie jetzt gekommen, um von uns zu nehmen oder uns zu geben? Momentan ist beides nicht gern gesehen oder nötig.',
        ][Random().nextInt(4)];
      }
    }

    if (event == null || Random().nextDouble() < 0.25) {
      return switch ((region.waterState == ResourceState.bad, region.waterTrend == ResourceTrend.falling, region.foodState == ResourceState.bad, region.foodTrend == ResourceTrend.falling)) {
        (true, true, true, true) => 'Momentan sehen unsere Ressourcenwerte nicht gut aus. Hoffentlich werden sie nicht noch knapper.',
        (true, true, _, _) when Random().nextBool() => 'Unsere Wasserbestände werden immer knapper! Wir benötigen Hilfe.',
        (true, true, _, _) => 'Unsere Wasservorräte sind deutlich gesunken und dieser Trend hört nicht auf.',
        (_, _, true, true) when Random().nextBool() => 'Unsere Lebensmittelbestände werden immer knapper! Wir benötigen Hilfe.',
        (_, _, true, true) => 'Unsere Essensvorräte sind deutlich gesunken und dieser Trend hört nicht auf.',
        (true, _, true, _) when Random().nextBool() => 'Wann wird uns endlich geholfen? Wir brauchen Ressourcen!',
        (true, _, true, _) => 'Unsere Bevölkerung leidet. Wir können sie nicht adäquat versorgen! Wir sind wirklich auf Hilfe von außen angewiesen.',
        (true, _, _, _) when Random().nextBool() => 'Die Trinkwassersituation bei uns sieht nicht gut aus. Wir brauchen mehr Wasser.',
        (true, _, _, _) => 'Wir benötigen dringend mehr Wasser! Unsere Bevölkerung ist aktiv am Verdursten!',
        (_, _, true, _) when Random().nextBool() => 'Die Nahrungsmittelsituation bei uns sieht nicht gut aus. Wir brauchen mehr Essen.',
        (_, _, true, _) => 'Wir benötigen dringend mehr Nahrung! Unsere Bevölkerung ist aktiv am Verhungern!',
        _ => throw Error(),
      };
    }

    return switch (event!) {
      PandemicEvent(level: 1) when Random().nextBool() =>
        'Wir brauchen unbedingt Hilfe. Aufgrund einer Epidemie in einigen unserer Länder sind viele unserer Lieferketten eingeschränkt. Können Sie uns helfen?',
      PandemicEvent(level: 1) => 'Wegen dem länderweiten Shutdown, gehen unsere Lagerbestände zuneige. Unsere Lage ist sehr prekär.',
      PandemicEvent() => [
          'Einige meiner Länder stecken gerade in einer tiefen Krise. Zu viele Menschen stecken gerade in Quarantäne und die Wirtschaft fährt herunter. Sie sind auf Waren von außen angewiesen. Helft uns!',
          'Viele Menschen können wegen der Pandemie nicht zur Arbeit erscheinen. Unsere Wirtschaft fährt herunter und die Supermärkte stehen leer. Wir sind auf Hilfspakete angewiesen.',
          'Unsere Bekölkerung hamstert panisch Lebensmittel. Dabei sind unsere Vorräte so gut wie ausgeschöpft. Wir brauchen Hilfe!',
        ][Random().nextInt(3)],
      InflationEvent() => [
          'Durch die hohe Inflation herrscht bei uns gerade eine Verknappung an Nahrungsmittel. Unsere Büger*innen können sich die Preise nicht leisten. Wir brauchen Hilfe.',
          'Aufgrund verschiedensten Krisen, steigen die Nahrungsmittelpreise. Viele Menschen können sich keine gesunde Ernährung mehr leisten. Können Sie uns Abhilfe verschaffen?',
          'Die Inflationsrate ist so hoch wie nie. Der Lebensstandard unserer Bevölkerung sinkt deswegen. Können Sie uns zumindest in einem Aspekt helfen, damit es unserer Bevölkerung besser geht?',
        ][Random().nextInt(3)],
      WarEvent() when region.exportBlockingEvents.contains(event) => [
          'Handelsblockaden verhindern den Import von lebenswichtigen Nahrungsmitteln. Unsere Bevölkerung hungert. Wir brauchen dringend Hilfspakete.',
          'Eine Kriegspartei droht, Weizenexporte teurer zu machen. Selbst wenn man nach Ersatzlieferanten sucht, wird es nicht unbedingt günstiger, schließlich sind sie die größten Weizenexporteure! Können Sie uns helfen, etwas unabhängiger von ihren Lieferungen zu machen?',
          'Der Handel mit verschiedenen Ländern ist aufgrund des Krieges eingeschränkt. Dabei sind wir sehr von deren Importen abhängig. Wir brauchen Hilfe!',
        ][Random().nextInt(3)],
      WarEvent() when Random().nextBool() => 'Wir haben viele Geflüchtete aufgenommen und die Preissteigerungen aufgrund des Krieges setzen uns sehr zu. Können Sie uns helfen?',
      WarEvent() => 'Auch wenn wir keine direkte Kriegspartei sind, treffen uns die Sanktionen und Handelsembargos sehr. Können Sie uns Essen bereitstellen?',
      NatureEvent() when Random().nextDouble() < 0.3 =>
        'Der Klimawandel trifft uns sehr hart. Ernten werden zerstört, Wasser verschmutzt und viele Menschen sterben, was auch die Zahl der Arbeitskräfte beeinflusst. Können wir auf Hilfspakete zählen?',
      NatureEvent(level: 1) => 'Wir haben durch die großen Überflutungen in vielen Ländern kaum sauberes Wasser mehr. Wir können Hilfspakete gut gebrauchen.',
      NatureEvent(level: 2) => 'Tsunamis haben Teile unseres Kontinentes komplett flachgelegt. Wir können Hilfe gut gebrauchen.',
      NatureEvent(level: 3) =>
        'Ein gewaltiges Erdbeben hat einige Länder schwergetroffen. Die Infrastruktur ist komplett in Schutt und Asche gelegt worden. Die Kriminalität ist hoch und sanitäre Einrichtungen sind praktisch non-existent. Es ist Ihre Pflicht, uns humanitäre Hilfe zu leisten! Jede Unterstützung zählt!',
      NatureEvent() => 'Die Folgen des Klimawandels treffen uns sehr hart. Viele Länder hier leiden an starken Dürren und Nahrungsknappheit durch extreme Hitze. Können Sie uns Hilfe leisten?',
      PlantDiseaseEvent(level: <= 3) => [
          'Eine Insektenplage hat viele unsere Felder befallen, weswegen wir mit Nahrungsknappheit kämpfen müssen.',
          'Eine sehr lästige Insektenart, die zu den Parasiten zählt, befällt unsere Getreideernte. Sie vermehrt sich schnell und die Monokultur macht es auch nicht besser. Helfen Sie uns, unsere Lebensgrundlage zu retten!',
          'Ernteausfälle waren aufgrund der Pflanzenkrankheit zu erwarten, aber dass sie uns so hart trifft, hätte sich keiner ausmalen können. Können Sie uns Abhilfe verschaffen? Unsere Bevölkerung hungert!',
        ][Random().nextInt(3)],
      PlantDiseaseEvent() => [
          'Eine Krankheit hat sich in vielen unserer Viehfarmen verbreitet. Fleisch ist teurer denn je, doch es herrscht noch eine hohe Nachfrage. Wäre es möglich, ein wenig Hilfe zu bekommen?',
          'Verschiedenen Viren und Bakterien machen sich in der Tierhaltung breit, die gegen jegliche Medizin resistent sind. Sämtliche Masttiere gehen deswegen zugrunde, doch die Nachfrage nach Fleisch ist so hoch wie nie. Können Sie uns helfen?',
          'Eine ominöse Krankheit tötet viele Tiere in der Massentierhaltung. Es hat epidemische Zustände angenommen. Können wir auf Ihre Unterstützung zählen, während wir versuchen, die Krankheit einzudämmen?',
        ][Random().nextInt(3)],
      WaterPollutionEvent() => [
          'Ein Chemiekonzernunfall hat ein Teil der Wasserversorgung im Osten unseres Kontinents flachgelegt. Können Sie uns helfen?',
          'Gefährliche Chemikalien haben die Wasserversorgung in einigen Regionen infiltriert. Wir bräuchten sauberes Trinkwasser, um die Zeit zu überbrücken, bis wir alles gesäubert haben.',
          'Es ist einer der heißesten Jahre seit Wetteraufzeichnung. Unsere Süßwasservorräte sehen nicht gut aus. Können wir auf Ihre Unterstützung zählen?',
        ][Random().nextInt(3)],
    };
  }

  String? _generateForshadowingMessage(Game game, Region region) {
    if (game.round == 10 || game.events[game.round].isEmpty) return null;

    return switch (_chooseEventBasedOnLevel(game.events[game.round])!) {
      final PandemicEvent event when event.regions.contains(region) =>
        'Eine neue Grippe wurde bei uns entdeckt. Vielleicht sollten wir dies näher auf den Grund gehen, aber es ist noch zu früh für Maßnahmen. Aber das soll unsere Sorge sein.',
      InflationEvent() when Random().nextBool() => 'Weltweit gibt es gerade einen Trend, dass es zu viele Exporte gibt und zu wenig importiert wird. Mal sehen, wie hart es die Wirtschaft trifft.',
      InflationEvent() =>
        'Die ganze Welt ist miteinander verbunden, sei es nun Handel oder Diplomatie. Das nennt man Globalisierung. Wenn es einem Teil der Erde nicht gut geht, leiden die anderen auch darunter. Da muss man sich nur den Börsencrash in der Wall Street und die Weltfinanzkrise in den 2000er anschauen. Aber ich rede schon wieder zu viel.',
      final WarEvent event when event.regions.contains(region) => [
          'Die Spannungen in einigen Regionen bei uns intensivieren sich. Ich hoffe, dass es nicht weiter eskaliert.',
          'Viele Kriege werden wegen jahrelangen Spannungen ausgelöst. Da fehlt nur ein Funke, um das ganze Pulverfass zum Explodieren zu bringen. So solche Situationen kann man überall auf der Welt finden. Auch auf unseren Kontinenten. Aber leider gibt es keine einfachen Lösungen für so etwas.',
        ][Random().nextInt(2)],
      NatureEvent() => [
          'Die extremen Wetterlagen, die durch den Klimawandel hervorgerufen werden sind besorgniserregend, auch im Hinblick auf die bevorstehende Ernte. Mehr als präventive Maßnahmen können wir aber auch nicht veranlassen.',
          'Wussten Sie das dieses Jahr das heißeste Jahr seit Aufzeichnung der Wetterdaten ist? Da kann mir keiner sagen, dass der Klimawandel nicht existiert.',
          'Wissenschaftler*innen warnen schon seit Jahren, dass sich Naturkatastrophen anhäufen und viel extremer werden, wenn wir keine ausreichenden Klimamaßnahmen ergreifen. Leider ist globale Kooperation schwierig, wenn alle ihre eigenen Interessen verfolgen.',
          'Unsere Frühwarnsysteme vor Naturkatastrophen sind teilweise ziemlich veraltet oder funktionieren nicht richtig. Aber das wird das Problem der nächsten Regierung sein.',
          'Klimaprognosen sagen, dass es wegen dem menschengemachten Klimawandels eines der wärmsten Jahre aller Zeiten sein wird. Hoffentlich wird es nicht Wirklichkeit. Wer weiß, wie es sich auf unsere Wasser- und Essensversorgung auswirken wird?',
        ][Random().nextInt(5)],
      PlantDiseaseEvent(level: <= 3) when Random().nextBool() =>
        'Wir versuchen immer den höchstmöglichen Ertrag zu erzielen und da sind Monokulturen am effektivsten. So lange die Nutzpflanzen von keinen Parasiten befallen wird, sind wir in dieser Hinsicht gesichert.',
      PlantDiseaseEvent(level: <= 3) =>
        'Mithilfe von Insektiziden können wir gegen Parasiten vorgehen. Aber die Methode garantiert nicht immer Erfolg und sehr viele Wildtierleben gehen verloren. Aber was solls. Wie sollen wir sonst die vielen Menschen ernähren?',
      PlantDiseaseEvent() =>
        'Wussten Sie, dass das Übernutzen von Antibiotika das Hervorrufen von multiresistenten Bakterien fördert? In der Massentierhaltung ist das ein großes Problem, aber Sie wissen doch, wie die Lobby da ist.',
      WaterPollutionEvent() => 'Durch verschiedensten Industrieabfällen, sind unsere Wasserreinigungsanlagen so gefordert wie noch nie. Wir müssen dort dringend mehr Geld hineinstecken.',
      _ => null,
    };
  }

  void requestResources(Region region, _Request type) {
    isRequestSuccessful = !region.isExportBlocked &&
        region.waterState != ResourceState.bad &&
        region.waterState != ResourceState.panic &&
        region.foodState != ResourceState.bad &&
        region.foodState != ResourceState.panic;

    request = type;

    if (isRequestSuccessful! && (event == null || Random().nextDouble() < 0.3)) {
      response = [
        'Wir geben gerne etwas ab.',
        'Natürlich können wir etwas abgeben.',
        'Okay. Aber wenn Sie zu gierig sind, wird unsere Population auch leiden, also behalten Sie das ebenfalls im Kopf.',
        'Wenn Sie wirklich darauf bestehen...',
        'Es passiert schon viel Schreckliches auf der Welt, da helfen wir gerne, wo wir können.',
        'Nur zu!',
        'Wir helfen gerne.',
      ][Random().nextInt(7)];
      return;
    }

    if (isRequestSuccessful!) {
      response = switch (event) {
        PandemicEvent() => [
            'Wir sind dazu verdammt alle auf einen Planeten zu leben. Früher oder später kommt der Virus auch zu uns. Wir können Hilfe leisten.',
            'Wir geben gerne etwas ab. Noch haben wir genug und sind nicht betroffen.',
            'Die Pandemie trifft uns alle hart. Da ist gegenseitige Hilfe nötiger denn je.',
            'Wenn es wirklich nötig ist... Ich vermute mal, dass andere mehr leiden als wir.',
          ][Random().nextInt(4)],
        InflationEvent() => [
            'Wir stecken gerade selber in einer Wirtschaftskrise. Wir können gerne Hilfspakete liefern, aber sie kommen mit bestimmten Kosten, wenn Sie verstehen.',
            'Ressourcen sind teurer denn je. Aber ich schätze, wir können ein wenig abgeben.',
            'Uns hat die Inflation nicht ganz so hart getroffen. Wir können Hilfe leisten.',
          ][Random().nextInt(3)],
        WarEvent() when Random().nextBool() => 'Wir sind vom Krieg nicht betroffen und helfen gerne.',
        WarEvent() => 'Kriege sind nicht schön und viele unschuldige Menschen müssen darunter leiden. Humanitäre Hilfe zu leisten ist unsere Pflicht!',
        NatureEvent() => [
            'Es ist unsere Pflicht, Hilfesuchende zu unterstützen. Wir werden helfen, die zerstörten Regionen wieder aufzubauen und Lebensmittel zu spenden.',
            'So solche Katastrophen sind wirklich schrecklich. Wir gehen gerne als gutes Beispiel voran.',
            'Durch Klimawandel verursacht oder nicht, viele Menschen müssen wegen Naturkatastrophen leiden. Globales Teamwork ist ein Muss!',
          ][Random().nextInt(3)],
        PlantDiseaseEvent() when Random().nextBool() => 'Wir können die Verzweilung nachvollziehen, wenn Krankheiten oder Parasiten die Lebensgrundlage gefährden. Wir helfen gerne.',
        PlantDiseaseEvent(level: 1) => 'Aktuell habe wir trotz reduzierter Ernte noch genug, also unterstützen wir gerne.',
        PlantDiseaseEvent() => 'Aktuell haben wir noch genug. Wir helfen gerne.',
        WaterPollutionEvent() when type is _RequestWater => 'Das müssen Sie nicht zwei Mal sagen. Ohne Wasser kann ein Mensch schließlich nicht überleben.',
        WaterPollutionEvent() => 'Natürlich, wir haben ja schon genug.',
        _ => throw Error(),
      };
      return;
    }

    if (event == null && (region.waterTrend == ResourceTrend.rising || region.foodTrend == ResourceTrend.rising) && Random().nextDouble() < 0.8) {
      response = 'Gerade erholen sich unsere Lagerbestände. Jetzt können wir nichts abgeben. Wir brauchen es selber.';
      return;
    }

    if (event == null || Random().nextDouble() < 0.3) {
      response = [
        'Nein, tut uns leid.',
        'Tut uns leid, aber unser Kontinent geht vor.',
        'Entschuldige, aber es geht nicht.',
        'Fragen Sie am besten jemand anderes. Dafür werden wir Ihnen sehr dankbar.',
        'Haben Sie unsere Werte gesehen, bevor Sie uns wegen so etwas fragen? ',
        'Nein, tut uns leid.',
        'Gibt es nicht jemand anderes, der oder die besser dran sind als wir?',
        'Auch wenn wir mit Ihnen mitfühlen, können wir leider nicht weiterhelfen. Entschuldigung.',
        'Wir schätzen Ihren Altruismus, aber leider können wir nichts abgeben.',
      ][Random().nextInt(9)];
      return;
    }

    response = switch (event) {
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
      _ => throw Error(),
    };
  }

  void distributeResources(_Request type) {
    request = type;
    isRequestSuccessful = true;
    response = [
      'Danke für die Unterstützung! Wie viel ${type is _RequestWater ? 'Wasser' : 'Essen'} möchten Sie uns geben?',
      'Dankeschön!',
      'Ihretwegen wird es vielen Menschen besser gehen.',
      'Danke, wir schätzen Ihre Hilfe sehr.',
      'Die Ressourcen nehmen wir gerne an.',
      'Unsere Population wird Ihnen sehr dankbar sein.',
      'Jegliche Unterstützung ist gerne gesehen. Wir bedanken uns bei Ihnen.',
      '${type is _RequestWater ? 'Wasser' : 'Essen'} ist bei unserer Lage gerne gesehen.',
      'Das ist wirklich super! Wie viel können Sie entbehren?',
    ][Random().nextInt(9)];
  }
}

sealed class _Request {
  const _Request(this.message);

  final String message;
}

class _RequestWater extends _Request {
  _RequestWater()
      : super(
          [
            'Ich würde gerne Wasser anfragen.',
            'Wäre es in Ordnung, wenn Sie uns Wasser geben könnten?',
            'Können Sie uns helfen und etwas von ihren Wasservorräten teilen?',
            'Ich bräuchte dringend Wasser, um Menschen in Not zu helfen.',
          ][Random().nextInt(4)],
        );
}

class _RequestFood extends _Request {
  _RequestFood()
      : super(
          [
            'Ich würde gerne Essen anfragen.',
            'Wäre es in Ordnung, wenn Sie uns Nahrungsmittel geben könnten?',
            'Können Sie uns helfen und etwas von ihren Essensvorräten teilen?',
            'Ich bräuchte dringend Nahrungsmittel, um Menschen in Not zu helfen.',
          ][Random().nextInt(4)],
        );
}

class _DistributeWater extends _Request {
  _DistributeWater()
      : super(
          [
            'Ich würde gerne Wasser verteilen.',
            'Ich kann Ihnen bei Ihrer heiklen Wassersituation unter die Arme greifen.',
            'Ich konnte ein wenig Wasser für ihre Bevölkerung erwerben.',
            'Ich kann Ihnen Wasser geben.',
          ][Random().nextInt(4)],
        );
}

class _DistributeFood extends _Request {
  _DistributeFood()
      : super(
          [
            'Ich würde gerne Essen verteilen.',
            'Ich kann Ihnen bei Ihrer heiklen Nahrungsmittelsituation unter die Arme greifen.',
            'Ich konnte ein wenig Essen für ihre Bevölkerung erwerben.',
            'Ich kann Ihnen Nahrungsmittel geben.',
          ][Random().nextInt(4)],
        );
}

class _RegionMessage extends StatelessWidget {
  const _RegionMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: TextCard(text: text));
}

class _YourMessage extends StatelessWidget {
  const _YourMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerRight, child: TextCard(text: text));
}
