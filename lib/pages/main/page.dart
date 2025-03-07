import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/pages/finish.dart';
import 'package:geocibus/pages/main/end_year.dart';
import 'package:geocibus/pages/main/events.dart';
import 'package:geocibus/pages/main/map.dart';
import 'package:geocibus/pages/main/resources.dart';
import 'package:geocibus/pages/main/round_beginning_overlay.dart';
import 'package:geocibus/pages/main/shop.dart';
import 'package:geocibus/pages/main/top.dart';
import 'package:provider/provider.dart';

// TODO Intro story for a tutorial

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final Game _game;

  @override
  void initState() {
    super.initState();
    _game = Game()..addListener(_handleGameChanged);
    _handleGameChanged();
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _handleGameChanged() {
    if (_game.roundState != RoundState.beginning) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final navigator = Navigator.of(context);
      if (_game.round == 10) {
        navigator.pushReplacement(MaterialPageRoute(builder: (context) => FinishPage(_game)));
        return;
      }
      if (navigator.canPop()) navigator.pop();
      showDialog(context: context, barrierDismissible: false, builder: (context) => RoundBeginningOverlay(_game));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _game,
      child: const Scaffold(
        floatingActionButton: MainEndYear(),
        body: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              MainTop(),
              Expanded(
                child: Row(
                  children: [
                    MainEvents(),
                    Expanded(child: MainMap()),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [MainResources(), Gap(8), MainShop()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
