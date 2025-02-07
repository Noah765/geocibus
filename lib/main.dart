import 'package:flutter/material.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/theme.dart';

final routeObserver = RouteObserver();

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartPage(),
      navigatorObservers: [routeObserver],
      title: 'Geocibus',
      theme: getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
