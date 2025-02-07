import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/theme.dart';
import 'package:window_manager/window_manager.dart';

final routeObserver = RouteObserver();

void main() {
  runApp(const _App());

  doWhenWindowReady(() {
    windowManager.setFullScreen(true);
    appWindow.show();
  });
}

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
