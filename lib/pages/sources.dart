import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/text_with_links.dart';

class SourcesPage extends StatelessWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData(:textTheme, colorScheme: colors) = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            Text(
              'Quellen',
              style: textTheme.displayLarge!.copyWith(color: colors.surfaceContainerLow, fontSize: textTheme.displayLarge!.fontSize! * 2),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Die folgenden Daten wurden ausgewertet, um den Nahrungsmittelkonsum, die Nahrungsmittelproduktion, die Auswirkungen von Events usw. so realistisch wie möglich zu modellieren. Die ermittelten Werte wurden für die Zwecke des Spiels angepasst.',
              style: textTheme.titleMedium!.copyWith(color: colors.surfaceContainerLow),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            TextWithLinks(
              style: textTheme.bodyMedium!.copyWith(color: colors.surfaceContainerLow),
              textAlign: TextAlign.center,
              '''
https://www.welthungerhilfe.de/welternaehrung/rubriken/agrar-ernaehrungspolitik/der-globale-nahrungsmittelausblick [1]
https://www.fian.de/was-wir-machen/themen/ernaehrungsarmut-in-deutschland/ [2]
https://www.bundesregierung.de/breg-de/schwerpunkteder-bundesregierung/produzieren-konsumieren-181666 [3]
https://www.welthungerhilfe.de/welternaehrung/rubriken/agrar-ernaehrungspolitik/ungesund-afrikas-staedte-ernaehren-sich-einseitig [4]
https://de.statista.com/ [5.0]
https://de.statista.com/statistik/daten/studie/1196858/umfrage/entwicklung-der-weltweit-zur-verfuegung-stehenden-kalorien/ [5.1]
https://de.statista.com/statistik/daten/studie/271432/umfrage/praevalenz-von-unterernaehrung-nach-weltregion/ [5.2]
https://de.statista.com/infografik/27066/anteil-der-befragten-die-wasser-und-nahrungsversorgung-fuer-eine-grosse-herausforderung-halten/ [5.3]
https://de.statista.com/statistik/daten/studie/1198154/umfrage/zur-verfuegung-stehende-kalorien-nach-weltregion/ [5.4]
https://de.statista.com/statistik/daten/studie/1198917/umfrage/anzahl-an-mangelernaehrung-verstorbener-menschen-weltweit/ [5.5]
https://de.statista.com/statistik/daten/studie/1195334/umfrage/kosten-fuer-gesunde-ernaehrung-weltweit-pro-kopf/ [5.6]
https://de.statista.com/statistik/daten/studie/1196854/umfrage/praevalenz-von-unterernaehrung-in-afrika/ [5.7]
https://de.statista.com/statistik/daten/studie/1274354/umfrage/nahrungsmittelunsicherheit-weltweit/ [5.8]
https://de.statista.com/statistik/daten/studie/1195964/umfrage/prognose-zum-anstieg-des-globalen-fleischkonsums/ [5.9]
https://de.statista.com/statistik/daten/studie/1198827/umfrage/schulkinder-mit-unter-oder-uebergewicht-nach-weltregion/ [5.10]
https://de.statista.com/statistik/daten/studie/1195363/umfrage/menschen-mit-zu-wenig-geld-fuer-nahrung-in-krisenlaendern/ [5.11]
https://de.statista.com/statistik/daten/studie/165561/umfrage/am-staerksten-von-hunger-betroffene-laender-weltweit-nach-dem-welthunger-index/ [5.12]
https://de.statista.com/statistik/daten/studie/1198137/umfrage/taegliche-kalorienzufuhr-pro-kopf-in-verschiedenen-weltregionen/ [5.13]
https://de.statista.com/statistik/daten/studie/1723/umfrage/weltbevoelkerung-nach-kontinenten/ [5.14]
https://de.statista.com/statistik/daten/studie/184686/umfrage/weltbevoelkerung-nach-kontinenten/ [5.15]
https://de.statista.com/statistik/daten/studie/1422119/umfrage/bevoelkerungsentwicklung-nach-kontinenten-und-weltweit [5.16]
https://de.statista.com/statistik/daten/studie/1276366/umfrage/laender-mit-der-hoechsten-praevalenz-von-akutem-hunger/ [5.17]
https://www.statista.com/outlook/io/manufacturing/consumer-goods/food/worldwide#value-added [5.18]
https://www.statista.com/statistics/267268/production-of-wheat-worldwide-since-1990/ [5.19]
https://www.statista.com/statistics/270024/global-stocks-of-wheat/ [5.20]
https://www.statista.com/statistics/1294190/production-volume-of-wheat-in-africa/ [5.21]
https://www.statista.com/topics/1668/wheat/ [5.22]
https://ourworldindata.org/food-supply [6.1]
https://ourworldindata.org/water-use-stress [6.2]
https://www.researchgate.net/figure/Renewable-Water-Resources-and-Water-Availability-by-Continents_tbl1_265432820 [7.0]
https://www.tk.de/techniker/magazin/ernaehrung/uebergewicht-und-diaet/wie-viele-kalorien-pro-tag-2006758 [8.0]
              ''',
            ),
            const Gap(40),
            Center(child: Button(text: 'Zurück', style: textTheme.headlineMedium, borderWidth: 3, onPressed: () => Navigator.of(context).pop())),
          ],
        ),
      ),
    );
  }
}
