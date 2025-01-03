import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/models/region.dart';

class ResourceIndicator extends StatelessWidget {
  const ResourceIndicator(this.region, {super.key});

  final Region region;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resourceLabelTextStyle = theme.textTheme.labelMedium!.copyWith(
      fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.labelMedium!.fontSize!),
      fontWeight: MediaQuery.boldTextOf(context) ? FontWeight.bold : null,
    );
    final resourceLabelTextHeight = resourceLabelTextStyle.fontSize! * resourceLabelTextStyle.height!;

    return Column(
      children: [
        Text('Wasser', style: theme.textTheme.titleMedium),
        // TODO Choose different colors
        CustomPaint(
          painter: _Painter(
            current: region.water,
            required: region.requiredWater,
            maximum: region.maximumWater,
            currentColor: theme.colorScheme.primary,
            requiredColor: theme.colorScheme.secondaryContainer,
            maximumColor: theme.colorScheme.surfaceContainer,
            textStyle: resourceLabelTextStyle,
          ),
          size: Size(240, resourceLabelTextHeight * 2 + 12),
        ),
        const Gap(8),
        Text('Essen', style: theme.textTheme.titleMedium),
        CustomPaint(
          painter: _Painter(
            current: region.food,
            required: region.requiredFood,
            maximum: region.maximumFood,
            currentColor: theme.colorScheme.primary,
            requiredColor: theme.colorScheme.secondaryContainer,
            maximumColor: theme.colorScheme.surfaceContainer,
            textStyle: resourceLabelTextStyle,
          ),
          size: Size(240, resourceLabelTextHeight * 2 + 12),
        ),
      ],
    );
  }
}

class _Painter extends CustomPainter {
  const _Painter({
    required this.current,
    required this.required,
    required this.maximum,
    required this.currentColor,
    required this.requiredColor,
    required this.maximumColor,
    required this.textStyle,
  });

  final int current;
  final int required;
  final int maximum;

  final Color currentColor;
  final Color requiredColor;
  final Color maximumColor;

  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final textHeight = _getTextSize('', textStyle).height;
    final lineHeight = size.height - 2 * textHeight;

    if (maximum > current) _drawLine(canvas, size, lineHeight, maximum, maximumColor);
    if (required > current) _drawLine(canvas, size, lineHeight, required, requiredColor);
    _drawLine(canvas, size, lineHeight, current, currentColor);

    final minimalTextSpacing = textHeight / 3;

    final currentWidth = size.width * min(1, current / maximum);
    final requiredWidth = size.width * required / maximum;

    final currentNumberWidth = _getTextSize(current.toString(), textStyle).width;
    final currentLabelWidth = _getTextSize('Aktuell', textStyle).width;
    final currentNumberOffset = max(0.0, (currentWidth - currentNumberWidth) / 2);
    final currentLabelOffset = max(0.0, (currentWidth - currentLabelWidth) / 2);
    _drawText(canvas, current.toString(), textStyle, Offset(currentNumberOffset, 0));
    _drawText(canvas, 'Aktuell', textStyle, Offset(currentLabelOffset, textHeight + lineHeight));

    // TODO Maybe align this correctly relative to current when current > maximum
    final maximumNumberWidth = _getTextSize(maximum.toString(), textStyle).width;
    final maximumLabelWidth = _getTextSize('Maximal', textStyle).width;
    final maximumNumberOffset = min(size.width - maximumNumberWidth, (size.width + max(currentWidth, requiredWidth) - maximumNumberWidth) / 2);
    final maximumLabelOffset = min(size.width - maximumLabelWidth, (size.width + max(currentWidth, requiredWidth) - maximumLabelWidth) / 2);
    _drawText(canvas, maximum.toString(), textStyle, Offset(maximumNumberOffset, 0));
    _drawText(canvas, 'Maximal', textStyle, Offset(maximumLabelOffset, textHeight + lineHeight));

    if (current >= required) return;
    final requiredNumberWidth = _getTextSize(required.toString(), textStyle).width;
    final requiredLabelWidth = _getTextSize('Benötigt', textStyle).width;
    final requiredTextCenterMin =
        max(currentWidth, max(currentNumberOffset + currentNumberWidth + requiredNumberWidth / 2, currentLabelOffset + currentLabelWidth + requiredLabelWidth / 2) + minimalTextSpacing);
    final requiredTextCenterMax = min(requiredWidth, min(maximumNumberOffset - requiredNumberWidth / 2, maximumLabelOffset - maximumLabelWidth / 2) - minimalTextSpacing);
    if (requiredTextCenterMin > requiredTextCenterMax) return;
    final requiredTextCenter = clampDouble((requiredWidth + currentWidth) / 2, requiredTextCenterMin, requiredTextCenterMax);
    _drawText(canvas, required.toString(), textStyle, Offset(requiredTextCenter - requiredNumberWidth / 2, 0));
    _drawText(canvas, 'Benötigt', textStyle, Offset(requiredTextCenter - requiredLabelWidth / 2, textHeight + lineHeight));
  }

  void _drawLine(Canvas canvas, Size size, double height, int end, Color color) {
    canvas.drawLine(
      Offset(height / 2, size.height / 2),
      Offset(max(height / 2, size.width * min(1, end / maximum) - height / 2), size.height / 2),
      Paint()
        ..strokeWidth = height
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  Size _getTextSize(String text, TextStyle textStyle) {
    final paragraph = _getParagraph(text, textStyle);
    final size = Size(paragraph.minIntrinsicWidth, paragraph.height);
    paragraph.dispose();
    return size;
  }

  void _drawText(Canvas canvas, String text, TextStyle textStyle, Offset offset) {
    final paragraph = _getParagraph(text, textStyle);
    canvas.drawParagraph(paragraph, offset);
    paragraph.dispose();
  }

  Paragraph _getParagraph(String text, TextStyle textStyle) => (ParagraphBuilder(textStyle.getParagraphStyle())
        ..pushStyle(textStyle.getTextStyle())
        ..addText(text))
      .build()
    ..layout(const ParagraphConstraints(width: double.infinity));

  @override
  bool shouldRepaint(_Painter oldDelegate) =>
      current != oldDelegate.current ||
      required != oldDelegate.required ||
      maximum != oldDelegate.maximum ||
      currentColor != oldDelegate.currentColor ||
      requiredColor != oldDelegate.requiredColor ||
      maximumColor != oldDelegate.maximumColor ||
      textStyle != oldDelegate.textStyle;
}
