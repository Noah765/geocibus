import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:sowi/menus/main.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.vibrant, // TODO: Test out all of these options
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainMenu(),
    );
  }
}
