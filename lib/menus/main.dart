import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/game/main/page.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/icon_span.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void _start(BuildContext context) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));

  void _options() {}

  void _leave() => appWindow.close();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                style: theme.textTheme.displayLarge,
                children: [
                  const TextSpan(text: 'GE'),
                  IconSpan(icon: FontAwesomeIcons.earthEurope),
                  const TextSpan(text: 'CIBUS'),
                ],
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Button(text: 'Start', onPressed: () => _start(context)),
                  Button(text: 'Optionen', onPressed: _options),
                  Button(text: 'Spiel verlassen', onPressed: _leave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
