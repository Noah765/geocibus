import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _popupPadding = 8;

class Popup extends StatefulWidget {
  const Popup({
    super.key,
    this.fixOnTap = true,
    this.direction,
    this.getPopupData,
    required this.popupBuilder,
    required this.child,
  }) : assert(direction != null || getPopupData != null);

  final bool fixOnTap;
  final Direction? direction;
  final (Offset, Direction) Function(Offset position)? getPopupData;
  final Widget Function(BuildContext context, Offset position) popupBuilder;
  final Widget child;

  @override
  State<Popup> createState() => _PopupState();
}

enum Direction { up, right, down, left }

class _PopupState extends State<Popup> {
  final _overlayController = OverlayPortalController();
  var _hoveringOverOverlay = false;
  var _tappedOverlay = false;
  Offset? _hoverPosition;
  Offset? _tapPosition;

  (Offset, Direction) _getPopupData(Offset position) {
    if (widget.getPopupData != null) return widget.getPopupData!(position);
    final bounds = Offset.zero & (context.findRenderObject()! as RenderBox).size;
    final offset = switch (widget.direction!) {
      Direction.up => bounds.topCenter,
      Direction.right => bounds.centerRight,
      Direction.down => bounds.bottomCenter,
      Direction.left => bounds.centerLeft,
    };
    return (offset, widget.direction!);
  }

  void _onTapOverlay(PointerDownEvent event) => _tappedOverlay = true;

  void _onPointerEnterOverlay(PointerEnterEvent event) => _hoveringOverOverlay = true;

  void _onPointerExitOverlay(PointerExitEvent event) {
    _hoveringOverOverlay = false;
    if (_tapPosition == null) _overlayController.hide();
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_tappedOverlay) {
      _tappedOverlay = false;
      return;
    }
    _tapPosition = null;
    _overlayController.hide();
  }

  void _onTapChild(PointerDownEvent event) {
    final position = (context.findRenderObject()! as RenderBox).globalToLocal(event.position);
    final tappedSameRegion = _tapPosition != null && _getPopupData(_tapPosition!).$1 == _getPopupData(position).$1;
    if (tappedSameRegion) {
      _tapPosition = null;
      return;
    }
    _tapPosition = position;
    _overlayController.show();
  }

  void _onPointerEnterChild(PointerEnterEvent event) {
    _hoverPosition = event.localPosition;
    _overlayController.show();
  }

  void _onPointerExitChild() {
    if (_hoveringOverOverlay) return;
    _hoverPosition = null;
    if (_tapPosition == null) _overlayController.hide();
  }

  void _onChildHover(PointerHoverEvent event) {
    if (_tapPosition != null) return;
    if (_getPopupData(_hoverPosition!).$1 != _getPopupData(event.localPosition).$1) _overlayController.show();
    _hoverPosition = event.localPosition;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (_) {
        final (localOffset, direction) = _getPopupData(_tapPosition ?? _hoverPosition!);
        final offset = (context.findRenderObject()! as RenderBox).localToGlobal(localOffset);

        // TODO Hairline width between arrow and card

        return Listener(
          onPointerDown: _onTapOverlay,
          child: MouseRegion(
            onEnter: _onPointerEnterOverlay,
            onExit: _onPointerExitOverlay,
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: _Overlay(
              direction: direction,
              offset: offset,
              arrowColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Card.filled(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.popupBuilder(context, _tapPosition ?? _hoverPosition!),
                ),
              ),
            ),
          ),
        );
      },
      child: TapRegion(
        onTapOutside: widget.fixOnTap ? _onTapOutside : null,
        onTapInside: widget.fixOnTap ? _onTapChild : null,
        child: MouseRegion(
          onEnter: _onPointerEnterChild,
          onExit: (event) => Future.microtask(_onPointerExitChild), // TODO Debug resize errors
          onHover: _onChildHover,
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: widget.child,
        ),
      ),
    );
  }
}

class _Overlay extends SingleChildRenderObjectWidget {
  const _Overlay({required this.direction, required this.offset, required this.arrowColor, required super.child});

  final Direction direction;
  final Offset offset;
  final Color arrowColor;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderOverlay(direction: direction, offset: offset, arrowColor: arrowColor);

  @override
  void updateRenderObject(BuildContext context, _RenderOverlay renderObject) => renderObject
    ..direction = direction
    ..offset = offset
    ..arrowColor = arrowColor;
}

class _RenderOverlay extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  _RenderOverlay({required Direction direction, required Offset offset, required Color arrowColor})
      : _direction = direction,
        _offset = offset,
        _arrowColor = arrowColor;

  Direction _direction;
  Direction get direction => _direction;
  set direction(Direction value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsLayout();
  }

  Offset _offset;
  Offset get offset => _offset;
  set offset(Offset value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsLayout();
  }

  Color _arrowColor;
  Color get arrowColor => _arrowColor;
  set arrowColor(Color value) {
    if (value == _arrowColor) return;
    _arrowColor = value;
    markNeedsPaint();
  }

  double get _arrowWidth => _direction == Direction.up || _direction == Direction.down ? 16 : 12;
  double get _arrowHeight => _direction == Direction.up || _direction == Direction.down ? 12 : 16;

  @override
  bool hitTestSelf(Offset position) {
    final childOffset = (child!.parentData! as BoxParentData).offset;
    final childSize = child!.size;
    final rect = switch (_direction) {
      Direction.up => Rect.fromLTWH(childOffset.dx, _offset.dy - _arrowHeight, childSize.width, _arrowHeight),
      Direction.right => Rect.fromLTWH(_offset.dx, childOffset.dy, _arrowWidth, childSize.height),
      Direction.down => Rect.fromLTWH(childOffset.dx, _offset.dy, childSize.width, _arrowHeight),
      Direction.left => Rect.fromLTWH(_offset.dx - _arrowWidth, childOffset.dy, _arrowWidth, childSize.height),
    };
    return rect.contains(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => child!.hitTest(result, position: position - (child!.parentData! as BoxParentData).offset);

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    final childConstraints = switch (_direction) {
      Direction.up => BoxConstraints(maxWidth: size.width - 2 * _popupPadding, maxHeight: _offset.dy - _arrowHeight - _popupPadding),
      Direction.right => BoxConstraints(maxWidth: size.width - _offset.dx - _arrowWidth - _popupPadding, maxHeight: size.height - 2 * _popupPadding),
      Direction.down => BoxConstraints(maxWidth: size.width - 2 * _popupPadding, maxHeight: size.height - _offset.dy - _arrowHeight - _popupPadding),
      Direction.left => BoxConstraints(maxWidth: _offset.dx - _arrowWidth - _popupPadding, maxHeight: size.height - 2 * _popupPadding),
    };
    child!.layout(childConstraints, parentUsesSize: true);

    final childWidth = child!.size.width;
    final childHeight = child!.size.height;
    final childOffset = switch (_direction) {
      Direction.left || Direction.right => Offset(
          _direction == Direction.left ? _offset.dx - _arrowWidth - childWidth : _offset.dx + _arrowWidth,
          _offset.dy - childHeight / 2 + max(0, childHeight / 2 - _offset.dy + _popupPadding) - max(0, _offset.dy + childHeight / 2 - size.height + _popupPadding),
        ),
      Direction.up || Direction.down => Offset(
          _offset.dx - childWidth / 2 + max(0, childWidth / 2 - _offset.dx + _popupPadding) - max(0, _offset.dx + childWidth / 2 - size.width + _popupPadding),
          _direction == Direction.up ? _offset.dy - _arrowHeight - childHeight : _offset.dy + _arrowHeight,
        ),
    };
    child!.parentData = BoxParentData()..offset = childOffset;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    child!.paint(context, offset + (child!.parentData! as BoxParentData).offset);

    final arrowPath = switch (_direction) {
      Direction.up => Path()
        ..lineTo(_arrowWidth / 2, _arrowHeight)
        ..lineTo(_arrowWidth, 0)
        ..lineTo(0, 0),
      Direction.right => Path()
        ..moveTo(0, _arrowHeight / 2)
        ..lineTo(_arrowWidth, 0)
        ..lineTo(_arrowWidth, _arrowHeight)
        ..lineTo(0, _arrowHeight / 2),
      Direction.down => Path()
        ..moveTo(0, _arrowHeight)
        ..lineTo(_arrowWidth / 2, 0)
        ..lineTo(_arrowWidth, _arrowHeight)
        ..lineTo(0, _arrowHeight),
      Direction.left => Path()
        ..lineTo(0, _arrowHeight)
        ..lineTo(_arrowWidth, _arrowHeight / 2)
        ..lineTo(0, 0),
    };
    final arrowPosition = switch (_direction) {
      Direction.up => _offset.translate(-_arrowWidth / 2, -_arrowHeight),
      Direction.right => _offset.translate(0, -_arrowHeight / 2),
      Direction.down => _offset.translate(-_arrowWidth / 2, 0),
      Direction.left => _offset.translate(-_arrowWidth, -_arrowHeight / 2),
    };
    final arrowPaint = Paint()..color = _arrowColor;
    context.canvas.drawPath(arrowPath.shift(offset + arrowPosition), arrowPaint);
  }
}
