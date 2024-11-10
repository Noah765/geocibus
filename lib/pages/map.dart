import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:sowi/game.dart';
import 'package:sowi/pages/interact.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapShapeSource _mapSource;

  @override
  void initState() {
    super.initState();

    final regions = context.read<Game>().regions;

    _mapSource = MapShapeSource.asset(
      'assets/continents.json',
      shapeDataField: 'CONTINENT',
      dataCount: regions.length,
      primaryValueMapper: (index) => regions[index].name,
      //shapeColorValueMapper: (int index) => data[index].color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = context.watch<Game>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Karte. Runde ${game.round}'),
        actions: [
          IconButton(onPressed: () {}, tooltip: 'Einstellungen', icon: const Icon(Icons.settings)),
        ],
      ),
      body: Center(
        child: SfMaps(
          layers: [
            MapShapeLayer(
              source: _mapSource,
              showDataLabels: true,
              dataLabelSettings: MapDataLabelSettings(textStyle: theme.textTheme.labelMedium),
              shapeTooltipBuilder: (context, index) {
                final region = game.regions[index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(region.name, style: theme.textTheme.titleMedium),
                      const Gap(16),
                      Text('Essen', style: theme.textTheme.bodyMedium),
                      _ResourceIndicator(value: region.food, preferredValue: region.preferredFood),
                      const Gap(8),
                      Text('Wasser', style: theme.textTheme.bodyMedium),
                      //_ResourceIndicator(value: region.water, preferredValue: region.preferredWater),
                    ],
                  ),
                );
              },
              tooltipSettings: MapTooltipSettings(color: theme.colorScheme.surfaceContainer, strokeColor: theme.colorScheme.surfaceContainer),
              onSelectionChanged: (index) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => InteractPage(game.regions[index]))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceIndicator extends StatelessWidget {
  const _ResourceIndicator({required this.value, required this.preferredValue});

  final int value;
  final int preferredValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      painter: _ResourceIndicatorPainter(
        value: value,
        preferredValue: preferredValue,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primaryContainer,
        labelTextStyle: theme.textTheme.labelSmall!,
        labelColor: theme.colorScheme.secondary,
        valueMarkerTextStyle: theme.textTheme.labelLarge!,
        valueMarkerColor: theme.colorScheme.tertiary,
        preferredValueMarkerTextStyle: theme.textTheme.labelMedium!,
        preferredValueMarkerColor: theme.colorScheme.primary,
      ),
      size: const Size(120, 40),
    );
  }
}

typedef _LabelRects = ({Rect box, Rect text});
typedef _MarkerTextRects = ({Rect value, Rect preferredValue});

class _ResourceIndicatorPainter extends CustomPainter {
  const _ResourceIndicatorPainter({
    required this.value,
    required this.preferredValue,
    required this.color,
    required this.backgroundColor,
    required this.labelTextStyle,
    required this.labelColor,
    required this.valueMarkerTextStyle,
    required this.valueMarkerColor,
    required this.preferredValueMarkerTextStyle,
    required this.preferredValueMarkerColor,
  });

  final int value;
  final int preferredValue;

  final Color color;
  final Color backgroundColor;
  final TextStyle labelTextStyle;
  final Color labelColor;
  final TextStyle valueMarkerTextStyle;
  final Color valueMarkerColor;
  final TextStyle preferredValueMarkerTextStyle;
  final Color preferredValueMarkerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = preferredValue > value ? preferredValue : (value * 1.25).round();

    _drawBar(canvas, size.width, maxValue);
    final markerTextRects = _drawMarkers(canvas, size, maxValue);
    _drawLabels(canvas, size, maxValue, markerTextRects);
  }

  void _drawBar(Canvas canvas, double width, int maxValue) {
    final reachedWidth = value / maxValue * width;

    canvas.drawRect(Rect.fromLTRB(0, 0, reachedWidth, 12), Paint()..color = color);
    canvas.drawRect(Rect.fromLTRB(reachedWidth, 0, width, 12), Paint()..color = backgroundColor);
  }

  _MarkerTextRects _drawMarkers(Canvas canvas, Size size, int maxValue) {
    final valueRects = _computeLabelRects(value.toString(), valueMarkerTextStyle, value / maxValue * size.width, size);
    final preferredValueRects = _computeLabelRects(preferredValue.toString(), preferredValueMarkerTextStyle, preferredValue / maxValue * size.width, size);

    _paintLabel(canvas, valueRects, value.toString(), valueMarkerTextStyle);
    _paintLabel(canvas, preferredValueRects, preferredValue.toString(), preferredValueMarkerTextStyle);

    return (value: valueRects.text, preferredValue: preferredValueRects.text);
  }

  void _drawLabels(Canvas canvas, Size size, int maxValue, _MarkerTextRects markerTextRects) {
    final spacing = _computeLabelSpacing(maxValue);
    final pixelSpacing = spacing / maxValue * size.width;

    var pixelX = 0.0;
    for (var x = 0; x <= maxValue; x += spacing) {
      final rects = _computeLabelRects(x.toString(), labelTextStyle, pixelX, size);

      if (!(rects.text.right < markerTextRects.value.left || rects.text.left > markerTextRects.value.right) ||
          !(rects.text.right < markerTextRects.preferredValue.left || rects.text.left > markerTextRects.preferredValue.right)) continue;

      _paintLabel(canvas, rects, x.toString(), labelTextStyle);

      pixelX += pixelSpacing;
    }
  }

  int _computeLabelSpacing(int maxValue) {
    final preferredSpacing = maxValue / 3;
    final factor = pow(10, (log(preferredSpacing) / ln10).floor()) as int;

    if (preferredSpacing < 2 * factor) return 2 * factor;
    if (preferredSpacing < 2.5 * factor) return (2.5 * factor).round();
    if (preferredSpacing < 5 * factor) return 5 * factor;
    if (preferredSpacing < 7.5 * factor) return (7.5 * factor).round();
    return 10 * factor;
  }

  _LabelRects _computeLabelRects(String text, TextStyle textStyle, double x, Size size) {
    final textPainter = TextPainter(text: TextSpan(text: text, style: textStyle), textDirection: TextDirection.ltr)..layout();
    final textRect = Rect.fromLTWH(
      clampDouble(x - textPainter.width / 2, 0, size.width - textPainter.width),
      size.height - textPainter.height,
      textPainter.width,
      textPainter.height,
    );

    const boxWidth = 2.0;
    final boxRect = Rect.fromLTWH(
      clampDouble(x - boxWidth / 2, 0, size.width - boxWidth),
      0,
      boxWidth,
      size.height - textPainter.height,
    );

    textPainter.dispose();

    return (box: boxRect, text: textRect);
  }

  void _paintLabel(Canvas canvas, _LabelRects rects, String text, TextStyle textStyle) {
    canvas.drawRect(rects.box, Paint()..color = labelColor);

    TextPainter(text: TextSpan(text: text, style: textStyle), textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(rects.text.left, rects.text.top));
  }

  @override
  bool shouldRepaint(_ResourceIndicatorPainter oldDelegate) => false; // TODO
}
