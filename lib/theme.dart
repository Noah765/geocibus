import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ThemeData getTheme() {
  // TODO Check every Theme.of(context).colorScheme to confirm they use the right property
  final colors = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.green,
    onPrimary: Colors.green.shade700,
    secondary: Colors.lightGreen,
    onSecondary: Colors.lightGreen.shade700,
    tertiary: Colors.lime,
    error: Colors.transparent,
    onError: Colors.transparent,
    surface: Colors.blue.shade900,
    onSurface: Colors.black,
    surfaceContainerLow: Colors.grey.shade200,
  );

  final typography = Typography.material2021(platform: defaultTargetPlatform, colorScheme: colors);
  final textTheme = typography.englishLike.merge(typography.black);

  OutlinedBorder getShape(double borderWidth, [double borderRadius = 12]) =>
      RoundedRectangleBorder(side: BorderSide(color: colors.outline, width: borderWidth), borderRadius: BorderRadius.circular(borderRadius));

  // TODO Compare and fix up all paddings using fixed rules (including custom button styles scattered over the codebase)
  // TODO Elevation (debugDisableShadows may also be used)

  return ThemeData(
    colorScheme: colors,
    fontFamily: 'Roboto',
    // TODO Compare elevation of different components
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
          if (states.contains(WidgetState.focused)) return colors.onSurface.withOpacity(0.08);
          return Colors.transparent;
        }),
        shape: WidgetStatePropertyAll(getShape(2)),
        visualDensity: VisualDensity.comfortable,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: colors.onSurface,
      backgroundColor: colors.surfaceContainerLow,
      focusColor: colors.onSurface.withOpacity(0.1),
      hoverColor: colors.onSurface.withOpacity(0.08),
      splashColor: colors.onSurface.withOpacity(0.1),
      // TODO Elevation
      shape: getShape(3, 16),
      iconSize: 32,
      sizeConstraints: const BoxConstraints.tightFor(width: 72, height: 72),
    ),
    // TODO Display tooltip when hovering over padding
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
        padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
        minimumSize: const WidgetStatePropertyAll(Size(36, 36)),
        shape: WidgetStatePropertyAll(getShape(3)),
      ),
    ),
    // TODO Elevation
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: colors.surfaceContainerLow, border: Border.all(color: colors.outline), borderRadius: BorderRadius.circular(8)),
      textStyle: textTheme.labelMedium,
    ),
  );
}
