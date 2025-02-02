import 'package:flutter/material.dart';
import 'package:geocibus/theme.dart';

enum ContainerCardSize {
  large(24),
  medium(20),
  small(16);

  const ContainerCardSize(this.size);

  final double size;
}

class ContainerCard extends StatelessWidget {
  const ContainerCard({
    super.key,
    required this.size,
    required this.child,
  });

  final ContainerCardSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      elevation: 1,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(side: BorderSide(color: colors.outline, width: 3), borderRadius: BorderRadius.circular(size.size)),
      child: Padding(padding: EdgeInsets.all(size.size), child: child),
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
        padding: getTextPadding(context, style, 3, 2),
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
