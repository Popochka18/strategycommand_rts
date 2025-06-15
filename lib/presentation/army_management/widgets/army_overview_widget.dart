import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ArmyOverviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> units;

  const ArmyOverviewWidget({
    super.key,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final totalUnits = units.length;
    final totalPower =
        units.fold<int>(0, (sum, unit) => sum + (unit["powerRating"] as int));
    final totalMaintenance = units.fold<int>(
        0, (sum, unit) => sum + (unit["maintenanceCost"] as int));
    final upgradeableUnits =
        units.where((unit) => unit["canUpgrade"] as bool).length;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'military_tech',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Army Overview',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Units',
                  totalUnits.toString(),
                  'groups',
                  AppTheme.darkTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  'Total Power',
                  _formatNumber(totalPower),
                  'flash_on',
                  AppTheme.darkTheme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Maintenance',
                  '\$${_formatNumber(totalMaintenance)}',
                  'attach_money',
                  AppTheme.warningColor,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  'Upgradeable',
                  upgradeableUnits.toString(),
                  'upgrade',
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          if (upgradeableUnits > 0) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.successColor,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      '$upgradeableUnits units ready for upgrade',
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
                size: 20,
              ),
              Spacer(),
              Text(
                value,
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
