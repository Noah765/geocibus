import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sowi/models/region.dart';

class InteractCharacter extends StatelessWidget {
  const InteractCharacter({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Image loading indicator?
    return CustomPaint(
      painter: _Painter(Theme.of(context).colorScheme.surfaceContainerHighest),
      child: AspectRatio(
        aspectRatio: 258 / 607, // This is the largest aspect ratio of the characters
        child: Image.asset('assets/characters/${context.read<Region>().character}', fit: BoxFit.fitHeight),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  const _Painter(this.color);

  final Color color;

  // TODO Improve speech bubble arrow (arcs instead of lines)
  @override
  void paint(Canvas canvas, Size size) {} //=> canvas.drawPath(
  // TODO Remove?
  //Path()
  //  ..moveTo(size.width - size.width / 5, size.height / 10)
  //  ..lineTo(size.width, size.height / 12)
  //  ..lineTo(size.width, size.height / 8)
  //  ..lineTo(size.width - size.width / 5, size.height / 10),
  //Paint()..color = color,
  //);

  @override
  bool shouldRepaint(_Painter oldDelegate) => color != oldDelegate.color;
}
