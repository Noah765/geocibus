import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sowi/game.dart';
import 'package:sowi/pages/map.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Game(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark)),
        debugShowCheckedModeBanner: false,
        home: const MapPage(),
      ),
    );
  }
}
