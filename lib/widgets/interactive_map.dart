import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocibus/models/region.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class InteractiveMap extends StatelessWidget {
  const InteractiveMap({
    super.key,
    required this.data,
    this.deads = const {},
    this.scales = const {Europe: 1, Asia: 1, NorthAmerica: 1, SouthAmerica: 1, Africa: 1, Australia: 1},
    this.elevations = const {Europe: 3, Asia: 3, NorthAmerica: 3, SouthAmerica: 3, Africa: 3, Australia: 3},
    this.colors,
  });

  final InteractiveMapData data;
  final Set<Type> deads;
  final Map<Type, double> scales;
  final Map<Type, double> elevations;
  final Map<Type, Color>? colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.surfaceContainerLow;

    return CustomPaint(
      painter: _Painter(
        data: data,
        deads: deads,
        scales: scales,
        elevations: elevations,
        colors: colors ?? {Europe: defaultColor, Asia: defaultColor, NorthAmerica: defaultColor, SouthAmerica: defaultColor, Africa: defaultColor, Australia: defaultColor},
        deadColor: theme.colorScheme.surface,
        outlineColor: theme.colorScheme.outline,
        shadowColor: theme.colorScheme.shadow,
        textStyle: theme.textTheme.titleLarge!.copyWith(
          fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.titleLarge!.fontSize!),
          fontWeight: MediaQuery.boldTextOf(context) ? FontWeight.bold : null,
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    required this.data,
    required this.deads,
    required this.scales,
    required this.elevations,
    required this.colors,
    required this.deadColor,
    required this.outlineColor,
    required this.shadowColor,
    required this.textStyle,
  });

  final InteractiveMapData data;
  final Set<Type> deads;
  final Map<Type, double> scales;
  final Map<Type, double> elevations;
  final Map<Type, Color> colors;
  final Color deadColor;
  final Color outlineColor;
  final Color shadowColor;
  final TextStyle textStyle;

  late Size _size;

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    data.transformCanvas(size, canvas);

    final inactiveRegions = data.regions.keys.where((e) => scales[e] == 1).toList();
    final activeRegions = data.regions.keys.where((e) => scales[e] != 1).toList()..sort((a, b) => scales[a]!.compareTo(scales[b]!));

    for (final region in inactiveRegions) {
      _paintShadow(canvas, region);
    }
    for (final region in activeRegions) {
      _withScale(canvas, region, () => _paintShadow(canvas, region));
    }

    for (final region in inactiveRegions) {
      _paintRegion(canvas, region);
    }
    for (final region in activeRegions) {
      _withScale(canvas, region, () => _paintRegion(canvas, region));
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final region in inactiveRegions) {
      _layoutText(textPainter, region);
      _paintText(canvas, textPainter, region);
    }
    for (final region in activeRegions) {
      _layoutText(textPainter, region);
      _withScale(canvas, region, () => _paintText(canvas, textPainter, region), scaleCenter: data.getRegionPathTextCenter(region, textPainter.height));
    }
    textPainter.dispose();
  }

  void _withScale(Canvas canvas, Type region, VoidCallback callback, {Offset? scaleCenter}) {
    final scale = scales[region]!;
    final center = scaleCenter ?? data.regions[region]!.bounds.center;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(center.dx / scale - center.dx, center.dy / scale - center.dy);
    callback();
    canvas.restore();
  }

  void _paintShadow(Canvas canvas, Type region) {
    if (deads.contains(region)) return;
    for (final path in data.regions[region]!.paths) {
      canvas.drawShadow(path, shadowColor, elevations[region]!, false);
    }
  }

  late final strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = outlineColor;
  void _paintRegion(Canvas canvas, Type region) {
    final fillPaint = Paint()..color = colors[region]!;
    for (final path in data.regions[region]!.paths) {
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  void _layoutText(TextPainter textPainter, Type region) {
    textPainter.text = TextSpan(text: data.getRegionName(region), style: textStyle);
    textPainter.layout();
  }

  void _paintText(Canvas canvas, TextPainter textPainter, Type region) =>
      textPainter.paint(canvas, data.getRegionPathTextCenter(region, textPainter.height).translate(-textPainter.width / 2, -textPainter.height / 2));

  @override
  bool shouldRepaint(_Painter oldDelegate) =>
      data != oldDelegate.data ||
      deads != oldDelegate.deads ||
      scales != oldDelegate.scales ||
      elevations != oldDelegate.elevations ||
      colors != oldDelegate.colors ||
      deadColor != oldDelegate.deadColor ||
      outlineColor != oldDelegate.outlineColor ||
      shadowColor != oldDelegate.shadowColor ||
      textStyle != oldDelegate.textStyle;

  @override
  bool? hitTest(Offset position) => data.hitTest(_size, position, deads);
}

class InteractiveMapData {
  const InteractiveMapData({required this.bounds, required this.regions});

  final Rect bounds;
  final Map<Type, ({Rect bounds, List<Path> paths})> regions;

  static const _regionsToPaths = {
    Europe: [5, 6, 7, 8, 9, 10, 12],
    Asia: [3, 20, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34],
    NorthAmerica: [0, 1, 2, 4, 13, 14, 15, 16, 17, 18, 19, 21],
    SouthAmerica: [22],
    Africa: [11, 36],
    Australia: [29, 35, 37, 38, 39],
  };
  static Future<InteractiveMapData> load() async {
    final pathsFile = await rootBundle.loadString('assets/map.paths');
    final paths = pathsFile.split('\n').map((e) => parseSvgPath(e)).toList();

    final regions = <Type, ({Rect bounds, List<Path> paths})>{};
    for (final region in [Europe, Asia, NorthAmerica, SouthAmerica, Africa, Australia]) {
      final regionPaths = _regionsToPaths[region]!.map((e) => paths[e]).toList();
      final regionBounds = regionPaths.map((e) => e.getBounds()).reduce((rect, e) => rect.expandToInclude(e));
      regions[region] = (bounds: regionBounds, paths: regionPaths);
    }

    final bounds = regions.values.map((e) => e.bounds).reduce((rect, e) => rect.expandToInclude(e));

    return InteractiveMapData(bounds: bounds, regions: regions);
  }

  Offset pathToLocal(Size size, Offset pathPosition) => pathPosition.translate(-bounds.left, -bounds.top).scale(size.width / bounds.width, size.height / bounds.height);
  Offset localToPath(Size size, Offset localPosition) => localPosition.scale(bounds.width / size.width, bounds.height / size.height).translate(bounds.left, bounds.top);
  void transformCanvas(Size size, Canvas canvas) => canvas
    ..scale(size.width / bounds.width, size.height / bounds.height)
    ..translate(-bounds.left, -bounds.top);

  bool hitTest(Size size, Offset localPosition, Set<Type> deadRegions) {
    final pathPosition = localToPath(size, localPosition);
    final entries = regions.entries.where((region) => region.value.paths.any((e) => e.contains(pathPosition)));
    return entries.isNotEmpty && !deadRegions.contains(entries.first.key);
  }

  Type getRegionAt(Size size, Offset localPosition) {
    final pathPosition = localToPath(size, localPosition);
    return regions.entries.firstWhere((entry) => entry.value.paths.any((e) => e.contains(pathPosition))).key;
  }

  static const _regionNames = {
    Europe: 'Europa',
    Asia: 'Asien',
    NorthAmerica: 'Nordamerika',
    SouthAmerica: 'Südamerika',
    Africa: 'Afrika',
    Australia: 'Australien',
  };
  String getRegionName(Type region) => _regionNames[region]!;
  static const _regionsCenters = {
    Europe: Offset(1000, 580),
    Asia: Offset(1400, 600),
    NorthAmerica: Offset(300, 620),
    SouthAmerica: Offset(530, 1000),
    Africa: Offset(1020, 850),
    Australia: Offset(1760, 1080),
  };
  Offset getRegionCenter(Size size, Type region) => pathToLocal(size, _regionsCenters[region]!);
  static const _regionsDrawPopupUpwards = {
    Europe: false,
    Asia: false,
    NorthAmerica: false,
    SouthAmerica: true,
    Africa: false,
    Australia: true,
  };
  bool getRegionDrawPopupUpwards(Type region) => _regionsDrawPopupUpwards[region]!;
  Offset getRegionPathTextCenter(Type region, double textHeight) => _regionsCenters[region]!.translate(0, _regionsDrawPopupUpwards[region]! ? textHeight / 2 : -textHeight / 2);
}
