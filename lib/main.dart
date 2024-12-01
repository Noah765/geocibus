import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:sowi/start_page.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004AAD),
          brightness: Brightness.dark,
          surface: const Color(0xFF004AAD),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontSize: 40),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            minimumSize: const Size(double.infinity, 0),
            side: const BorderSide(color: Colors.white, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            side: const BorderSide(width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const StartPage(),
    );
  }
}
