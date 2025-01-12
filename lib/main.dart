import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:geocibus/menus/main.dart';
import 'package:geocibus/theme.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  runApp(const App());

  doWhenWindowReady(() {
    windowManager.setFullScreen(true);
    appWindow.show();
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geocibus',
      theme: getTheme(),
      debugShowCheckedModeBanner: false,
      home: const MainMenu(),
    );
  }
}
