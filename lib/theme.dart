import 'package:flutter/material.dart';

ThemeData getTheme() {
  // TODO Check every Theme.of(context).colorScheme to confirm they use the right property
  final colors = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.blue.shade700, // TODO
    onPrimary: Colors.transparent,
    secondary: Colors.transparent,
    onSecondary: Colors.transparent,
    error: Colors.transparent,
    onError: Colors.transparent,
    surface: Colors.blue.shade900,
    onSurface: Colors.black,
    surfaceContainerLow: Colors.white,
  );

  OutlinedBorder getShape(double borderWidth) => RoundedRectangleBorder(side: BorderSide(color: colors.outline, width: borderWidth), borderRadius: BorderRadius.circular(12));

  return ThemeData(
    colorScheme: colors,
    fontFamily: 'Roboto',
    // TODO Because of https://github.com/fluttercommunity/font_awesome_flutter/issues/270, icons are taller than expected
    iconTheme: IconThemeData(size: 20, color: colors.onSurface, applyTextScaling: true),
    cardTheme: CardTheme(margin: EdgeInsets.zero, shape: getShape(3)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.onSurface.withOpacity(0.38);
          return colors.onSurface;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return colors.onSurface.withOpacity(0.1);
          if (states.contains(WidgetState.hovered)) return colors.onSurface.withOpacity(0.08);
          if (states.contains(WidgetState.focused)) return colors.onSurface.withOpacity(0.1);
          return Colors.transparent;
        }),
        shape: WidgetStatePropertyAll(getShape(2)),
        visualDensity: VisualDensity.comfortable,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
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
        minimumSize: const WidgetStatePropertyAll(Size(36, 36)),
        shape: WidgetStatePropertyAll(getShape(3)),
      ),
    ),
  );
}
