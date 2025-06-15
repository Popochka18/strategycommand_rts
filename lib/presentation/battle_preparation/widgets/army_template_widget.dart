import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class ArmyTemplateWidget extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onLoadTemplate;

  const ArmyTemplateWidget({
    super.key,
    required this.template,
    required this.onLoadTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> units = template["units"] as List<dynamic>;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.darkTheme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Template info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  template["name"],
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  template["description"],
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Unit composition preview
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'groups',
                      color: AppTheme.darkTheme.colorScheme.primary,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${units.length} unit types',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.darkTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12),

          // Unit icons preview
          SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: units.take(3).map((unit) {
                    return Container(
                      width: 16,
                      height: 16,
                      margin: EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: _getUnitTypeColor(unit["unitId"]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          '${unit["count"]}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (units.length > 3) ...[
                  SizedBox(height: 2),
                  Text(
                    '+${units.length - 3} more',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppTheme.darkTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 12),

          // Load button
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onLoadTemplate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkTheme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Load',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUnitTypeColor(int unitId) {
    // Simple color mapping based on unit ID
    switch (unitId) {
      case 1: // Infantry
        return AppTheme.darkTheme.colorScheme.secondary;
      case 2: // Archer
        return AppTheme.accentColor;
      case 3: // Cavalry
        return AppTheme.darkTheme.colorScheme.primary;
      case 4: // Mage
        return Colors.purple;
      case 5: // Siege Engine
        return Colors.red;
      case 6: // Scout
        return Colors.cyan;
      default:
        return AppTheme.darkTheme.colorScheme.onSurface;
    }
  }
}
