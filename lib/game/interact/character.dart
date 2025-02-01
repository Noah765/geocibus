import 'package:flutter/material.dart';
import 'package:geocibus/models/region.dart';
import 'package:provider/provider.dart';

class InteractCharacter extends StatelessWidget {
  const InteractCharacter({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 258 / 607, // This is the largest aspect ratio of the characters
      child: Image.asset('assets/characters/${context.read<Region>().character}', fit: BoxFit.fitHeight),
    );
  }
}
