import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _popupPadding = 8;

enum Direction { up, right, down, left }

class Popup<T extends Object> extends StatefulWidget {
  const Popup({
    super.key,
    this.controller,
    this.getDataAt,
    this.getPosition,
    this.getDirection,
    this.direction,
    required this.builder,
    required this.child,
  })  : assert(getDirection != null || direction != null),
        assert(getDataAt != null || T == Object);

  final PopupController<T>? controller;
  final T Function(Offset localPosition)? getDataAt;
  final Offset Function(T data)? getPosition;
  final Direction Function(T data)? getDirection;
  final Direction? direction;
  final Widget Function(BuildContext context, T data) builder;
  final Widget child;

  @override
  State<Popup> createState() => _PopupState<T>();
}

class _PopupState<T extends Object> extends State<Popup<T>> {
  final _overlayController = OverlayPortalController();
  late final PopupController<T> _controller;
  var _overlayHovered = false;
  var _overlayPressed = false;

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

  T _getDataAt(Offset localPosition) => widget.getDataAt == null ? true as T : widget.getDataAt!(localPosition);

  void _onTapOverlay(PointerDownEvent event) => _overlayPressed = true;

  void _onPointerEnterOverlay(PointerEnterEvent event) => _overlayHovered = true;

  void _onPointerExitOverlay(PointerExitEvent event) {
    _overlayHovered = false;
    if (_controller.pressed != null) return;
    _controller.hovered = null;
    _overlayController.hide();
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_overlayPressed) {
      _overlayPressed = false;
      return;
    }
    _controller.hovered = null;
    _controller.pressed = null;
    _overlayController.hide();
  }

  void _onTapChild(PointerDownEvent event) {
    final position = (context.findRenderObject()! as RenderBox).globalToLocal(event.position);
    final data = _getDataAt(position);
    _controller.hovered = data;
    _controller.pressed = data == _controller.pressed ? null : data;
    _overlayController.show();
  }

  void _onPointerEnterChild(PointerEnterEvent event) {
    _controller.hovered = _getDataAt(event.localPosition);
    _overlayController.show();
  }

  void _onPointerExitChild() {
    if (_overlayHovered) return;
    _controller.hovered = null;
    if (_controller.pressed == null) _overlayController.hide();
  }

  void _onChildHover(PointerHoverEvent event) {
    if (_controller.hovered == null) return;
    final data = _getDataAt(event.localPosition);
    if (data == _controller.hovered) return;
    _controller.hovered = data;
    _overlayController.show();
  }

  Offset _getFallbackPosition() {
    final bounds = Offset.zero & (context.findRenderObject()! as RenderBox).size;
    return switch (widget.direction!) {
      Direction.up => bounds.topCenter,
      Direction.right => bounds.centerRight,
      Direction.down => bounds.bottomCenter,
      Direction.left => bounds.centerLeft,
    };
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (overlayContext) {
        final data = _controller.pressed ?? _controller.hovered!;
        final globalPosition = (context.findRenderObject()! as RenderBox).localToGlobal(widget.getPosition == null ? _getFallbackPosition() : widget.getPosition!(data));
        final direction = widget.getDirection == null ? widget.direction! : widget.getDirection!(data);

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
              arrowColor: Theme.of(overlayContext).colorScheme.outline,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.builder(overlayContext, data),
                ),
              ),
            ),
          ),
        );
      },
      child: TapRegion(
        onTapOutside: _onTapOutside,
        onTapInside: _onTapChild,
        child: MouseRegion(
          onEnter: _onPointerEnterChild,
          onExit: (event) => Future.microtask(_onPointerExitChild),
          onHover: _onChildHover,
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: widget.child,
        ),
      ),
    );
  }
}

class PopupController<T extends Object> extends ChangeNotifier {
  T? _hovered;
  T? get hovered => _hovered;
  set hovered(T? value) {
    if (value == _hovered) return;
    _hovered = value;
    notifyListeners();
  }

  T? _pressed;
  T? get pressed => _pressed;
  set pressed(T? value) {
    if (value == _pressed) return;
    _pressed = value;
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
