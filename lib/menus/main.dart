import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/game/main/page.dart';

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
                  WidgetSpan(
                    // TODO Correctly size and align the Icon
                    alignment: PlaceholderAlignment.middle,
                    child: FaIcon(FontAwesomeIcons.earthEurope, size: theme.textTheme.displayLarge!.fontSize),
                  ),
                  const TextSpan(text: 'CIBUS'),
                ],
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () => _start(context),
                    child: const Text('START'),
                  ),
                  OutlinedButton(
                    onPressed: _options,
                    child: const Text('OPTIONEN'),
                  ),
                  OutlinedButton(
                    onPressed: _leave,
                    child: const Text('SPIEL VERLASSEN'),
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
