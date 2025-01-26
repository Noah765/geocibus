import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _trackHeight = 8.0;
const _activeTrackHeight = 10.0;
const _thumbPadding = 4.0;

class BidirectionalSlider extends StatefulWidget {
  const BidirectionalSlider({
    super.key,
    required this.value,
    this.secondaryTrackValueLeft,
    this.secondaryTrackValueRight,
    required this.onChanged,
    this.snapValues = const [],
    required this.leftMax,
    required this.rightMax,
  });

  final double value;
  final double? secondaryTrackValueLeft;
  final double? secondaryTrackValueRight;
  final ValueChanged<double> onChanged;
  final List<double> snapValues;
  final double leftMax;
  final double rightMax;

  @override
  State<BidirectionalSlider> createState() => _BidirectionalSliderState();
}

class _BidirectionalSliderState extends State<BidirectionalSlider> {
  late Size _thumbSize;
  var _thumbHover = false;
  var _active = false;
  var _dragStarting = false;

  @override
  void didChangeDependencies() {
    _updateThumbSize();
    super.didChangeDependencies();
  }

  void _updateThumbSize() {
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final thumbTextStyle = defaultTextStyle.copyWith(fontSize: MediaQuery.textScalerOf(context).scale(defaultTextStyle.fontSize!));
    final textPainter = TextPainter(text: TextSpan(text: max(widget.leftMax, widget.rightMax).toString(), style: thumbTextStyle), textDirection: TextDirection.ltr);
    textPainter.layout();
    _thumbSize = Size(textPainter.width + 2 * _thumbPadding, textPainter.height + 2 * _thumbPadding);
    textPainter.dispose();
  }

  void _handleUpdate(double width, double dx, double snapDifference) {
    final snapValue = widget.snapValues
        .where((e) => e <= 0 ? -e <= widget.leftMax : e <= widget.rightMax)
        .map((e) => (value: e, difference: (dx - width / 2 - (e == 0 && widget.leftMax == 0 ? 0 : e / (e <= 0 ? widget.leftMax : widget.rightMax)) * (width / 2 - _thumbSize.width / 2)).abs()))
        .where((e) => e.difference <= snapDifference)
        .sortedBy<num>((e) => e.difference)
        .firstOrNull
        ?.value;
    final newValue = snapValue ?? clampDouble((dx - width / 2) * (dx < width / 2 ? widget.leftMax : widget.rightMax) / (width / 2 - _thumbSize.width / 2), -widget.leftMax, widget.rightMax);
    if (widget.value == newValue) return;
    widget.onChanged(newValue);
  }

  void _onDragStart(DragStartDetails details, double width) {
    setState(() {
      _active = true;
      _dragStarting = true;
    });
    _handleUpdate(width, details.localPosition.dx, 40);
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    setState(() => _dragStarting = false);
    _handleUpdate(width, details.localPosition.dx, 10);
  }

  void _onDragEnd(DragEndDetails details) => setState(() => _active = false);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeColor = widget.value <= 0 ? colors.onPrimary : colors.onSecondary;
    final thumbColor = switch ((_active, _thumbHover)) {
      (true, _) => Color.alphaBlend(colors.onSurface.withOpacity(0.1), activeColor),
      (false, true) => Color.alphaBlend(colors.onSurface.withOpacity(0.08), activeColor),
      (false, false) => activeColor,
    };

    return SizedBox(
      height: _thumbSize.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final BoxConstraints(maxWidth: width, maxHeight: height) = constraints;
          return GestureDetector(
            onHorizontalDragStart: (details) => _onDragStart(details, width),
            onHorizontalDragUpdate: (details) => _onDragUpdate(details, width),
            onHorizontalDragEnd: _onDragEnd,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TweenAnimationBuilder(
                tween: Tween(begin: widget.value, end: widget.value),
                duration: _dragStarting ? const Duration(milliseconds: 75) : Duration.zero,
                curve: Curves.fastOutSlowIn,
                builder: (context, value, child) => Stack(
                  children: [
                    Positioned(
                      top: height / 2 - _trackHeight / 2,
                      width: width / 2,
                      height: _trackHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.leftMax == 0 ? colors.onSurface.withOpacity(0.12) : colors.primary,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(_trackHeight / 2)),
                        ),
                      ),
                    ),
                    if (widget.secondaryTrackValueLeft != null && widget.secondaryTrackValueLeft! > 0 && widget.leftMax != 0)
                      Positioned(
                        top: height / 2 - _trackHeight / 2,
                        right: width / 2,
                        width: widget.secondaryTrackValueLeft! / widget.leftMax * width / 2,
                        height: _trackHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.onPrimary.withOpacity(0.1),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(_trackHeight / 2)),
                          ),
                        ),
                      ),
                    Positioned(
                      left: width / 2,
                      top: height / 2 - _trackHeight / 2,
                      width: width / 2,
                      height: _trackHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.rightMax == 0 ? colors.onSurface.withOpacity(0.12) : colors.secondary,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(_trackHeight / 2)),
                        ),
                      ),
                    ),
                    if (widget.secondaryTrackValueRight != null && widget.secondaryTrackValueRight! > 0 && widget.rightMax != 0)
                      Positioned(
                        left: width / 2,
                        top: height / 2 - _trackHeight / 2,
                        width: widget.secondaryTrackValueRight! / widget.rightMax * width / 2,
                        height: _trackHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.onSurface.withOpacity(0.1),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(_trackHeight / 2)),
                          ),
                        ),
                      ),
                    Positioned(
                      left: value <= 0 ? null : width / 2 - _activeTrackHeight / 2,
                      top: height / 2 - _activeTrackHeight / 2,
                      right: value <= 0 ? width / 2 - _activeTrackHeight / 2 : null,
                      width: (value <= 0 && widget.leftMax == 0 ? 0 : value / (value <= 0 ? -widget.leftMax : widget.rightMax) * width / 2) + _activeTrackHeight / 2,
                      height: _activeTrackHeight,
                      child: DecoratedBox(decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(_activeTrackHeight / 2))),
                    ),
                    Positioned(
                      left: width / 2 + (value <= 0 && widget.leftMax == 0 ? 0 : value / (value <= 0 ? widget.leftMax : widget.rightMax) * (width - _thumbSize.width) / 2) - _thumbSize.width / 2,
                      top: height / 2 - _thumbSize.height / 2,
                      width: _thumbSize.width,
                      height: _thumbSize.height,
                      child: MouseRegion(
                        onEnter: (event) => setState(() => _thumbHover = true),
                        onExit: (event) => setState(() => _thumbHover = false),
                        child: TweenAnimationBuilder(
                          tween: ColorTween(begin: thumbColor, end: thumbColor),
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.fastOutSlowIn,
                          builder: (context, color, child) => Material(
                            elevation: _thumbHover && !_active ? 3 : 1,
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            animationDuration: kRadialReactionDuration,
                            child: Center(child: Text(widget.value.round().abs().toString())),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
