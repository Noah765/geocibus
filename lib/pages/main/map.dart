import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/pages/interact/page.dart';
import 'package:geocibus/widgets/button.dart';
import 'package:geocibus/widgets/interactive_map.dart';
import 'package:geocibus/widgets/popup.dart';
import 'package:geocibus/widgets/resource_indicator.dart';
import 'package:provider/provider.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  InteractiveMapData? _data;
  late final PopupController<Type> _popupController;

  @override
  void initState() {
    super.initState();
    InteractiveMapData.load().then((value) => setState(() => _data = value));
    _popupController = PopupController();
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const SizedBox();

    final game = context.watch<Game>();
    final theme = Theme.of(context);

    return Center(
      child: AspectRatio(
        aspectRatio: _data!.bounds.width / _data!.bounds.height,
        child: LayoutBuilder(
          builder: (context, constraints) => Popup(
            controller: _popupController,
            getDataAt: (localPosition) => _data!.getRegionAt(constraints.biggest, localPosition),
            getPosition: (region) => _data!.getRegionCenter(constraints.biggest, region),
            getDirection: (region) => _data!.getRegionDrawPopupUpwards(region) ? Direction.up : Direction.down,
            builder: (context, type) {
              final region = game.regions.firstWhere((e) => e.runtimeType == type);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(region.name, style: theme.textTheme.headlineSmall),
                  Text('${region.population} Mio. Einwohner'),
                  const Gap(16),
                  ResourceIndicator(region),
                  const Gap(32),
                  Button(
                    text: 'Kontaktieren',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => InteractPage(game: game, region: region))),
                  ),
                ],
              );
            },
            child: _AnimatedMap(data: _data!, size: constraints.biggest, popupController: _popupController),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMap extends StatefulWidget {
  const _AnimatedMap({required this.data, required this.size, required this.popupController});

  final InteractiveMapData data;
  final Size size;
  final PopupController<Type> popupController;

  @override
  State<_AnimatedMap> createState() => _AnimatedMapState();
}

class _AnimatedMapState extends State<_AnimatedMap> with TickerProviderStateMixin {
  late final Map<Type, AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.data.regions.map((key, value) => MapEntry(key, AnimationController(duration: const Duration(milliseconds: 100), vsync: this)..addListener(() => setState(() {}))));
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

  Type? _previousHoveredRegion;
  Type? _previousPressedRegion;
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

  double _getRegionScale(Type region) => 1 + _controllers[region]!.value * 0.03;
  double _getRegionElevation(Type region) => 3 + _controllers[region]!.value * 3;
  Color _getRegionColor(Type type) {
    final region = context.read<Game>().regions.firstWhere((e) => e.runtimeType == type);
    if (region.population == 0) return Colors.transparent;
    final missingResourcesPercentage = min(min(region.food / region.maximumFood, region.water / region.maximumWater), 1.0);
    final color = Color.lerp(Colors.red, Colors.green, missingResourcesPercentage)!;
    return Color.lerp(color, Theme.of(context).colorScheme.surface, 0.2 * (1 - _controllers[type]!.value))!;
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveMap(
      data: widget.data,
      deads: context.read<Game>().regions.where((e) => e.population == 0).map((e) => e.runtimeType).toSet(),
      scales: widget.data.regions.map((key, value) => MapEntry(key, _getRegionScale(key))),
      elevations: widget.data.regions.map((key, value) => MapEntry(key, _getRegionElevation(key))),
      colors: widget.data.regions.map((key, value) => MapEntry(key, _getRegionColor(key))),
    );
  }
}
