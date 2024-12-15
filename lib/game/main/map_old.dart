import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sowi/game/dialog/page.dart';
import 'package:sowi/models/game.dart';
import 'package:sowi/models/region.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  late MapShapeSource _mapSource;

  @override
  void initState() {
    super.initState();

    final game = context.read<Game>();
    _mapSource = MapShapeSource.asset(
      'assets/continents.json',
      shapeDataField: 'CONTINENT',
      dataCount: game.regions.length,
      primaryValueMapper: (index) => game.regions[index].name,
      shapeColorValueMapper: (index) => _computeRegionColor(game.regions[index]),
    );
  }

  Color _computeRegionColor(Region region) {
    final missingResourcesPercentage = (region.food / region.maximumFood + region.water / region.maximumWater) / 2;
    return Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!;
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<Game>();
    final theme = Theme.of(context);

    return SfMaps(
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
                  Text('Population: ${region.population}'),
                  Text('Wasser: ${region.water}/${region.requiredWater}/${region.maximumWater}', style: theme.textTheme.bodyMedium),
                  Text('Essen: ${region.food}/${region.requiredFood}/${region.maximumFood}', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          },
          tooltipSettings: MapTooltipSettings(
            color: theme.colorScheme.surfaceContainer,
            strokeColor: theme.colorScheme.surfaceContainer,
          ),
          onSelectionChanged: (index) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DialogPage(game: game, region: game.regions[index]))),
        ),
      ],
    );
  }
}
