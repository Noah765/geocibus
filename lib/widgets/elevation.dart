import 'package:flutter/material.dart';

class Elevation extends StatelessWidget {
  const Elevation({super.key, this.symmetricalPadding = true, required this.child});

  final bool symmetricalPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: symmetricalPadding ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black),
        child: IconTheme.merge(
          data: const IconThemeData(color: Colors.black),
          child: child,
        ),
      ),
    );
  }
}
