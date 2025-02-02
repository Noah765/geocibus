import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ThemeData getTheme() {
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

  return ThemeData(
    colorScheme: colors,
    fontFamily: 'Roboto',
    iconTheme: IconThemeData(size: 18, color: colors.onSurface, applyTextScaling: true),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: colors.surfaceContainerLow, border: Border.all(color: colors.outline), borderRadius: BorderRadius.circular(8)),
      textStyle: textTheme.labelMedium,
    ),
  );
}

EdgeInsets getTextPadding(BuildContext context, TextStyle textStyle, double borderWidth, double horizontalPadding) {
  final fontSize = MediaQuery.textScalerOf(context).scale(textStyle.fontSize!);
  final height = (fontSize * textStyle.height!).roundToDouble();
  final padding = (fontSize + 11) / 3;
  return EdgeInsets.symmetric(vertical: padding + fontSize / 2 - height / 2 + borderWidth, horizontal: horizontalPadding * padding + borderWidth);
}

RoundedRectangleBorder getTextShape(BuildContext context, TextStyle textStyle, Color borderColor, double borderWidth) {
  final height = 5 / 3 * textStyle.fontSize! + 22 / 3 + 2 * borderWidth;
  return RoundedRectangleBorder(side: BorderSide(color: borderColor, width: borderWidth), borderRadius: BorderRadius.circular(height * 0.3));
}

EdgeInsets getIconPadding(BuildContext context, double iconSize, double borderWidth) {
  final size = MediaQuery.textScalerOf(context).scale(iconSize);
  return EdgeInsets.all(size - 10 + borderWidth);
}

RoundedRectangleBorder getIconShape(BuildContext context, double iconSize, Color borderColor, double borderWidth) {
  final size = MediaQuery.textScalerOf(context).scale(iconSize) * 3 - 20 + 2 * borderWidth;
  return RoundedRectangleBorder(side: BorderSide(color: borderColor, width: borderWidth), borderRadius: BorderRadius.circular(size * 0.3));
}
