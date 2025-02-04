import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/pages/main/page.dart';
import 'package:geocibus/pages/sources.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/icon_span.dart';
import 'package:geocibus/widgets/interactive_map.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  InteractiveMapData? _mapData;

  @override
  void initState() {
    super.initState();
    InteractiveMapData.load().then((value) => setState(() => _mapData = value));
  }

  void _start(BuildContext context) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));

  void _sources(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SourcesPage()));

  void _leave() => appWindow.close();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = theme.textTheme.displayMedium!;
    final mapColor = Colors.green.withOpacity(0.75);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                style: theme.textTheme.displayLarge!.copyWith(color: theme.colorScheme.surfaceContainerLow, fontSize: theme.textTheme.displayLarge!.fontSize! * 3),
                children: [
                  const TextSpan(text: 'GE'),
                  IconSpan(icon: FontAwesomeIcons.earthEurope),
                  const TextSpan(text: 'CIBUS'),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (_mapData != null)
                    Center(
                      child: AspectRatio(
                        aspectRatio: _mapData!.bounds.width / _mapData!.bounds.height,
                        child: InteractiveMap(
                          data: _mapData!,
                          colors: {Asia: mapColor, Africa: mapColor, Europe: mapColor, SouthAmerica: mapColor, NorthAmerica: mapColor, Australia: mapColor},
                        ),
                      ),
                    ),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 1 / 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Button(text: 'Start', style: buttonStyle, elevation: 3, borderWidth: 3, onPressed: () => _start(context)),
                          const Gap(16),
                          Button(text: 'Quellen', style: buttonStyle, elevation: 3, borderWidth: 3, onPressed: () => _sources(context)),
                          const Gap(16),
                          Button(text: 'Spiel verlassen', style: buttonStyle, elevation: 3, borderWidth: 3, onPressed: _leave),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
