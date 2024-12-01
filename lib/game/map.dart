import 'package:flutter/material.dart';
import 'package:sowi/logic/region.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key, required this.regions});

  final List<Region> regions;

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  late MapShapeSource _mapSource;

  @override
  void initState() {
    super.initState();

    _mapSource = MapShapeSource.asset(
      'assets/continents.json',
      shapeDataField: 'CONTINENT',
      dataCount: widget.regions.length,
      primaryValueMapper: (index) => widget.regions[index].name,
      shapeColorValueMapper: (index) => _computeRegionColor(widget.regions[index]),
    );
  }

  Color _computeRegionColor(Region region) {
    final missingResourcesPercentage = (region.food / region.maximumFood + region.water / region.maximumWater) / 2;
    return Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SfMaps(
      layers: [
        MapShapeLayer(
          source: _mapSource,
          showDataLabels: true,
          dataLabelSettings: MapDataLabelSettings(
            textStyle: theme.textTheme.labelMedium,
          ),
          shapeTooltipBuilder: (context, index) {
            final region = widget.regions[index];
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(region.name, style: theme.textTheme.titleMedium),
                  Text('Population: ${region.population}'),
                  Text('Essen: ${region.food}/${region.requiredFood}/${region.maximumFood}', style: theme.textTheme.bodyMedium),
                  Text('Wasser: ${region.water}/${region.requiredWater}/${region.maximumWater}', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          },
          tooltipSettings: MapTooltipSettings(
            color: theme.colorScheme.surfaceContainer,
            strokeColor: theme.colorScheme.surfaceContainer,
          ),
          //onSelectionChanged: (index) => Navigator.of(context).pushReplacement(
          //  MaterialPageRoute(
          //    builder: (context) => InteractPage(regions[index]),
          //  ),
          //),
        ),
      ],
    );
  }
}
