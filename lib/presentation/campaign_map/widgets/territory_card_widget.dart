import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class TerritoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> territory;
  final VoidCallback onTap;

  const TerritoryCardWidget({
    super.key,
    required this.territory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: territory['color'] as Color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: territory['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      territory['name'],
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${territory['garrisonStrength']}%',
                    style: AppTheme.darkTheme.textTheme.labelSmall,
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'monetization_on',
                    color: AppTheme.darkTheme.colorScheme.tertiary,
                    size: 12,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '+${(territory['resourceIncome'] as Map<String, dynamic>).values.fold(0, (sum, value) => sum + (value as int))}',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: territory['status'] == 'controlled'
                      ? AppTheme.successColor.withValues(alpha: 0.2)
                      : territory['status'] == 'enemy'
                          ? AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.2)
                          : AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  territory['status'].toString().toUpperCase(),
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: territory['status'] == 'controlled'
                        ? AppTheme.successColor
                        : territory['status'] == 'enemy'
                            ? AppTheme.darkTheme.colorScheme.error
                            : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}