import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/theme.dart';
import 'package:video_player_win/video_player_win.dart';

final routeObserver = RouteObserver();

void main() {
  if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();
  runApp(const _App());
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
