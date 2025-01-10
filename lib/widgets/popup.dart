import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _popupPadding = 8;

class Popup extends StatefulWidget {
  const Popup({
    super.key,
    this.controller,
    this.fixOnTap = true,
    this.getPopupPosition,
    this.getPopupDirection,
    this.direction,
    required this.popupBuilder,
    required this.child,
  }) : assert(direction != null || getPopupDirection != null);

  final PopupController? controller;
  final bool fixOnTap;
  final Offset Function(Offset localPosition)? getPopupPosition;
  final Direction Function(Offset localPopupPosition)? getPopupDirection;
  final Direction? direction;
  final Widget Function(BuildContext context, Offset localPosition) popupBuilder;
  final Widget child;

  @override
  State<Popup> createState() => _PopupState();
}

enum Direction { up, right, down, left }

class _PopupState extends State<Popup> {
  final _overlayController = OverlayPortalController();
  late final PopupController _controller;
  var _hoveringOverOverlay = false;
  var _tappedOverlay = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PopupController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Offset _getPopupPosition(Offset localPosition) {
    if (widget.getPopupPosition != null) return widget.getPopupPosition!(localPosition);
    final bounds = Offset.zero & (context.findRenderObject()! as RenderBox).size;
    return switch (widget.direction!) {
      Direction.up => bounds.topCenter,
      Direction.right => bounds.centerRight,
      Direction.down => bounds.bottomCenter,
      Direction.left => bounds.centerLeft,
    };
  }

  void _onTapOverlay(PointerDownEvent event) => _tappedOverlay = true;

  void _onPointerEnterOverlay(PointerEnterEvent event) => _hoveringOverOverlay = true;

  void _onPointerExitOverlay(PointerExitEvent event) {
    _hoveringOverOverlay = false;
    if (_controller.tapPopupPosition != null) return;
    _controller.hoverPopupPosition = null;
    _overlayController.hide();
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_tappedOverlay) {
      _tappedOverlay = false;
      return;
    }
    _controller.tapPopupPosition = null;
    _overlayController.hide();
  }

  void _onTapChild(PointerDownEvent event) {
    final tapPosition = (context.findRenderObject()! as RenderBox).globalToLocal(event.position);
    final popupPosition = _getPopupPosition(tapPosition);
    if (popupPosition == _controller.tapPopupPosition) {
      _controller.tapPopupPosition = null;
      return;
    }
    _controller.tapPopupPosition = popupPosition;
    _overlayController.show();
  }

  void _onPointerEnterChild(PointerEnterEvent event) {
    _controller.hoverPopupPosition = _getPopupPosition(event.localPosition);
    _overlayController.show();
  }

  void _onPointerExitChild() {
    if (_hoveringOverOverlay) return;
    _controller.hoverPopupPosition = null;
    if (_controller.tapPopupPosition == null) _overlayController.hide();
  }

  void _onChildHover(PointerHoverEvent event) {
    final popupPosition = _getPopupPosition(event.localPosition);
    if (popupPosition == _controller.hoverPopupPosition) return;
    _overlayController.show();
    _controller.hoverPopupPosition = popupPosition;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (overlayContext) {
        final localPosition = _controller.tapPopupPosition ?? _controller.hoverPopupPosition!;
        final direction = widget.getPopupDirection != null ? widget.getPopupDirection!(localPosition) : widget.direction!;
        final globalPosition = (context.findRenderObject()! as RenderBox).localToGlobal(localPosition);

        // TODO Hairline width between arrow and card

        return Listener(
          onPointerDown: _onTapOverlay,
          child: MouseRegion(
            onEnter: _onPointerEnterOverlay,
            onExit: _onPointerExitOverlay,
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: _Overlay(
              direction: direction,
              position: globalPosition,
              arrowColor: Theme.of(overlayContext).colorScheme.surfaceContainerHighest,
              child: Card.filled(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.popupBuilder(overlayContext, localPosition),
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

class PopupController extends ChangeNotifier {
  Offset? _hoverPopupPosition;
  Offset? get hoverPopupPosition => _hoverPopupPosition;
  set hoverPopupPosition(Offset? value) {
    if (value == _hoverPopupPosition) return;
    _hoverPopupPosition = value;
    notifyListeners();
  }

  Offset? _tapPopupPosition;
  Offset? get tapPopupPosition => _tapPopupPosition;
  set tapPopupPosition(Offset? value) {
    if (value == _tapPopupPosition) return;
    _tapPopupPosition = value;
    notifyListeners();
  }
}

class _Overlay extends SingleChildRenderObjectWidget {
  const _Overlay({required this.direction, required this.position, required this.arrowColor, required super.child});

  final Direction direction;
  final Offset position;
  final Color arrowColor;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderOverlay(direction: direction, position: position, arrowColor: arrowColor);

  @override
  void updateRenderObject(BuildContext context, _RenderOverlay renderObject) => renderObject
    ..direction = direction
    ..position = position
    ..arrowColor = arrowColor;
}

class _RenderOverlay extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  _RenderOverlay({required Direction direction, required Offset position, required Color arrowColor})
      : _direction = direction,
        _position = position,
        _arrowColor = arrowColor;

  Direction _direction;
  Direction get direction => _direction;
  set direction(Direction value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsLayout();
  }

  Offset _position;
  Offset get position => _position;
  set position(Offset value) {
    if (value == _position) return;
    _position = value;
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
      Direction.up => Rect.fromLTWH(childOffset.dx, _position.dy - _arrowHeight, childSize.width, _arrowHeight),
      Direction.right => Rect.fromLTWH(_position.dx, childOffset.dy, _arrowWidth, childSize.height),
      Direction.down => Rect.fromLTWH(childOffset.dx, _position.dy, childSize.width, _arrowHeight),
      Direction.left => Rect.fromLTWH(_position.dx - _arrowWidth, childOffset.dy, _arrowWidth, childSize.height),
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
      Direction.up => BoxConstraints(maxWidth: size.width - 2 * _popupPadding, maxHeight: _position.dy - _arrowHeight - _popupPadding),
      Direction.right => BoxConstraints(maxWidth: size.width - _position.dx - _arrowWidth - _popupPadding, maxHeight: size.height - 2 * _popupPadding),
      Direction.down => BoxConstraints(maxWidth: size.width - 2 * _popupPadding, maxHeight: size.height - _position.dy - _arrowHeight - _popupPadding),
      Direction.left => BoxConstraints(maxWidth: _position.dx - _arrowWidth - _popupPadding, maxHeight: size.height - 2 * _popupPadding),
    };
    child!.layout(childConstraints, parentUsesSize: true);

    final childWidth = child!.size.width;
    final childHeight = child!.size.height;
    final childOffset = switch (_direction) {
      Direction.left || Direction.right => Offset(
          _direction == Direction.left ? _position.dx - _arrowWidth - childWidth : _position.dx + _arrowWidth,
          _position.dy - childHeight / 2 + max(0, childHeight / 2 - _position.dy + _popupPadding) - max(0, _position.dy + childHeight / 2 - size.height + _popupPadding),
        ),
      Direction.up || Direction.down => Offset(
          _position.dx - childWidth / 2 + max(0, childWidth / 2 - _position.dx + _popupPadding) - max(0, _position.dx + childWidth / 2 - size.width + _popupPadding),
          _direction == Direction.up ? _position.dy - _arrowHeight - childHeight : _position.dy + _arrowHeight,
        ),
    };
    child!.parentData = BoxParentData()..offset = childOffset;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset + (child!.parentData! as BoxParentData).offset);

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
      Direction.up => _position.translate(-_arrowWidth / 2, -_arrowHeight),
      Direction.right => _position.translate(0, -_arrowHeight / 2),
      Direction.down => _position.translate(-_arrowWidth / 2, 0),
      Direction.left => _position.translate(-_arrowWidth, -_arrowHeight / 2),
    };
    final arrowPaint = Paint()..color = _arrowColor;
    context.canvas.drawPath(arrowPath.shift(offset + arrowPosition), arrowPaint);
  }
}
