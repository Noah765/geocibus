import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:geocibus/game/interact/page.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:geocibus/widgets/resource_indicator.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late final _Map _map;
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
  }

  (Offset, Direction) _getPopupData(Size size, Offset position) {
    final region = _map.getRegionAt(size, position);
    return (_map.getRegionCenter(size, region), region.runtimeType == Australia ? Direction.up : Direction.down);
  }

  Color _computeRegionColor(Region region) {
    if (region.population == 0) return Colors.black;
    final missingResourcesPercentage = min(min(region.food / region.maximumFood, region.water / region.maximumWater), 1.0);
    return Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!; // TODO Update colors, blue for too much food
  }

  @override
  Widget build(BuildContext context) {
    if (!_finishedInitializing) return const SizedBox(); // TODO Maybe show loading indicator? Should be almost instant though

    final game = context.watch<Game>();
    final theme = Theme.of(context);

    return Center(
      child: AspectRatio(
        aspectRatio: _map.bounds.width / _map.bounds.height,
        child: LayoutBuilder(
          builder: (context, constraints) => Popup(
            getPopupData: (position) => _getPopupData(constraints.biggest, position),
            popupBuilder: (context, position) {
              final region = _map.getRegionAt(constraints.biggest, position);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(region.name, style: theme.textTheme.headlineSmall),
                  Text('${region.population} Mio. Einwohner'),
                  const Gap(8),
                  ResourceIndicator(region),
                  const Gap(24),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => InteractPage(game: game, region: region))),
                    child: const Text('Kontaktieren'),
                  ),
                ],
              );
            },
            child: CustomPaint(
              painter: _MapPainter(
                size: constraints.biggest,
                map: _map,
                colors: _map.regions.map((key, value) => MapEntry(key, _computeRegionColor(key))),
                outlineColor: theme.colorScheme.onSurface,
                textStyle: theme.textTheme.titleMedium!.copyWith(
                  fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.titleMedium!.fontSize!),
                  fontWeight: MediaQuery.boldTextOf(context) ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Map {
  const _Map({required this.bounds, required this.regions});

  final Rect bounds;
  final Map<Region, List<Path>> regions;

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

    final bounds = paths.map((e) => e.getBounds()).reduce((rect, e) => rect.expandToInclude(e));
    final regions = {
      for (final region in game.regions) region: [for (final i in _regionsToPaths[region.runtimeType]!) paths[i]],
    };

    return _Map(bounds: bounds, regions: regions);
  }

  Offset pathToLocal(Size size, Offset position) => position.translate(-bounds.left, -bounds.top).scale(size.width / bounds.width, size.height / bounds.height);
  Offset localToPath(Size size, Offset position) => position.scale(bounds.width / size.width, bounds.height / size.height).translate(bounds.left, bounds.top);
  void transformCanvas(Size size, Canvas canvas) => canvas
    ..scale(size.width / bounds.width, size.height / bounds.height)
    ..translate(-bounds.left, -bounds.top);

  bool hitTest(Size size, Offset offset) {
    final pathPosition = localToPath(size, offset);
    final regionEntries = regions.entries.where((entry) => entry.value.any((e) => e.contains(pathPosition)));
    return regionEntries.isNotEmpty && regionEntries.first.key.population > 0;
  }

  Region getRegionAt(Size size, Offset position) {
    final pathPosition = localToPath(size, position);
    return regions.entries.firstWhere((entry) => entry.value.any((e) => e.contains(pathPosition))).key;
  }

  static const _regionCenters = {
    Europe: Offset(1000, 580),
    Asia: Offset(1400, 600),
    NorthAmerica: Offset(300, 620),
    SouthAmerica: Offset(520, 1020),
    Africa: Offset(1020, 850),
    Australia: Offset(1750, 1110),
  };
  Offset getRegionCenter(Size size, Region region) => pathToLocal(size, _regionCenters[region.runtimeType]!);
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.size,
    required this.map,
    required this.colors,
    required this.outlineColor,
    required this.textStyle,
  });

  final Size size;
  final _Map map;
  final Map<Region, Color> colors;
  final Color outlineColor;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    map.transformCanvas(size, canvas);

    for (final MapEntry(key: region, value: paths) in map.regions.entries) {
      final fillPaint = Paint()..color = colors[region]!;
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = outlineColor;

      for (final path in paths) {
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      }
    }

    canvas.restore();

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final MapEntry(key: region, value: _) in map.regions.entries) {
      textPainter.text = TextSpan(text: region.name, style: textStyle);
      textPainter.layout();
      final position = map.getRegionCenter(size, region).translate(-textPainter.width / 2, -textPainter.height);
      textPainter.paint(canvas, position);
    }
    textPainter.dispose();
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      size != oldDelegate.size || map != oldDelegate.map || colors != oldDelegate.colors || outlineColor != oldDelegate.outlineColor || textStyle != oldDelegate.textStyle;

  @override
  bool? hitTest(Offset position) => map.hitTest(size, position);
}
