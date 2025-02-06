import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocibus/widgets/card.dart';
import 'package:vector_math/vector_math_64.dart';

enum Direction { up, right, down, left }

class Popup<T extends Object> extends StatefulWidget {
  const Popup({
    super.key,
    this.controller,
    this.clickable = true,
    this.getDataAt,
    this.getPosition,
    this.getDirection,
    this.direction,
    required this.builder,
    required this.child,
  })  : assert(getDirection != null || direction != null),
        assert(getDataAt != null || T == Object);

  final PopupController<T>? controller;
  final bool clickable;
  final T Function(Offset localPosition)? getDataAt;
  final Offset Function(T data)? getPosition;
  final Direction Function(T data)? getDirection;
  final Direction? direction;
  final Widget Function(BuildContext context, T data) builder;
  final Widget child;

  @override
  State<Popup> createState() => _PopupState<T>();
}

class _PopupState<T extends Object> extends State<Popup<T>> with TickerProviderStateMixin {
  late final PopupController<T> _controller;
  final _inactivePopups = <T>{};
  final _overlayController = OverlayPortalController()..show();
  var _popupHovered = false;
  var _popupPressed = false;
  var _childHovered = false;

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

  void _onTapPopup(PointerDownEvent event) => _popupPressed = true;

  void _onPointerEnterPopup(T data) {
    _popupHovered = true;
    if (_controller.pressed == null && _controller.hovered != data) setState(() => _inactivePopups.remove(data));
    _controller.hovered = data;
  }

  void _onPointerExitPopup(T data) {
    _popupHovered = false;
    if (_childHovered && _controller.hovered == data) return;
    if (_controller.pressed == null) setState(() => _inactivePopups.add(data));
    if (!_childHovered) _controller.hovered = null;
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_popupPressed || _controller.pressed == null) {
      _popupPressed = false;
      return;
    }
    setState(() => _inactivePopups.add(_controller.pressed!));
    _controller.pressed = null;
  }

  void _onTapChild(PointerDownEvent event) {
    final position = (context.findRenderObject()! as RenderBox).globalToLocal(event.position);
    final data = _getDataAt(position);
    if (_controller.pressed != null && _controller.pressed != data) {
      _inactivePopups.add(_controller.pressed!);
      _inactivePopups.remove(data);
      setState(() {});
    }
    _controller.pressed = data == _controller.pressed ? null : data;
  }

  void _onPointerEnterChild(PointerEnterEvent event) {
    _childHovered = true;
    final data = _getDataAt(event.localPosition);
    if (_controller.pressed == null && _controller.hovered != data) setState(() => _inactivePopups.remove(data));
    _controller.hovered = data;
  }

  void _onPointerExitChild() {
    _childHovered = false;
    if (_popupHovered) return;
    if (_controller.pressed == null) setState(() => _inactivePopups.add(_controller.hovered!));
    _controller.hovered = null;
  }

  void _onChildHover(PointerHoverEvent event) {
    final data = _getDataAt(event.localPosition);
    if (data == _controller.hovered) return;
    if (_controller.pressed == null) {
      _inactivePopups.add(_controller.hovered!);
      _inactivePopups.remove(data);
      setState(() {});
    }
    _controller.hovered = data;
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

  Widget _buildPopup(T data, bool active) {
    final direction = widget.getDirection == null ? widget.direction! : widget.getDirection!(data);
    final position = (context.findRenderObject()! as RenderBox).localToGlobal(widget.getPosition == null ? _getFallbackPosition() : widget.getPosition!(data));

    return CustomSingleChildLayout(
      key: ValueKey(data),
      delegate: _LayoutDelegate(direction: direction, position: position),
      child: Listener(
        onPointerDown: active ? _onTapPopup : null,
        child: MouseRegion(
          onEnter: (event) => _onPointerEnterPopup(data),
          onExit: (event) => Future.microtask(() => _onPointerExitPopup(data)),
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: TweenAnimationBuilder(
            tween: active ? Tween(begin: 0.0, end: 1.0) : Tween(begin: 1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            onEnd: active ? null : () => setState(() => _inactivePopups.remove(data)),
            builder: (context, value, child) => _Popup(
              direction: direction,
              position: position,
              scale: value,
              child: ContainerCard(
                size: ContainerCardSize.medium,
                child: widget.builder(context, data),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            for (final data in _inactivePopups) _buildPopup(data, false),
            if (_controller.pressed != null || _controller.hovered != null) _buildPopup(_controller.pressed ?? _controller.hovered!, true),
          ],
        ),
      ),
      child: TapRegion(
        onTapOutside: widget.clickable ? _onTapOutside : null,
        onTapInside: widget.clickable ? _onTapChild : null,
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

class _LayoutDelegate extends SingleChildLayoutDelegate {
  const _LayoutDelegate({required this.direction, required this.position});

  final Direction direction;
  final Offset position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final edges = switch (direction) {
      Direction.up => EdgeInsets.only(bottom: constraints.maxHeight - position.dy),
      Direction.right => EdgeInsets.only(left: position.dx),
      Direction.down => EdgeInsets.only(top: position.dy),
      Direction.left => EdgeInsets.only(right: constraints.maxWidth - position.dx),
    };
    return constraints.deflate(edges);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return switch (direction) {
      Direction.up => Offset(clampDouble(position.dx - childSize.width / 2, 0, size.width - childSize.width), position.dy - childSize.height),
      Direction.right => Offset(position.dx, clampDouble(position.dy - childSize.height / 2, 0, size.height - childSize.height)),
      Direction.down => Offset(clampDouble(position.dx - childSize.width / 2, 0, size.width - childSize.width), position.dy),
      Direction.left => Offset(position.dx - childSize.width, clampDouble(position.dy - childSize.height / 2, 0, size.height - childSize.height)),
    };
  }

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) => direction != oldDelegate.direction || position != oldDelegate.position;
}

class _Popup extends SingleChildRenderObjectWidget {
  const _Popup({required this.direction, required this.position, required this.scale, required super.child});

  final Direction direction;
  final Offset position;
  final double scale;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPopup(
      direction: direction,
      position: position,
      scale: scale,
      arrowColor: Theme.of(context).colorScheme.outline,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderPopup renderObject) {
    renderObject
      ..direction = direction
      ..position = position
      ..scale = scale
      ..arrowColor = Theme.of(context).colorScheme.outline;
  }
}

class _RenderPopup extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  _RenderPopup({required Direction direction, required Offset position, required double scale, required Color arrowColor})
      : _direction = direction,
        _position = position,
        _scale = scale,
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

  double _scale;
  double get scale => _scale;
  set scale(double value) {
    if (value == _scale) return;
    _scale = value;
    markNeedsPaint();
  }

  Color _arrowColor;
  Color get arrowColor => _arrowColor;
  set arrowColor(Color value) {
    if (value == _arrowColor) return;
    _arrowColor = value;
    markNeedsPaint();
  }

  Matrix4 _getTransform([Offset translation = Offset.zero]) {
    final position = globalToLocal(_position);
    return Matrix4.translationValues(translation.dx + position.dx, translation.dy + position.dy, 0)
      ..scale(scale, scale)
      ..translate(-position.dx, -position.dy);
  }

  @override
  bool hitTestSelf(Offset position) {
    if (_scale == 0) return false;
    final transformed = (_getTransform()..invert()).transform3(Vector3(position.dx, position.dy, 0));
    return Rect.fromLTWH(0, 0, size.width, size.height).contains(Offset(transformed.x, transformed.y));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _getTransform((child!.parentData! as BoxParentData).offset),
      position: position,
      hitTest: (result, position) => child!.hitTest(result, position: position),
    );
  }

  static const _padding = 8.0;

  double get _arrowWidth => _direction == Direction.up || _direction == Direction.down ? 16 : 12;
  double get _arrowHeight => _direction == Direction.up || _direction == Direction.down ? 12 : 16;

  @override
  void performLayout() {
    final removedEdgesForChildConstraints = _direction == Direction.left || _direction == Direction.right
        ? EdgeInsets.only(left: _arrowWidth + _padding, top: 2 * _padding)
        : EdgeInsets.only(left: 2 * _padding, top: _arrowHeight + _padding);
    child!.layout(constraints.deflate(removedEdgesForChildConstraints), parentUsesSize: true);

    final width = _direction == Direction.left || _direction == Direction.right ? child!.size.width + _arrowWidth : max(_arrowWidth, child!.size.width);
    final height = _direction == Direction.left || _direction == Direction.right ? max(_arrowHeight, child!.size.height) : child!.size.height + _arrowHeight;

    final showTopPadding = switch (_direction) {
      Direction.up => _position.dy - height < _padding,
      Direction.left || Direction.right => height == constraints.maxHeight - 2 * _padding || _position.dy - height / 2 < _padding,
      Direction.down => false,
    };
    final showRightPadding = switch (_direction) {
      Direction.up || Direction.down => width == constraints.maxWidth - 2 * _padding || constraints.maxWidth - _position.dx - width / 2 < _padding,
      Direction.right => constraints.maxWidth - width < _padding,
      Direction.left => false,
    };
    final showBottomPadding = switch (_direction) {
      Direction.up => false,
      Direction.left || Direction.right => height == constraints.maxHeight - 2 * _padding || constraints.maxHeight - _position.dy - height / 2 < _padding,
      Direction.down => constraints.maxHeight - height < _padding,
    };
    final showLeftPadding = switch (_direction) {
      Direction.up || Direction.down => width == constraints.maxWidth - 2 * _padding || _position.dx - width / 2 < _padding,
      Direction.right => false,
      Direction.left => _position.dx - width < _padding,
    };

    size = Size(
      width + (showLeftPadding ? _padding : 0) + (showRightPadding ? _padding : 0),
      height + (showTopPadding ? _padding : 0) + (showBottomPadding ? _padding : 0),
    );

    final childOffset = switch (_direction) {
      Direction.up || Direction.left => Offset(showLeftPadding ? _padding : 0, showTopPadding ? _padding : 0),
      Direction.right => Offset(_arrowWidth, showTopPadding ? _padding : 0),
      Direction.down => Offset(showLeftPadding ? _padding : 0, _arrowHeight),
    };
    child!.parentData = BoxParentData()..offset = childOffset;
  }

  @override
  void paint(PaintingContext context, Offset offset) => layer = context.pushTransform(needsCompositing, offset, _getTransform(), _paintScaled, oldLayer: layer as TransformLayer?);

  void _paintScaled(PaintingContext context, Offset offset) {
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
    final position = globalToLocal(_position);
    final arrowPosition = switch (_direction) {
      Direction.up => position.translate(-_arrowWidth / 2, -_arrowHeight),
      Direction.right => position.translate(0, -_arrowHeight / 2),
      Direction.down => position.translate(-_arrowWidth / 2, 0),
      Direction.left => position.translate(-_arrowWidth, -_arrowHeight / 2),
    };
    context.canvas.drawPath(arrowPath.shift(offset + arrowPosition), Paint()..color = _arrowColor);
  }
}
