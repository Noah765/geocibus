import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sowi/models/region.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

typedef _Regions = Map<Region, ({List<Path> paths, Color color})>;

class _GameMapState extends State<GameMap> {
  _Regions? _regions;
  Rect? _bounds;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map.paths').then(_initializeRegions);
  }

  void _initializeRegions(String pathsFile) {
    final paths = (pathsFile.split('\n')..removeLast()).map((e) => parseSvgPath(e));

    _regions = {Europe(): (paths: paths.toList(), color: Colors.white)};
    _bounds = paths.map((e) => e.getBounds()).reduce((rect, e) => rect.expandToInclude(e));

    setState(() {});
  }

  Color _computeRegionColor(Region region) {
    final missingResourcesPercentage = (region.food / region.maximumFood + region.water / region.maximumWater) / 2;
    return Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!;
  }

  @override
  Widget build(BuildContext context) {
    if (_regions == null) return const SizedBox();

    return CustomPaint(painter: _Painter(regions: _regions!, bounds: _bounds!), size: Size.infinite);
  }
}

class _Painter extends CustomPainter {
  const _Painter({required this.regions, required this.bounds});

  final _Regions regions;
  final Rect bounds;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / bounds.width, -(size.height / bounds.height));
    canvas.translate(-bounds.left, -bounds.bottom);

    for (final region in regions.values) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = region.color;

      for (final path in region.paths) {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // TODO
}
