import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResearchHeaderWidget extends StatelessWidget {
  final int availablePoints;
  final int activeResearchCount;

  const ResearchHeaderWidget({
    super.key,
    required this.availablePoints,
    required this.activeResearchCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Research Points Display
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.darkTheme.colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'science',
                    color: AppTheme.darkTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Research Points',
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color:
                              AppTheme.darkTheme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        availablePoints.toString(),
                        style:
                            AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Active Research Display
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.darkTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'hourglass_empty',
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Active Research',
                        style: AppTheme.darkTheme.textTheme.labelMedium,
                      ),
                      Text(
                        '$activeResearchCount/5',
                        style:
                            AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Quick Actions
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showAutoResearchDialog(context),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomIconWidget(
                      iconName: 'auto_mode',
                      color: AppTheme.darkTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Auto',
                  style: AppTheme.darkTheme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAutoResearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.dialogBackgroundColor,
        title: Text(
          'Auto Research',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enable automatic research suggestions based on your current strategy?',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.darkTheme.colorScheme.primary
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Path:',
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '1. Basic Infantry Training\n2. Resource Management\n3. Advanced Weaponry',
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.darkTheme.colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement auto research logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkTheme.colorScheme.primary,
            ),
            child: Text(
              'Enable',
              style: TextStyle(color: AppTheme.darkTheme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
