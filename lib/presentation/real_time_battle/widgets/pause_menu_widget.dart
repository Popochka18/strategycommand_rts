import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PauseMenuWidget extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onSettings;
  final VoidCallback onExit;

  const PauseMenuWidget({
    super.key,
    required this.onResume,
    required this.onSettings,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.darkTheme.scaffoldBackgroundColor.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 80.w,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Paused',
                style: AppTheme.darkTheme.textTheme.headlineSmall,
              ),
              SizedBox(height: 32),
              _buildMenuButton(
                'Resume Battle',
                'play_arrow',
                onResume,
                AppTheme.darkTheme.colorScheme.primary,
              ),
              SizedBox(height: 16),
              _buildMenuButton(
                'Settings',
                'settings',
                onSettings,
                AppTheme.darkTheme.colorScheme.onSurface,
              ),
              SizedBox(height: 16),
              _buildMenuButton(
                'Exit Battle',
                'exit_to_app',
                onExit,
                AppTheme.darkTheme.colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      String text, String iconName, VoidCallback onTap, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              text,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
