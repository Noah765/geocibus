import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _textFontSizeToIconFontSize = 0.682;
const _removedToPixels = 0.0201;
const _removedBottomPixels = 0.0223;
const _debugDrawHelperLines = false;

class IconSpan extends WidgetSpan {
  IconSpan({required IconData icon, int removedTop = 1, int removedBottom = 1})
      : super(
          child: _Icon(icon: icon, removedTop: removedTop * _removedToPixels, removedBottom: removedBottom * _removedBottomPixels),
          alignment: PlaceholderAlignment.aboveBaseline,
          baseline: TextBaseline.alphabetic,
        );
}

class _Icon extends LeafRenderObjectWidget {
  const _Icon({required this.icon, required this.removedTop, required this.removedBottom});

  final IconData icon;
  final double removedTop;
  final double removedBottom;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderIcon(icon: icon, removedTop: removedTop, removedBottom: removedBottom);

  @override
  void updateRenderObject(BuildContext context, _RenderIcon renderObject) {
    renderObject
      ..icon = icon
      ..removedTop = removedTop
      ..removedBottom = removedBottom;
  }
}

class _RenderIcon extends RenderBox {
  _RenderIcon({required IconData icon, required double removedTop, required double removedBottom})
      : _icon = icon,
        _removedTop = removedTop,
        _removedBottom = removedBottom,
        _painter = TextPainter(textDirection: TextDirection.ltr);

  IconData _icon;
  IconData get icon => _icon;
  set icon(IconData value) {
    if (value == _icon) return;
    _icon = value;
    markNeedsLayout();
  }

  double _removedTop;
  double get removedTop => _removedTop;
  set removedTop(double value) {
    if (value == _removedTop) return;
    _removedTop = value;
    markNeedsLayout();
  }

  double _removedBottom;
  double get removedBottom => _removedBottom;
  set removedBottom(double value) {
    if (value == _removedBottom) return;
    _removedBottom = value;
    markNeedsLayout();
  }

  final TextPainter _painter;

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  RenderObject _visitParents(RenderObject parent, bool Function(RenderObject parent) visitor) {
    if (visitor(parent)) return parent;
    return _visitParents(parent.parent!, visitor);
  }

  List<TextStyle>? _getTextStyles(InlineSpan span, IconSpan iconSpan) {
    if (span == iconSpan) return [];
    if (span is! TextSpan || span.children == null) return null;
    for (final child in span.children!) {
      final result = _getTextStyles(child, iconSpan);
      if (result == null) continue;
      if (span.style == null) return result;
      return result..add(span.style!);
    }
    return null;
  }

  @override
  void performLayout() {
    final span = (_visitParents(this, (parent) => parent.parentData is TextParentData).parentData! as TextParentData).span! as IconSpan;
    final renderParagraph = _visitParents(parent!, (parent) => parent is RenderParagraph) as RenderParagraph;
    final style = _getTextStyles(renderParagraph.text, span)!.reversed.reduce((value, e) => value.merge(e));

    _painter.text = TextSpan(
      text: String.fromCharCode(_icon.codePoint),
      style: TextStyle(
        color: _debugDrawHelperLines ? Colors.red : style.color,
        fontSize: style.fontSize! * _textFontSizeToIconFontSize * (1 + _removedTop + _removedBottom),
        fontFamily: _icon.fontFamily,
        package: _icon.fontPackage,
      ),
    );
    _painter.layout();

    size = constraints.constrain(Size(_painter.width, _painter.height / (1 + _removedTop + _removedBottom)));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_debugDrawHelperLines) {
      context.canvas.drawLine(offset.translate(0, -0.5), offset.translate(size.width, -0.5), Paint());
      context.canvas.drawLine(offset.translate(0, size.height + 0.5), offset.translate(size.width, size.height + 0.5), Paint());
    }

    _painter.paint(context.canvas, offset.translate(0, -_painter.height * _removedTop));
  }
}
