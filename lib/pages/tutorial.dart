import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/pages/main/page.dart';
import 'package:geocibus/pages/start.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

enum TutorialNavigationTarget { startPage, mainPage, back }

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key, required this.navigationTarget});

  final TutorialNavigationTarget navigationTarget;

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late final VideoPlayerController _videoPlayerController;
  late final ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset('assets/tutorial.mp4')..initialize();
    _chewieController = ChewieController(videoPlayerController: _videoPlayerController, autoPlay: true, showOptions: false);
    SharedPreferences.getInstance().then((value) => value.setBool('watchedTutorial', true));
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void _onNavigate() {
    if (widget.navigationTarget == TutorialNavigationTarget.back) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => widget.navigationTarget == TutorialNavigationTarget.startPage ? const StartPage() : const MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(child: Chewie(controller: _chewieController)),
            const Gap(16),
            Button(
              text: switch (widget.navigationTarget) {
                TutorialNavigationTarget.startPage => 'Zurück zum Hauptmenü',
                TutorialNavigationTarget.mainPage => 'Spiel starten',
                TutorialNavigationTarget.back => 'Zurück',
              },
              style: Theme.of(context).textTheme.headlineMedium,
              onPressed: _onNavigate,
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}
