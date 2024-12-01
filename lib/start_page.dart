import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/game/page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  void _start(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const GamePage()));

  void _options() {}

  void _leave() => appWindow.close();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'GE'),
                      WidgetSpan(
                        child: Image.asset(
                          'assets/globe.png',
                          height: theme.textTheme.displayLarge!.fontSize,
                        ),
                      ),
                      const TextSpan(text: 'CIBUS'),
                    ],
                  ),
                  style: theme.textTheme.displayLarge,
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () => _start(context),
                    child: const Text('START'),
                  ),
                  const Gap(32),
                  OutlinedButton(
                    onPressed: _options,
                    child: const Text('OPTIONEN'),
                  ),
                  const Gap(32),
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
