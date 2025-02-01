import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _trackHeight = 8.0;
const _activeTrackHeight = 10.0;
const _thumbPadding = 4.0;

class SnappingSlider extends StatefulWidget {
  const SnappingSlider({
    super.key,
    required this.value,
    double? secondaryTrackValue,
    required this.onChanged,
    this.snapValues = const [],
    required double max,
  })  : rightMax = max,
        secondaryTrackValueLeft = null,
        secondaryTrackValueRight = secondaryTrackValue,
        leftMax = null;

  const SnappingSlider.bidirectional({
    super.key,
    required this.value,
    this.secondaryTrackValueLeft,
    this.secondaryTrackValueRight,
    required this.onChanged,
    this.snapValues = const [],
    required double this.leftMax,
    required this.rightMax,
  });

  final double value;
  final double? secondaryTrackValueLeft;
  final double? secondaryTrackValueRight;
  final ValueChanged<double> onChanged;
  final List<double> snapValues;
  final double? leftMax;
  final double rightMax;

  @override
  State<SnappingSlider> createState() => _SnappingSliderState();
}

class _SnappingSliderState extends State<SnappingSlider> {
  late final TextPainter _thumbTextPainter;
  late Size _thumbSize;
  var _thumbHover = false;
  var _active = false;
  var _dragStarting = false;

  @override
  void initState() {
    super.initState();
    _thumbTextPainter = TextPainter(textDirection: TextDirection.ltr);
  }

  @override
  void dispose() {
    super.dispose();
    _thumbTextPainter.dispose();
  }

  void _handleUpdate(double width, double dx, double snapDifference) {
    final snapValue = widget.snapValues
        .where((e) => e < 0 ? widget.leftMax != null && -e <= widget.leftMax! : e <= widget.rightMax)
        .map(
          (e) => (
            value: e,
            difference: (widget.leftMax == null
                    ? (widget.rightMax == 0 ? 0 : (dx - _thumbSize.width / 2) - e / widget.rightMax * (width - _thumbSize.width))
                    : dx - width / 2 - (e == 0 && widget.leftMax == 0 ? 0 : e / (e <= 0 ? widget.leftMax! : widget.rightMax)) * (width - _thumbSize.width) / 2)
                .abs()
          ),
        )
        .where((e) => e.difference <= snapDifference)
        .sortedBy<num>((e) => e.difference)
        .firstOrNull
        ?.value;
    final newValue = snapValue ??
        clampDouble(
          widget.leftMax == null
              ? (dx - _thumbSize.width / 2) / (width - _thumbSize.width) * widget.rightMax
              : (dx - width / 2) / (width / 2 - _thumbSize.width / 2) * (dx < width / 2 ? widget.leftMax! : widget.rightMax),
          -(widget.leftMax ?? 0),
          widget.rightMax,
        );
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
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final thumbTextStyle = defaultTextStyle.copyWith(fontSize: MediaQuery.textScalerOf(context).scale(defaultTextStyle.fontSize!));
    _thumbTextPainter.text = TextSpan(text: max(widget.leftMax ?? 0, widget.rightMax).toString(), style: thumbTextStyle);
    _thumbTextPainter.layout();
    _thumbSize = Size(_thumbTextPainter.width + 2 * _thumbPadding, _thumbTextPainter.height + 2 * _thumbPadding);

    final colors = Theme.of(context).colorScheme;
    final activeColor = widget.value <= 0 || widget.leftMax == null ? colors.onPrimary : colors.onSecondary;
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
                    if (widget.leftMax != null)
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
                        width: widget.secondaryTrackValueLeft! / widget.leftMax! * width / 2,
                        height: _trackHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.onSurface.withOpacity(0.1),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(_trackHeight / 2)),
                          ),
                        ),
                      ),
                    Positioned(
                      left: widget.leftMax == null ? 0 : width / 2,
                      top: height / 2 - _trackHeight / 2,
                      width: widget.leftMax == null ? width : width / 2,
                      height: _trackHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.rightMax == 0 ? colors.onSurface.withOpacity(0.12) : (widget.leftMax == null ? colors.primary : colors.secondary),
                          borderRadius: widget.leftMax == null ? BorderRadius.circular(_trackHeight / 2) : const BorderRadius.horizontal(right: Radius.circular(_trackHeight / 2)),
                        ),
                      ),
                    ),
                    if (widget.secondaryTrackValueRight != null && widget.secondaryTrackValueRight! > 0 && widget.rightMax != 0)
                      Positioned(
                        left: widget.leftMax == null ? _thumbSize.width / 2 : width / 2,
                        top: height / 2 - _trackHeight / 2,
                        width: widget.secondaryTrackValueRight! / widget.rightMax * (widget.leftMax == null ? width - _thumbSize.width / 2 : width / 2),
                        height: _trackHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.onSurface.withOpacity(0.1),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(_trackHeight / 2)),
                          ),
                        ),
                      ),
                    if (value != 0)
                      Positioned(
                        left: value <= 0 || widget.leftMax == null ? null : width / 2 - _activeTrackHeight / 2,
                        top: height / 2 - _activeTrackHeight / 2,
                        right: value <= 0 && widget.leftMax != null ? width / 2 - _activeTrackHeight / 2 : null,
                        width: widget.leftMax == null
                            ? _thumbSize.width / 2 + value / widget.rightMax * (width - _thumbSize.width)
                            : value / (value <= 0 ? -widget.leftMax! : widget.rightMax) * width / 2 + _activeTrackHeight / 2,
                        height: _activeTrackHeight,
                        child: DecoratedBox(decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(_activeTrackHeight / 2))),
                      ),
                    Positioned(
                      left: widget.leftMax == null
                          ? (widget.rightMax == 0 ? 0 : value / widget.rightMax * (width - _thumbSize.width))
                          : width / 2 + (value <= 0 && widget.leftMax == 0 ? 0 : value / (value <= 0 ? widget.leftMax! : widget.rightMax) * (width - _thumbSize.width) / 2) - _thumbSize.width / 2,
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
