import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocibus/models/region.dart';
import 'package:geocibus/widgets/popup.dart';

class PopulationDiagram extends StatelessWidget {
  const PopulationDiagram({super.key, required this.yearlyPopulation});

  final List<Map<Region, int>> yearlyPopulation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Legend(regions: yearlyPopulation[0].keys.toList()),
        const Gap(8),
        Expanded(child: _Chart(yearlyPopulation: yearlyPopulation)),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.yearlyPopulation});

  final List<Map<Region, int>> yearlyPopulation;

  int _getPopulationStepSize(int maxPopulation, double height) {
    final steps = (height / 50).ceil();
    final populationPerStep = maxPopulation / steps;
    final exponent = log(populationPerStep) ~/ log(10) - 1;
    return switch (populationPerStep / pow(10, exponent)) {
      > 75 => pow(10, exponent + 2) as int,
      > 50 => 75 * pow(10, exponent) as int,
      > 25 => 50 * pow(10, exponent) as int,
      > 20 => 25 * pow(10, exponent) as int,
      > 10 => 20 * pow(10, exponent) as int,
      double() => throw Error(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        final maxPopulation = yearlyPopulation.map((e) => e.values.sum).max;
        final populationStepSize = _getPopulationStepSize(maxPopulation, height);
        final populationSteps = (maxPopulation / populationStepSize).ceil();
        final maxDisplayedPopulation = populationSteps * populationStepSize;

        final ThemeData(colorScheme: colors, :textTheme) = Theme.of(context);
        final labellingStyle = textTheme.labelMedium!.copyWith(color: colors.surfaceContainerLow);
        final axisLabellingStyle = textTheme.labelLarge!.copyWith(color: colors.surfaceContainerLow);

        const axisWidth = 2.0;
        const labellingPadding = 4.0;
        final labellingHeight = (MediaQuery.textScalerOf(context).scale(labellingStyle.fontSize!) * labellingStyle.height!).roundToDouble();
        final axisLabellingHeight = (MediaQuery.textScalerOf(context).scale(axisLabellingStyle.fontSize!) * axisLabellingStyle.height!).roundToDouble();
        final topOffset = labellingHeight / 2;
        final maxBarHeight = height - axisLabellingHeight - labellingHeight - labellingPadding - axisWidth - topOffset;

        return Row(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: axisLabellingHeight + labellingHeight / 2 + labellingPadding + axisWidth),
              child: Row(
                children: [
                  RotatedBox(quarterTurns: 3, child: Text('Bevölkerung in Mio.', style: axisLabellingStyle)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [for (var i = populationSteps; i >= 0; i--) Text((i * populationStepSize).toString(), style: labellingStyle)],
                  ),
                  const Gap(labellingPadding),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: colors.surfaceContainerLow, width: axisWidth),
                          left: BorderSide(color: colors.surfaceContainerLow, width: axisWidth),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(axisWidth, topOffset, 0, axisWidth),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                for (var i = 0; i < populationSteps; i++) ...[
                                  Container(height: 1, color: Colors.grey.shade600),
                                  const Spacer(),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                for (final (i, year) in yearlyPopulation.indexed) ...[
                                  Expanded(
                                    flex: 4,
                                    child: TweenAnimationBuilder(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 1500),
                                      curve: _Chained([
                                        Curves.fastOutSlowIn,
                                        Interval(i / (yearlyPopulation.length - 1) * 2 / 3, 1 / 3 + i / (yearlyPopulation.length - 1) * 2 / 3, curve: Curves.fastOutSlowIn),
                                      ]),
                                      builder: (context, value, child) => _Bar(
                                        regions:
                                            year.entries.map((e) => (region: e.key, population: e.value, height: e.value / maxDisplayedPopulation * maxBarHeight * value)).toList().reversed.toList(),
                                      ),
                                    ),
                                  ),
                                  if (year != yearlyPopulation.last) const Spacer(flex: 2),
                                ],
                                const Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(labellingPadding),
                  Row(children: [for (var i = 0; i < yearlyPopulation.length; i++) Expanded(child: Text(i.toString(), style: labellingStyle, textAlign: TextAlign.center))]),
                  Text('Jahr', style: axisLabellingStyle),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Chained extends Curve {
  const _Chained(this.curves);

  final List<Curve> curves;

  @override
  double transformInternal(double t) => curves.fold(t, (previousValue, curve) => curve.transform(previousValue));
}

class _Bar extends StatefulWidget {
  const _Bar({required this.regions});

  final List<({Region region, int population, double height})> regions;

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> {
  late final PopupController<Region> _popupController;

  @override
  void initState() {
    super.initState();
    _popupController = PopupController();
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  Region _getDataAt(double paddingTop, double dy) {
    var y = paddingTop;
    for (final e in widget.regions) {
      y += e.height;
      if (y >= dy) return e.region;
    }
    throw Error();
  }

  Offset _getPosition(double width, double paddingTop, Region region) {
    var y = paddingTop;
    for (final e in widget.regions) {
      y += e.height;
      if (e.region == region) return Offset(width, y - e.height / 2);
    }
    throw Error();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final paddingTop = constraints.maxHeight - widget.regions.map((e) => e.height).sum;
        return Popup(
          controller: _popupController,
          clickable: false,
          getDataAt: (localPosition) => _getDataAt(paddingTop, localPosition.dy),
          getPosition: (region) => _getPosition(constraints.maxWidth, paddingTop, region),
          direction: Direction.right,
          builder: (context, region) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(region.name, style: Theme.of(context).textTheme.headlineSmall),
              Text('${widget.regions.firstWhere((e) => e.region == region).population} Mio. Einwohner'),
            ],
          ),
          child: ListenableBuilder(
            listenable: _popupController,
            builder: (context, child) => Stack(
              children: [
                for (final (i, e) in widget.regions.indexed.whereNot((e) => e.$2.region == (_popupController.pressed ?? _popupController.hovered)))
                  Positioned(
                    key: ObjectKey(e.region),
                    top: paddingTop + widget.regions.take(i).map((e) => e.height).sum,
                    width: constraints.maxWidth,
                    height: e.height,
                    child: _BarSegment(active: false, color: e.region.diagramColor),
                  ),
                if (_popupController.pressed != null || _popupController.hovered != null)
                  Positioned(
                    key: ObjectKey(_popupController.pressed ?? _popupController.hovered),
                    top: paddingTop + widget.regions.take(widget.regions.indexWhere((e) => e.region == (_popupController.pressed ?? _popupController.hovered))).map((e) => e.height).sum,
                    width: constraints.maxWidth,
                    height: widget.regions.firstWhere((e) => e.region == (_popupController.pressed ?? _popupController.hovered)).height,
                    child: _BarSegment(active: true, color: (_popupController.pressed ?? _popupController.hovered!).diagramColor),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.03 : 1,
      duration: kThemeChangeDuration,
      curve: Curves.fastOutSlowIn,
      child: Material(
        elevation: active ? 3 : 1,
        color: color,
        shape: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          style: active ? BorderStyle.solid : BorderStyle.none,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.regions});

  final List<Region> regions;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.surfaceContainerLow);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final region in regions) ...[
          SizedBox.square(dimension: MediaQuery.textScalerOf(context).scale(textStyle.fontSize!), child: ColoredBox(color: region.diagramColor)),
          const Gap(6),
          Text(region.name, style: textStyle),
          if (region != regions.last) const Gap(24),
        ],
      ],
    );
  }
}
