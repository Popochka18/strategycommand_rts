import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class GestureHintWidget extends StatelessWidget {
  final String gestureType;
  final Animation<double> animation;

  const GestureHintWidget({
    super.key,
    required this.gestureType,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.4 * animation.value),
          child: Opacity(
            opacity: 0.6 + (0.4 * (1.0 - animation.value)),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.accentColor,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: _getGestureIcon(gestureType),
                    color: AppTheme.accentColor,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getGestureText(gestureType),
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGestureIcon(String gestureType) {
    switch (gestureType) {
      case "tap":
        return "touch_app";
      case "drag":
        return "drag_indicator";
      case "pinch":
        return "zoom_out_map";
      default:
        return "touch_app";
    }
  }

  String _getGestureText(String gestureType) {
    switch (gestureType) {
      case "tap":
        return "TAP";
      case "drag":
        return "DRAG";
      case "pinch":
        return "PINCH";
      default:
        return "TAP";
    }
  }
}
