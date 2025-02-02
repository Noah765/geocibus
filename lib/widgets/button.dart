import 'package:flutter/material.dart';
import 'package:geocibus/theme.dart';

abstract class Button extends StatelessWidget {
  const factory Button({Key? key, required String text, TextStyle? style, double elevation, double borderWidth, required VoidCallback? onPressed}) = _TextButton;
  const factory Button.icon({Key? key, required IconData icon, double? size, String? tooltip, required VoidCallback? onPressed}) = _IconButton;

  const Button._({super.key});

  static double getDefaultIconButtonWidth(BuildContext context) => _IconButton.getDefaultWidth(context);
}

class _TextButton extends Button {
  const _TextButton({super.key, required this.text, this.style, this.elevation = 1, this.borderWidth = 2, required this.onPressed}) : super._();

  final String text;
  final TextStyle? style;
  final double elevation;
  final double borderWidth;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = this.style ?? Theme.of(context).textTheme.labelLarge!;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.onSurface.withOpacity(0.38);
          return colors.onSurface;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return colors.onSurface.withOpacity(0.1);
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) return colors.onSurface.withOpacity(0.08);
          return null;
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return elevation;
          if (states.contains(WidgetState.hovered)) return elevation * 3;
          return elevation;
        }),
        padding: WidgetStatePropertyAll(getTextPadding(context, style, borderWidth, 3)),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        shape: WidgetStatePropertyAll(getTextShape(context, style, colors.outline, borderWidth)),
        visualDensity: VisualDensity.standard,
      ),
      child: Text(text, style: style),
    );
  }
}

class _IconButton extends Button {
  const _IconButton({super.key, required this.icon, this.size, this.tooltip, required this.onPressed}) : super._();

  final IconData icon;
  final double? size;
  final String? tooltip;
  final VoidCallback? onPressed;

  static double getDefaultWidth(BuildContext context) {
    final size = IconTheme.of(context).size!;
    return getIconPadding(context, size, 3).horizontal + MediaQuery.textScalerOf(context).scale(size);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = this.size ?? IconTheme.of(context).size!;

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.onSurface.withOpacity(0.12);
          return colors.surfaceContainerLow;
        }),
        shadowColor: WidgetStatePropertyAll(colors.shadow),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 1;
          if (states.contains(WidgetState.hovered)) return 3;
          return 1;
        }),
        padding: WidgetStatePropertyAll(getIconPadding(context, size, 3)),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        shape: WidgetStatePropertyAll(getIconShape(context, size, colors.onSurface, 3)),
      ),
      icon: Icon(icon, size: size),
    );
  }
}
