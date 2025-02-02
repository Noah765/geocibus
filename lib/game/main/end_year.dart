import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocibus/models/game.dart';
import 'package:geocibus/theme.dart';
import 'package:provider/provider.dart';

class MainEndYear extends StatelessWidget {
  const MainEndYear({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final resourcesStyle = Theme.of(context).textTheme.headlineMedium!;
    final resourcesHeight = (MediaQuery.textScalerOf(context).scale(resourcesStyle.fontSize!) * resourcesStyle.height!).roundToDouble() + getTextPadding(context, resourcesStyle, 3, 2).vertical;
    final iconSize = resourcesHeight / 2 + 14 / 3;

    return SizedBox.square(
      dimension: iconSize + getIconPadding(context, iconSize, 3).horizontal,
      child: FloatingActionButton(
        tooltip: 'Jahr beenden',
        foregroundColor: colors.onSurface,
        backgroundColor: colors.surfaceContainerLow,
        focusColor: colors.onSurface.withOpacity(0.1),
        hoverColor: colors.onSurface.withOpacity(0.08),
        splashColor: colors.onSurface.withOpacity(0.1),
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 3,
        highlightElevation: 1,
        disabledElevation: 0,
        shape: getIconShape(context, iconSize, colors.outline, 3),
        onPressed: context.read<Game>().finishRound,
        child: Icon(FontAwesomeIcons.forward, size: iconSize),
      ),
    );
  }
}
