import 'package:flutter/material.dart';
import 'package:geocibus/theme.dart';

class ContainerCard extends StatelessWidget {
  const ContainerCard({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderWidth = 3,
    this.borderRadius = 20,
    required this.child,
  });

  final EdgeInsets padding;
  final double borderWidth;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      elevation: 1,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(side: BorderSide(color: colors.outline, width: borderWidth), borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(padding: padding, child: child),
    );
  }
}

class TextCard extends StatelessWidget {
  const TextCard({super.key, this.text, this.style, this.child}) : assert(text != null || child != null);

  final String? text;
  final TextStyle? style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = this.style ?? DefaultTextStyle.of(context).style;

    return Material(
      elevation: 1,
      color: colors.surfaceContainerLow,
      shape: getTextShape(context, style, colors.outline, 3),
      child: Padding(
        padding: getTextPadding(context, style, 3),
        child: text == null ? DefaultTextStyle(style: style, child: child!) : Text(text!, style: style),
      ),
    );
  }
}

class IconCard extends StatelessWidget {
  const IconCard({super.key, required this.icon, this.size});

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = this.size ?? IconTheme.of(context).size!;

    return Material(
      elevation: 1,
      color: colors.surfaceContainerLow,
      shape: getIconShape(context, size, colors.outline, 3),
      child: Padding(
        padding: getIconPadding(context, size, 3),
        child: Icon(icon, size: size),
      ),
    );
  }
}
