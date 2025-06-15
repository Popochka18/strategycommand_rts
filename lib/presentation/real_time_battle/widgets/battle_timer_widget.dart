import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BattleTimerWidget extends StatelessWidget {
  final int currentTime;
  final int timeLimit;

  const BattleTimerWidget({
    super.key,
    required this.currentTime,
    required this.timeLimit,
  });

  @override
  Widget build(BuildContext context) {
    final remainingTime = timeLimit - currentTime;
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    final progress = currentTime / timeLimit;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'timer',
              color: remainingTime < 300
                  ? AppTheme.darkTheme.colorScheme.error
                  : AppTheme.darkTheme.colorScheme.onSurface,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: AppTheme.dataTextStyle(
                isLight: false,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ).copyWith(
                color: remainingTime < 300
                    ? AppTheme.darkTheme.colorScheme.error
                    : AppTheme.darkTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 15.w,
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.darkTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  remainingTime < 300
                      ? AppTheme.darkTheme.colorScheme.error
                      : AppTheme.darkTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
