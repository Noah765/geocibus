import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/event.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/theme.dart';
import 'package:geocibus/widgets/bidirectional_slider.dart';
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

  var _interactable = false;
  var _showForeshadowing = false;
  var _showResponse = false;
  var _showFinalResponse = false;

  @override
  void initState() {
    super.initState();
    _messagesScrollController = ScrollController();
    _startInteraction();
  }

  @override
  void dispose() {
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _messagesScrollController.animateTo(
        _messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  void _showDelayed(Duration duration, VoidCallback callback, {bool allowInteractions = false}) {
    Future.delayed(duration, () {
      if (!mounted) return;
      setState(callback);
      if (allowInteractions) _interactable = true;
      _scrollToBottom();
    });
  }

  void _startInteraction() {
    final newInteraction = _Interaction(context.read<Game>(), context.read<Region>());
    setState(() => _interactions.add(newInteraction));
    _scrollToBottom();
    _showForeshadowing = false;
    _showResponse = false;
    _showFinalResponse = false;
    if (_interactions.last.foreshadowing == null) {
      _interactable = true;
    } else {
      _showDelayed(const Duration(milliseconds: 500), () => _showForeshadowing = true, allowInteractions: true);
    }
  }

  void _requestResources(_Request request) {
    setState(() => _interactable = false);
    _interactions.last.requestResources(request);
    _scrollToBottom();
    _showDelayed(const Duration(milliseconds: 200), () => _showResponse = true, allowInteractions: _interactions.last.isRequestSuccessful!);
    if (!_interactions.last.isRequestSuccessful!) _showDelayed(const Duration(milliseconds: 700), _startInteraction);
  }

  void _distributeResources(_Request request) {
    setState(() => _interactable = false);
    _interactions.last.distributeResources(request);
    _scrollToBottom();
    _showDelayed(const Duration(milliseconds: 200), () => _showResponse = true, allowInteractions: true);
  }

  void _submit() {
    setState(() => _interactable = false);
    _interactions.last.submit();
    context.read<Game>().distributeResources(
          context.read<Region>(),
          switch (_interactions.last.request) { _RequestWater() => -_interactions.last.value.round(), _DistributeWater() => _interactions.last.value.round(), _ => 0 },
          switch (_interactions.last.request) { _RequestFood() => -_interactions.last.value.round(), _DistributeFood() => _interactions.last.value.round(), _ => 0 },
        );
    _scrollToBottom();
    _showDelayed(const Duration(milliseconds: 200), () => _showFinalResponse = true);
    _showDelayed(const Duration(milliseconds: 700), _startInteraction);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<Game>();
    final region = context.read<Region>();

    final lastInteraction = _interactions.last;

    final buttonTextStyle = Theme.of(context).textTheme.labelLarge!;
    final buttonHeight = (MediaQuery.textScalerOf(context).scale(buttonTextStyle.fontSize!) * buttonTextStyle.height!).roundToDouble() + getTextPadding(context, buttonTextStyle, 2, 2).vertical;

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _messagesScrollController,
            cacheExtent: 9999999999999,
            children: [
              for (final interaction in _interactions) ...[
                Text(interaction.month, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.75))),
                _Message(text: interaction.state, alignLeft: true),
                if (interaction.foreshadowing != null && (interaction != lastInteraction || _showForeshadowing)) ...[const Gap(8), _Message(text: interaction.foreshadowing!, alignLeft: true)],
                if (interaction.request != null) ...[const Gap(8), _Message(text: interaction.request!.message, alignLeft: false)],
                if (interaction.response != null && (interaction != lastInteraction || _showResponse)) ...[const Gap(8), _Message(text: interaction.response!, alignLeft: true)],
                if (interaction.offer != null) ...[const Gap(8), _Message(text: interaction.offer!, alignLeft: false)],
                if (interaction.finalResponse != null && (interaction != lastInteraction || _showFinalResponse)) ...[const Gap(8), _Message(text: interaction.finalResponse!, alignLeft: true)],
                if (interaction != _interactions.last) const Gap(32),
              ],
            ],
          ),
        ),
        const Gap(16),
        if (!_interactable)
          SizedBox(height: buttonHeight + 2 * ContainerCardSize.medium.size)
        else if (lastInteraction.request == null)
          ContainerCard(
            size: ContainerCardSize.medium,
            child: Row(
              children: [
                Expanded(child: Button(text: 'Wasser anfragen', onPressed: () => _requestResources(_RequestWater()))),
                const Gap(8),
                Expanded(child: Button(text: 'Essen anfragen', onPressed: () => _requestResources(_RequestFood()))),
                const Gap(8),
                Expanded(child: Button(text: 'Wasser abgeben', onPressed: game.water == 0 ? null : () => _distributeResources(_DistributeWater()))),
                const Gap(8),
                Expanded(child: Button(text: 'Essen abgeben', onPressed: game.food == 0 ? null : () => _distributeResources(_DistributeFood()))),
              ],
            ),
          )
        else
          ContainerCard(
            size: ContainerCardSize.medium,
            child: Row(
              children: [
                Expanded(
                  child: SnappingSlider(
                    value: lastInteraction.value,
                    secondaryTrackValue: switch (lastInteraction.request!) {
                      _RequestWater() => region.water - region.maximumWater,
                      _RequestFood() => region.food - region.maximumFood,
                      _DistributeWater() => region.maximumWater - region.water,
                      _DistributeFood() => region.maximumFood - region.food,
                    }
                        .toDouble(),
                    onChanged: (value) => setState(() => lastInteraction.value = value),
                    snapValues: switch (lastInteraction.request!) {
                      _RequestWater() => [(region.water - region.maximumWater).toDouble(), (region.water - region.requiredWater).toDouble()],
                      _RequestFood() => [(region.food - region.maximumFood).toDouble(), (region.food - region.requiredFood).toDouble()],
                      _DistributeWater() => [(region.requiredWater - region.water).toDouble(), (region.maximumWater - region.water).toDouble()],
                      _DistributeFood() => [(region.requiredFood - region.food).toDouble(), (region.maximumFood - region.food).toDouble()],
                    },
                    max: switch (lastInteraction.request!) {
                      _RequestWater() => region.water,
                      _RequestFood() => region.food,
                      _DistributeWater() => game.water,
                      _DistributeFood() => game.food,
                    }
                        .toDouble(),
                  ),
                ),
                const Gap(16),
                Button(text: 'Senden', onPressed: lastInteraction.value.round() == 0 ? null : () => _submit()),
                const Gap(16),
                Button(text: 'Abbrechen', onPressed: () => _startInteraction()),
              ],
            ),
          ),
      ],
    );
  }
}

class _Interaction {
  _Interaction(this.game, this.region) : month = game.month {
    event = _chooseEventBasedOnLevel(region.exportBlockingEvents.isEmpty ? game.activeEvents : region.exportBlockingEvents);
    state = _generateStateMessage();
    foreshadowing = _generateForeshadowingMessage();
  }

  final Game game;
  final Region region;

  final String month;

  late final Event? event;
  late final String state;
  late final String? foreshadowing;
  _Request? request;
  String? response;
  bool? isRequestSuccessful;
  double value = 0;
  String? offer;
  String? finalResponse;

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

  String _generateStateMessage() {
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

    if (event == null ||
        (event is PlantDiseaseEvent && region.foodState != ResourceState.bad) ||
        (event is WaterPollutionEvent && region.waterState != ResourceState.bad) ||
        Random().nextDouble() < 0.25) {
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
      PandemicEvent() when region.foodState == ResourceState.bad && Random().nextBool() =>
        'Unsere Bekölkerung hamstert panisch Nahrungsmittel. Dabei sind unsere Vorräte so gut wie ausgeschöpft. Wir brauchen Hilfe!',
      PandemicEvent() when Random().nextBool() =>
        'Einige meiner Länder stecken gerade in einer tiefen Krise. Zu viele Menschen stecken gerade in Quarantäne und die Wirtschaft fährt herunter. Sie sind auf Waren von außen angewiesen. Helft uns!',
      PandemicEvent() => 'Viele Menschen können wegen der Pandemie nicht zur Arbeit erscheinen. Unsere Wirtschaft fährt herunter und die Supermärkte stehen leer. Wir sind auf Hilfspakete angewiesen.',
      InflationEvent() when region.foodState == ResourceState.bad && Random().nextBool() =>
        'Durch die hohe Inflation herrscht bei uns gerade eine Verknappung an Nahrungsmittel. Unsere Büger*innen können sich die Preise nicht leisten. Wir brauchen Hilfe.',
      InflationEvent() when region.foodState == ResourceState.bad =>
        'Aufgrund verschiedensten Krisen, steigen die Nahrungsmittelpreise. Viele Menschen können sich keine gesunde Ernährung mehr leisten. Können Sie uns Abhilfe verschaffen?',
      InflationEvent() =>
        'Die Inflationsrate ist so hoch wie nie. Der Lebensstandard unserer Bevölkerung sinkt deswegen. Können Sie uns zumindest in einem Aspekt helfen, damit es unserer Bevölkerung besser geht?',
      WarEvent() when region.exportBlockingEvents.contains(event) && region.foodState == ResourceState.bad =>
        'Handelsblockaden verhindern den Import von lebenswichtigen Nahrungsmitteln. Unsere Bevölkerung hungert. Wir brauchen dringend Hilfspakete.',
      WarEvent() when region.exportBlockingEvents.contains(event) && Random().nextBool() =>
        'Eine Kriegspartei droht, Lebensmittelexporte teurer zu machen. Können Sie uns helfen, uns etwas unabhängiger von ihren Lieferungen zu machen?',
      WarEvent() when region.exportBlockingEvents.contains(event) =>
        'Der Handel mit verschiedenen Ländern ist aufgrund des Krieges eingeschränkt. Dabei sind wir sehr von deren Importen abhängig. Wir brauchen Hilfe!',
      WarEvent() when Random().nextBool() => 'Wir haben viele Geflüchtete aufgenommen und die Preissteigerungen aufgrund des Krieges setzen uns sehr zu. Können Sie uns helfen?',
      WarEvent() => 'Auch wenn wir keine direkte Kriegspartei sind, treffen uns die Sanktionen und Handelsembargos sehr. Können Sie uns die benötigten Ressourcen bereitstellen?',
      NatureEvent() when Random().nextDouble() < 0.3 =>
        'Der Klimawandel trifft uns sehr hart. Ernten werden zerstört, Wasser verschmutzt und viele Menschen sterben, was auch die Zahl der Arbeitskräfte beeinflusst. Können wir auf Hilfspakete zählen?',
      NatureEvent(level: 1) => 'Wir haben durch die großen Überflutungen in vielen Ländern kaum Lebensmittel und sauberes Trinkwasser mehr. Wir können Hilfspakete gut gebrauchen.',
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

  String? _generateForeshadowingMessage() {
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

  void requestResources(_Request type) {
    request = type;
    isRequestSuccessful = !region.isExportBlocked &&
        region.waterState != ResourceState.bad &&
        region.waterState != ResourceState.panic &&
        region.foodState != ResourceState.bad &&
        region.foodState != ResourceState.panic;

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

  static const List<String> _thankingMessages = [
    'Dankeschön!',
    'Dankschön, wir schätzen es sehr.',
    'Unsere Bevölkerung dankt.',
    'Ihretwegen wird es vielen Menschen besser gehen.',
    'Danke, wir schätzen Ihre Hilfe sehr.',
    'Die Ressourcen nehmen wir gerne an.',
    'Unsere Population wird Ihnen sehr dankbar sein.',
    'Jegliche Unterstützung ist gerne gesehen. Wir bedanken uns bei Ihnen.',
  ];

  void distributeResources(_Request type) {
    request = type;
    isRequestSuccessful = true;
    response = [
      ..._thankingMessages,
      'Danke für die Unterstützung! Wie viel ${type is _RequestWater ? 'Wasser' : 'Essen'} möchten Sie uns geben?',
      '${type is _RequestWater ? 'Wasser' : 'Essen'} ist bei unserer Lage gerne gesehen. Danke.',
      'Das ist wirklich super! Wie viel können Sie entbehren?',
    ][Random().nextInt(11)];
  }

  void submit() {
    final value = this.value.round();
    final resource = request is _RequestWater || request is _DistributeWater ? 'Wasser' : 'Essen';

    offer = switch (request!) {
      _RequestWater() || _RequestFood() => [
          'Ich würde gerne $value $resource nehmen.',
          'Ich nehme $value $resource.',
          'Ich brauche $value $resource.',
          'Um den Bedürftigen zu helfen, brauche ich $value $resource.',
        ][Random().nextInt(4)],
      _DistributeWater() when value <= (region.requiredWater - region.water) / 2 => 'Ich kann Ihnen leider nur $value Wasser geben.',
      _DistributeFood() when value <= (region.requiredFood - region.food) / 2 => 'Ich kann Ihnen leider nur $value Essen geben.',
      _DistributeWater() || _DistributeFood() => [
          'Ich kann Ihnen $value $resource anbieten.',
          'Ich kann Ihnen $value $resource geben.',
          'Ich gebe Ihnen $value $resource.',
        ][Random().nextInt(3)],
    };

    finalResponse = switch (request!) {
      _RequestWater() when (region.water - value) / region.requiredWater < 0.5 => 'Jetzt haben wir viel zu wenig Wasser! Wir können unsere Bevölkerung nicht mehr ausreichend versorgen!',
      _RequestFood() when (region.food - value) / region.requiredFood < 0.5 => 'Jetzt haben wir viel zu wenig Essen! Wir können unsere Bevölkerung nicht mehr ausreichend versorgen!',
      _RequestWater() when (region.water - value) / region.requiredWater < 0.9 => 'Es ist zwar schön, dass wir helfen konnten, aber jetzt haben wir selber zu wenig Wasser!',
      _RequestFood() when (region.food - value) / region.requiredFood < 0.9 => 'Es ist zwar schön, dass wir helfen konnten, aber jetzt haben wir selber zu wenig Essen!',
      _RequestWater() || _RequestFood() => ['Ok', 'Das stellen wir gerne bereit.', 'Gut, dass wir helfen konnten!'][Random().nextInt(3)],
      _DistributeWater() when value < (region.requiredWater - region.water) / 4 => 'Danke für Nichts.',
      _DistributeFood() when value < (region.requiredFood - region.food) / 4 => 'Danke für Nichts.',
      _DistributeWater() when value < (region.requiredWater - region.water) / 3 => 'Sie sind ja ganz schön sparsam.',
      _DistributeFood() when value < (region.requiredFood - region.food) / 3 => 'Sie sind ja ganz schön sparsam.',
      _DistributeWater() when (region.water + value) / region.requiredWater < 0.75 => 'So wenig? Na ja, immerhin etwas.',
      _DistributeFood() when (region.food + value) / region.requiredFood < 0.75 => 'So wenig? Na ja, immerhin etwas.',
      _DistributeWater() when (region.water + value) / region.maximumWater > 1 => 'Mit so viel haben wir wirklich nicht gerechnet. Danke!',
      _DistributeFood() when (region.food + value) / region.maximumFood > 1 => 'Mit so viel haben wir wirklich nicht gerechnet. Danke!',
      _DistributeWater() || _DistributeFood() => _thankingMessages[Random().nextInt(8)],
    };
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

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.alignLeft});

  final String text;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      widthFactor: 0.7,
      child: Align(
        alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: TextCard(text: text),
            ),
          ),
        ),
      ),
    );
  }
}
