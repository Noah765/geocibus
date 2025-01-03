import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Popup extends StatefulWidget {
  const Popup({
    super.key,
    this.fixOnTap = true,
    required this.getPopupData,
    required this.popupBuilder,
    required this.child,
  });

  final bool fixOnTap;
  final (Offset, Direction) Function(Offset position) getPopupData;
  final Widget Function(BuildContext context, Offset position) popupBuilder;
  final Widget child;

  @override
  State<Popup> createState() => _PopupState();
}

enum Direction { up, right, down, left }

class _PopupState extends State<Popup> {
  final _overlayController = OverlayPortalController();
  final _key = GlobalKey();
  var _hoveringOverOverlay = false;
  Offset? _hoverPosition;
  Offset? _tapPosition;

  void _onPointerEnterOverlay() => _hoveringOverOverlay = true;

  void _onPointerExitOverlay() {
    _hoveringOverOverlay = false;
    if (_tapPosition == null) _overlayController.hide();
  }

  void _onTapChild(TapUpDetails details) {
    final isHit = (_key.currentContext!.findRenderObject()! as RenderBox).hitTest(BoxHitTestResult(), position: details.localPosition);
    if (!isHit) {
      _tapPosition = null;
      _overlayController.hide();
      return;
    }
    final tappedSameRegion = _tapPosition != null && widget.getPopupData(_tapPosition!).$1 == widget.getPopupData(details.localPosition).$1;
    if (tappedSameRegion) {
      _tapPosition = null;
      return;
    }
    _tapPosition = details.localPosition;
    _overlayController.show();
  }

  void _onPointerEnterChild(PointerEnterEvent event) {
    //print('Enter. Hover: $_hoverPosition Tap: $_tapPosition');
    _hoverPosition = event.localPosition;
    _overlayController.show();
  }

  void _onPointerExitChild() {
    //print('Exit. Hover: $_hoverPosition Tap: $_tapPosition, Overlay: $_hoveringOverOverlay');
    if (_hoveringOverOverlay) return;
    _hoverPosition = null;
    if (_tapPosition == null) _overlayController.hide();
  }

  void _onChildHover(PointerHoverEvent event) {
    //print('Hover: $_hoverPosition Tap: $_tapPosition');
    if (_tapPosition != null) return;
    if (widget.getPopupData(_hoverPosition!).$1 != widget.getPopupData(event.localPosition).$1) _overlayController.show();
    _hoverPosition = event.localPosition;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      key: _key,
      controller: _overlayController,
      overlayChildBuilder: (context) {
        final data = widget.getPopupData(_tapPosition ?? _hoverPosition!);
        final offset = (_key.currentContext!.findRenderObject()! as RenderBox).localToGlobal(data.$1);

        // TODO Hairline width between arrow and card
        final arrow = CustomPaint(
          painter: _ArrowPainter(direction: data.$2, color: Theme.of(context).colorScheme.surfaceContainerHighest),
          size: data.$2 == Direction.up || data.$2 == Direction.down ? const Size(16, 12) : const Size(12, 16),
        );
        final child = Card.filled(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: widget.popupBuilder(context, _tapPosition ?? _hoverPosition!),
          ),
        );

        return CustomSingleChildLayout(
          delegate: _OverlayLayoutDelegate(direction: data.$2, offset: offset),
          child: MouseRegion(
            onEnter: (event) => _onPointerEnterOverlay(),
            onExit: (event) => _onPointerExitOverlay(),
            child: switch (data.$2) {
              Direction.up => Column(mainAxisSize: MainAxisSize.min, children: [child, arrow]),
              Direction.right => Row(mainAxisSize: MainAxisSize.min, children: [arrow, child]),
              Direction.down => Column(mainAxisSize: MainAxisSize.min, children: [arrow, child]),
              Direction.left => Row(mainAxisSize: MainAxisSize.min, children: [child, arrow]),
            },
          ),
        );
      },
      child: GestureDetector(
        onTapUp: widget.fixOnTap ? _onTapChild : null,
        behavior: HitTestBehavior.translucent,
        child: MouseRegion(
          onEnter: _onPointerEnterChild,
          onExit: (event) => Future.microtask(_onPointerExitChild), // TODO Debug resize errors (and remove prints)
          onHover: _onChildHover,
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: widget.child,
        ),
      ),
    );
  }
}

class _OverlayLayoutDelegate extends SingleChildLayoutDelegate {
  const _OverlayLayoutDelegate({required this.direction, required this.offset});

  final Direction direction;
  final Offset offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) => switch (direction) {
        Direction.up => Offset(offset.dx - childSize.width / 2, offset.dy - childSize.height),
        Direction.right => Offset(offset.dx, offset.dy - childSize.height / 2),
        Direction.down => Offset(offset.dx - childSize.width / 2, offset.dy),
        Direction.left => Offset(offset.dx - childSize.width, offset.dy - childSize.height / 2),
      };

  @override
  bool shouldRelayout(_OverlayLayoutDelegate oldDelegate) => direction != oldDelegate.direction || offset != oldDelegate.offset;
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.direction, required this.color});

  final Direction direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = switch (direction) {
      Direction.up => Path()
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..lineTo(0, 0),
      Direction.right => Path()
        ..moveTo(0, size.height / 2)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height / 2),
      Direction.down => Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height),
      Direction.left => Path()
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, 0),
    };

    final paint = Paint()..color = color;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => direction != oldDelegate.direction || color != oldDelegate.color;
}
