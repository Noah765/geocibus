import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sowi/logic/game.dart';
import 'package:sowi/logic/region.dart';
import 'package:sowi/pages/interact.dart';
import 'package:sowi/pages/intro.dart';
import 'package:sowi/pages/market.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapShapeSource _mapSource;

  Color _computeRegionColor(Region region) {
    final missingResourcesPercentage = (region.food / region.preferredFood + region.water / region.preferredWater) / 2;
    return Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!;
  }

  @override
  void initState() {
    super.initState();

    _mapSource = MapShapeSource.asset(
      'assets/continents.json',
      shapeDataField: 'CONTINENT',
      dataCount: regions.length,
      primaryValueMapper: (index) => regions[index].name,
      shapeColorValueMapper: (index) => _computeRegionColor(regions[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Karte. Runde ${game.round}'),
        actions: [
          IconButton(onPressed: () {}, tooltip: 'Einstellungen', icon: const Icon(Icons.settings)),
        ],
      ),
      body: Column(
        children: [
          Text('Du besitzt ${game.food} Essen, ${game.water} Wasser und ${game.money} Geld'),
          Expanded(
            child: SfMaps(
              layers: [
                MapShapeLayer(
                  source: _mapSource,
                  showDataLabels: true,
                  dataLabelSettings: MapDataLabelSettings(textStyle: theme.textTheme.labelMedium),
                  shapeTooltipBuilder: (context, index) {
                    final region = regions[index];
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
                          _ResourceIndicator(value: region.water, preferredValue: region.preferredWater),
                        ],
                      ),
                    );
                  },
                  tooltipSettings: MapTooltipSettings(color: theme.colorScheme.surfaceContainer, strokeColor: theme.colorScheme.surfaceContainer),
                  onSelectionChanged: (index) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => InteractPage(regions[index]))),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              game.finishRound();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const IntroPage()));
            },
            child: const Text('Runde beenden'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MarketPage())),
            child: const Text('Ressourcen umwandeln'),
          ),
        ],
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
        lineColor: theme.colorScheme.secondary,
        textStyle: theme.textTheme.labelSmall!,
      ),
      // TODO Calculate the height dynamically using the text height and bar height
      size: const Size(120, 56),
    );
  }
}

class _ResourceIndicatorPainter extends CustomPainter {
  const _ResourceIndicatorPainter({
    required this.value,
    required this.preferredValue,
    required this.color,
    required this.backgroundColor,
    required this.lineColor,
    required this.textStyle,
  });

  static const barHeight = 12;
  static const lineWidth = 2.0;

  final int value;
  final int preferredValue;

  final Color color;
  final Color backgroundColor;
  final Color lineColor;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = preferredValue > value ? preferredValue : (value * 1.25).round();
    _drawBar(canvas, size, maxValue);
    _drawLabels(canvas, size, maxValue);
  }

  void _drawBar(Canvas canvas, Size size, int maxValue) {
    final top = size.height / 2 - barHeight / 2;
    final reachedWidth = value / maxValue * size.width;
    final freeWidth = size.width - reachedWidth;

    canvas.drawRect(Rect.fromLTWH(0, top, reachedWidth, 12), Paint()..color = color);
    canvas.drawRect(Rect.fromLTWH(reachedWidth, top, freeWidth, 12), Paint()..color = backgroundColor);
  }

  void _drawLabels(Canvas canvas, Size size, int maxValue) {
    final spacing = _computeLabelSpacing(maxValue);
    for (var x = 0; x <= maxValue; x += spacing) {
      _drawLabel(canvas: canvas, size: size, value: x, maxValue: maxValue);
    }

    _drawLabel(canvas: canvas, size: size, value: value, maxValue: maxValue, upwards: true);
    _drawLabel(canvas: canvas, size: size, value: preferredValue, maxValue: maxValue, upwards: true);
  }

  int _computeLabelSpacing(int maxValue) {
    final preferredSpacing = maxValue / 3;
    final factor = pow(10, max((log(preferredSpacing) / ln10).floor(), 0)) as int;

    if (preferredSpacing < 2 * factor) return 2 * factor;
    if (preferredSpacing < 2.5 * factor) return (2.5 * factor).round();
    if (preferredSpacing < 5 * factor) return 5 * factor;
    if (preferredSpacing < 7.5 * factor) return (7.5 * factor).round();
    return 10 * factor;
  }

  void _drawLabel({required Canvas canvas, required Size size, required int value, required int maxValue, bool upwards = false}) {
    final x = value / maxValue * size.width;

    final textPainter = TextPainter(text: TextSpan(text: value.toString(), style: textStyle), textDirection: TextDirection.ltr)..layout();

    final lineX = clampDouble(x, lineWidth / 2, size.width - lineWidth / 2);
    final lineYStart = upwards ? size.height / 2 + barHeight / 2 : size.height / 2 - barHeight / 2;
    final lineYEnd = upwards ? textPainter.height : size.height - textPainter.height;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;
    canvas.drawLine(Offset(lineX, lineYStart), Offset(lineX, lineYEnd), linePaint);

    final textX = clampDouble(x - textPainter.width / 2, 0, size.width - textPainter.width);
    final textY = upwards ? 0.0 : size.height - textPainter.height;
    textPainter
      ..paint(canvas, Offset(textX, textY))
      ..dispose();
  }

  @override
  bool shouldRepaint(_ResourceIndicatorPainter oldDelegate) => false; // TODO
}
