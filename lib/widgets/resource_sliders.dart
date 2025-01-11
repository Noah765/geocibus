import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResourceSliders extends StatelessWidget {
  const ResourceSliders({
    super.key,
    required this.controller,
    required this.leftText,
    required this.rightText,
    required this.waterLeftMax,
    required this.waterRightMax,
    required this.foodLeftMax,
    required this.foodRightMax,
  });

  final ResourceSlidersController controller;

  final String leftText;
  final String rightText;

  final int waterLeftMax;
  final int waterRightMax;

  final int foodLeftMax;
  final int foodRightMax;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [Text(leftText), const Spacer(), Text(rightText)]),
        _LabeledSlider(valueNotifier: controller.water, resetNotifier: controller._reset, icon: FontAwesomeIcons.glassWater, leftMax: waterLeftMax, rightMax: waterRightMax),
        _LabeledSlider(valueNotifier: controller.food, resetNotifier: controller._reset, icon: FontAwesomeIcons.bowlFood, leftMax: foodLeftMax, rightMax: foodRightMax),
      ],
    );
  }
}

class ResourceSlidersController {
  final water = ValueNotifier(0);
  final food = ValueNotifier(0);

  final _reset = _ResetNotifier();
  void reset() {
    water.value = 0;
    food.value = 0;
    _reset.reset();
  }

  void dispose() {
    water.dispose();
    food.dispose();
    _reset.dispose();
  }
}

class _ResetNotifier extends ChangeNotifier {
  void reset() => notifyListeners();
}

class _LabeledSlider extends StatefulWidget {
  const _LabeledSlider({required this.valueNotifier, required this.resetNotifier, required this.icon, required this.leftMax, required this.rightMax});

  final ValueNotifier<int> valueNotifier;
  final _ResetNotifier resetNotifier;

  final IconData icon;

  final int leftMax;
  final int rightMax;

  @override
  State<_LabeledSlider> createState() => _LabeledSliderState();
}

class _LabeledSliderState extends State<_LabeledSlider> {
  late final VoidCallback _resetNotifierListener;
  var _value = 0.0;

  @override
  void initState() {
    super.initState();
    _resetNotifierListener = () => setState(() => _value = 0);
    widget.resetNotifier.addListener(_resetNotifierListener);
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_resetNotifierListener);
    super.dispose();
  }

  int _convertValue() => switch (_value) {
        < 0 => (_value * widget.leftMax).round(),
        > 0 => (_value * widget.rightMax).round(),
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbColor = switch (_value) { <= 0 => colorScheme.onPrimaryContainer, _ => colorScheme.onSecondaryContainer };

    return Row(
      children: [
        FaIcon(widget.icon),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              thumbColor: thumbColor,
              overlayColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.dragged) || states.contains(WidgetState.focused)) return thumbColor.withOpacity(0.1);
                if (states.contains(WidgetState.hovered)) return thumbColor.withOpacity(0.08);
                return Colors.transparent;
              }),
              valueIndicatorColor: thumbColor,
              //valueIndicatorStrokeColor: ,
              // TODO Choose appropriate colors, maybe draw value inside thumb? Should there be an input field for precise values?
              trackShape: _TrackShape(
                leftTrackColor: colorScheme.primaryContainer,
                leftActiveTrackColor: colorScheme.onPrimaryContainer,
                rightTrackColor: colorScheme.secondaryContainer,
                rightActiveTrackColor: colorScheme.onSecondaryContainer,
              ),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: _value,
              onChanged: (value) => setState(() => _value = value),
              onChangeEnd: (value) => widget.valueNotifier.value = _convertValue(),
              min: -1,
              label: _convertValue().abs().toString(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _TrackShape({required this.leftTrackColor, required this.leftActiveTrackColor, required this.rightTrackColor, required this.rightActiveTrackColor});

  final Color leftTrackColor;
  final Color leftActiveTrackColor;
  final Color rightTrackColor;
  final Color rightActiveTrackColor;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final center = offset + Offset(parentBox.size.width / 2, parentBox.size.height / 2);
    final isThumbLeft = thumbCenter.dx < center.dx;

    final leftPaint = Paint()..color = leftTrackColor;
    final rightPaint = Paint()..color = rightTrackColor;
    final activePaint = Paint()..color = isThumbLeft ? leftActiveTrackColor : rightActiveTrackColor;

    final rect = getPreferredRect(parentBox: parentBox, offset: offset, sliderTheme: sliderTheme);

    final radius = Radius.circular(rect.height / 2);
    final activeRadius = Radius.circular((rect.height + additionalActiveTrackHeight) / 2);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        rect.left,
        rect.top,
        isThumbLeft ? thumbCenter.dx : center.dx,
        rect.bottom,
        topLeft: radius,
        bottomLeft: radius,
      ),
      leftPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        isThumbLeft ? center.dx : thumbCenter.dx,
        rect.top,
        rect.right,
        rect.bottom,
        topRight: radius,
        bottomRight: radius,
      ),
      rightPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        isThumbLeft ? thumbCenter.dx : center.dx,
        rect.top - (additionalActiveTrackHeight / 2),
        isThumbLeft ? center.dx : thumbCenter.dx,
        rect.bottom + (additionalActiveTrackHeight / 2),
        topLeft: isThumbLeft ? Radius.zero : activeRadius,
        topRight: isThumbLeft ? activeRadius : Radius.zero,
        bottomRight: isThumbLeft ? activeRadius : Radius.zero,
        bottomLeft: isThumbLeft ? Radius.zero : activeRadius,
      ),
      activePaint,
    );
  }
}
