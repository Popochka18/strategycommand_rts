import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> selectedUnits;
  final String currentAction;
  final Function(String) onActionSelected;

  const ActionButtonsWidget({
    super.key,
    required this.selectedUnits,
    required this.currentAction,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedUnits.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton('Move', 'directions_run', 'move'),
          _buildActionButton('Attack', 'gps_fixed', 'attack'),
          _buildActionButton('Defend', 'shield', 'defend'),
          _buildActionButton('Special', 'flash_on', 'special'),
          _buildActionButton('Retreat', 'keyboard_return', 'retreat'),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String iconName, String action) {
    final isSelected = currentAction == action;

    return GestureDetector(
      onTap: () {
        onActionSelected(action);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppTheme.darkTheme.colorScheme.primary)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.onSurface,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.darkTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
