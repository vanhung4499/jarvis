import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingAnimationWidget.halfTriangleDot(
          color: customColors.backgroundInvertedColor ?? Colors.white,
          size: 70,
        ),
        const SizedBox(height: 10),
        Text(
          message ?? "Loading，please wait...",
          style: TextStyle(
            color: customColors.backgroundInvertedColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
