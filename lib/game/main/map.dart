import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/game/interact/page.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:geocibus/widgets/resource_indicator.dart';
import 'package:provider/provider.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late final _Map _map;
  late final PopupController<Region> _popupController;
  var _finishedInitializing = false;

  @override
  void initState() {
    super.initState();

    _Map.load(context.read<Game>()).then(
      (value) => setState(() {
        _map = value;
        _finishedInitializing = true;
      }),
    );

    _popupController = PopupController();
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_finishedInitializing) return const SizedBox();

    final game = context.watch<Game>();
    final theme = Theme.of(context);

    return Center(
      child: AspectRatio(
        aspectRatio: _map.bounds.width / _map.bounds.height,
        child: LayoutBuilder(
          builder: (context, constraints) => Popup(
            controller: _popupController,
            getDataAt: (localPosition) => _map.getRegionAt(constraints.biggest, localPosition),
            getPosition: (region) => _map.getRegionCenter(constraints.biggest, region),
            getDirection: (region) => region.drawPopupUpwards ? Direction.up : Direction.down,
            builder: (context, region) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(region.name, style: theme.textTheme.headlineSmall),
                Text('${region.population} Mio. Einwohner'),
                const Gap(16),
                ResourceIndicator(region),
                const Gap(32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => InteractPage(game: game, region: region))),
                  child: const Text('Kontaktieren'),
                ),
              ],
            ),
            child: _AnimatedMap(map: _map, size: constraints.biggest, popupController: _popupController),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMap extends StatefulWidget {
  const _AnimatedMap({required this.map, required this.size, required this.popupController});

  final _Map map;
  final Size size;
  final PopupController<Region> popupController;

  @override
  State<_AnimatedMap> createState() => _AnimatedMapState();
}

class _AnimatedMapState extends State<_AnimatedMap> with TickerProviderStateMixin {
  late final Map<Region, AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.map.regions.map((key, value) => MapEntry(key, AnimationController(duration: const Duration(milliseconds: 100), vsync: this)..addListener(() => setState(() {}))));
    widget.popupController.addListener(_handlePopupControllerChanged);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    widget.popupController.removeListener(_handlePopupControllerChanged);
    super.dispose();
  }

  Region? _previousHoveredRegion;
  Region? _previousPressedRegion;
  void _handlePopupControllerChanged() {
    final hovered = widget.popupController.hovered;
    final pressed = widget.popupController.pressed;

    if (hovered != _previousHoveredRegion) {
      if (hovered != null && hovered != pressed) _controllers[hovered]!.animateTo(1 / 3, curve: Curves.fastOutSlowIn);
      if (_previousHoveredRegion != null && _previousHoveredRegion != pressed) _controllers[_previousHoveredRegion]!.animateTo(0, curve: Curves.fastOutSlowIn);
    }
    if (pressed != _previousPressedRegion) {
      if (pressed != null) _controllers[pressed]!.animateTo(1, curve: Curves.fastOutSlowIn);
      if (_previousPressedRegion != null) _controllers[_previousPressedRegion]!.animateTo(_previousPressedRegion == hovered ? 1 / 3 : 0, curve: Curves.fastOutSlowIn);
    }

    _previousHoveredRegion = hovered;
    _previousPressedRegion = pressed;
  }

  double _getRegionScale(Region region) => 1 + _controllers[region]!.value * 0.03;

  double _getRegionElevation(Region region) => region.population == 0 ? 0 : 3 + _controllers[region]!.value * 3;

  Color _getRegionColor(Region region) {
    final surface = Theme.of(context).colorScheme.surface;
    if (region.population == 0) return surface;
    final missingResourcesPercentage = min(min(region.food / region.maximumFood, region.water / region.maximumWater), 1.0);
    final color = Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!;
    return Color.lerp(color, surface, 0.2 * (1 - _controllers[region]!.value))!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      painter: _Painter(
        size: widget.size,
        map: widget.map,
        scales: widget.map.regions.map((key, value) => MapEntry(key, _getRegionScale(key))),
        elevations: widget.map.regions.map((key, value) => MapEntry(key, _getRegionElevation(key))),
        colors: widget.map.regions.map((key, value) => MapEntry(key, _getRegionColor(key))),
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
    required this.size,
    required this.map,
    required this.scales,
    required this.elevations,
    required this.colors,
    required this.outlineColor,
    required this.shadowColor,
    required this.textStyle,
  });

  final Size size;
  final _Map map;
  final Map<Region, double> scales;
  final Map<Region, double> elevations;
  final Map<Region, Color> colors;
  final Color outlineColor;
  final Color shadowColor;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    map.transformCanvas(size, canvas);

    final inactiveRegions = map.regions.keys.where((e) => scales[e] == 1).toList();
    final activeRegions = map.regions.keys.where((e) => scales[e] != 1).toList()..sort((a, b) => scales[a]!.compareTo(scales[b]!));

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
      _withScale(canvas, region, () => _paintText(canvas, textPainter, region), scaleCenter: map.getRegionPathTextCenter(region, textPainter.height));
    }
    textPainter.dispose();
  }

  void _withScale(Canvas canvas, Region region, VoidCallback callback, {Offset? scaleCenter}) {
    final scale = scales[region]!;
    final center = scaleCenter ?? map.regions[region]!.bounds.center;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(center.dx / scale - center.dx, center.dy / scale - center.dy);
    callback();
    canvas.restore();
  }

  void _paintShadow(Canvas canvas, Region region) {
    for (final path in map.regions[region]!.paths) {
      canvas.drawShadow(path, shadowColor, elevations[region]!, false);
    }
  }

  late final strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = outlineColor;
  void _paintRegion(Canvas canvas, Region region) {
    final fillPaint = Paint()..color = colors[region]!;
    for (final path in map.regions[region]!.paths) {
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  void _layoutText(TextPainter textPainter, Region region) {
    textPainter.text = TextSpan(text: region.name, style: textStyle);
    textPainter.layout();
  }

  void _paintText(Canvas canvas, TextPainter textPainter, Region region) =>
      textPainter.paint(canvas, map.getRegionPathTextCenter(region, textPainter.height).translate(-textPainter.width / 2, -textPainter.height / 2));

  @override
  bool shouldRepaint(_Painter oldDelegate) =>
      map != oldDelegate.map || scales != oldDelegate.scales || colors != oldDelegate.colors || outlineColor != oldDelegate.outlineColor || textStyle != oldDelegate.textStyle;

  @override
  bool? hitTest(Offset position) => map.hitTest(size, position);
}

class _Map {
  const _Map({required this.bounds, required this.regions});

  final Rect bounds;
  final Map<Region, ({Rect bounds, List<Path> paths})> regions;

  static const _regionsToPaths = {
    Europe: [5, 6, 7, 8, 9, 10, 12],
    Asia: [3, 20, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34],
    NorthAmerica: [0, 1, 2, 4, 13, 14, 15, 16, 17, 18, 19, 21],
    SouthAmerica: [22],
    Africa: [11, 36],
    Australia: [29, 35, 37, 38, 39],
  };
  static Future<_Map> load(Game game) async {
    final pathsFile = await rootBundle.loadString('assets/map.paths');
    final paths = pathsFile.split('\n').map((e) => parseSvgPath(e)).toList();

    final regions = <Region, ({Rect bounds, List<Path> paths})>{};
    for (final region in game.regions) {
      final regionPaths = _regionsToPaths[region.runtimeType]!.map((e) => paths[e]).toList();
      final regionBounds = regionPaths.map((e) => e.getBounds()).reduce((rect, e) => rect.expandToInclude(e));
      regions[region] = (bounds: regionBounds, paths: regionPaths);
    }

    final bounds = regions.values.map((e) => e.bounds).reduce((rect, e) => rect.expandToInclude(e));

    return _Map(bounds: bounds, regions: regions);
  }

  Offset pathToLocal(Size size, Offset pathPosition) => pathPosition.translate(-bounds.left, -bounds.top).scale(size.width / bounds.width, size.height / bounds.height);
  Offset localToPath(Size size, Offset localPosition) => localPosition.scale(bounds.width / size.width, bounds.height / size.height).translate(bounds.left, bounds.top);
  void transformCanvas(Size size, Canvas canvas) => canvas
    ..scale(size.width / bounds.width, size.height / bounds.height)
    ..translate(-bounds.left, -bounds.top);

  bool hitTest(Size size, Offset localPosition) {
    final pathPosition = localToPath(size, localPosition);
    final regionEntries = regions.entries.where((entry) => entry.value.paths.any((e) => e.contains(pathPosition)));
    return regionEntries.isNotEmpty && regionEntries.first.key.population > 0;
  }

  Region getRegionAt(Size size, Offset localPosition) {
    final pathPosition = localToPath(size, localPosition);
    return regions.entries.firstWhere((entry) => entry.value.paths.any((e) => e.contains(pathPosition))).key;
  }

  static const _regionCenters = {
    Europe: Offset(1000, 580),
    Asia: Offset(1400, 600),
    NorthAmerica: Offset(300, 620),
    SouthAmerica: Offset(530, 1000),
    Africa: Offset(1020, 850),
    Australia: Offset(1760, 1080),
  };
  Offset getRegionCenter(Size size, Region region) => pathToLocal(size, _regionCenters[region.runtimeType]!);
  Offset getRegionPathTextCenter(Region region, double textHeight) => _regionCenters[region.runtimeType]!.translate(0, region.drawPopupUpwards ? textHeight / 2 : -textHeight / 2);
}
