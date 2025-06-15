import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ResourceCounterWidget extends StatelessWidget {
  final int currentBudget;
  final int usedBudget;
  final bool isMultiplayer;
  final String opponentStrength;
  final String estimatedDuration;

  const ResourceCounterWidget({
    super.key,
    required this.currentBudget,
    required this.usedBudget,
    required this.isMultiplayer,
    required this.opponentStrength,
    required this.estimatedDuration,
  });

  Color _getBudgetColor() {
    final double percentage = usedBudget / currentBudget;
    if (percentage > 1.0) return AppTheme.darkTheme.colorScheme.error;
    if (percentage > 0.8) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  @override
  Widget build(BuildContext context) {
    final int remainingBudget = currentBudget - usedBudget;
    final double budgetPercentage =
        (usedBudget / currentBudget).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Budget section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'account_balance_wallet',
                          color: AppTheme.darkTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Army Budget',
                          style:
                              AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.darkTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Budget progress bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.surface
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: budgetPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getBudgetColor(),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Budget numbers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Used: \$$usedBudget',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getBudgetColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Remaining: \$$remainingBudget',
                          style: TextStyle(
                            fontSize: 12,
                            color: remainingBudget >= 0
                                ? AppTheme.darkTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7)
                                : AppTheme.darkTheme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16),

              // Total budget display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.darkTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Budget',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.darkTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$$currentBudget',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Multiplayer info section
          if (isMultiplayer) ...[
            SizedBox(height: 16),
            Divider(color: AppTheme.darkTheme.dividerColor),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Opponent Strength',
                    opponentStrength,
                    'shield',
                    _getStrengthColor(opponentStrength),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Est. Duration',
                    estimatedDuration,
                    'schedule',
                    AppTheme.darkTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.darkTheme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.darkTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'low':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'high':
        return AppTheme.darkTheme.colorScheme.error;
      default:
        return AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }
}
