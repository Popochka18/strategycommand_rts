import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ResearchNodeWidget extends StatelessWidget {
  final Map<String, dynamic> node;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController progressAnimation;

  const ResearchNodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = node['isUnlocked'] as bool;
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final progress = node['progress'] as double;

    Color nodeColor;
    Color borderColor;

    if (isCompleted) {
      nodeColor = AppTheme.successColor;
      borderColor = AppTheme.successColor;
    } else if (isResearching) {
      nodeColor = AppTheme.darkTheme.colorScheme.primary;
      borderColor = AppTheme.darkTheme.colorScheme.primary;
    } else if (isUnlocked) {
      nodeColor = AppTheme.darkTheme.colorScheme.surface;
      borderColor = AppTheme.darkTheme.colorScheme.primary;
    } else {
      nodeColor = AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.3);
      borderColor =
          AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        // Show research path highlighting
        _showResearchPath(context);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: nodeColor,
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : borderColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isSelected || isResearching)
              BoxShadow(
                color: (isSelected ? AppTheme.accentColor : borderColor)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Main icon
            Center(
              child: CustomIconWidget(
                iconName: node['icon'] as String,
                color: isUnlocked
                    ? AppTheme.darkTheme.colorScheme.onSurface
                    : AppTheme.darkTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                size: 24,
              ),
            ),

            // Progress ring for researching nodes
            if (isResearching && progress > 0)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: progressAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ProgressRingPainter(
                        progress: progress,
                        color: AppTheme.darkTheme.colorScheme.primary,
                        animationValue: progressAnimation.value,
                      ),
                    );
                  },
                ),
              ),

            // Completion checkmark
            if (isCompleted)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.successColor,
                    border: Border.all(
                      color: AppTheme.darkTheme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),

            // Lock icon for locked nodes
            if (!isUnlocked)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.darkTheme.colorScheme.surface,
                    border: Border.all(
                      color: AppTheme.darkTheme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: AppTheme.darkTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showResearchPath(BuildContext context) {
    // Show tooltip with research path information
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 10.h,
        left: 5.w,
        right: 5.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Research Path',
                      style: AppTheme.darkTheme.textTheme.titleMedium,
                    ),
                    GestureDetector(
                      onTap: () => overlayEntry.remove(),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.darkTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Prerequisites: ${(node['prerequisites'] as List).isEmpty ? 'None' : (node['prerequisites'] as List).join(', ')}',
                  style: AppTheme.darkTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  'This research unlocks advanced technologies in the ${node['category']} branch.',
                  style: AppTheme.darkTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double animationValue;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background ring
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Animated glow effect
    if (animationValue > 0.5) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3 * (1 - animationValue))
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}