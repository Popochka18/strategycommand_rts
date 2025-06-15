import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResearchDetailSheet extends StatelessWidget {
  final Map<String, dynamic> node;
  final Function(String) onStartResearch;
  final int availablePoints;

  const ResearchDetailSheet({
    super.key,
    required this.node,
    required this.onStartResearch,
    required this.availablePoints,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = node['isUnlocked'] as bool;
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final cost = node['cost'] as int;
    final duration = node['duration'] as int;
    final benefits = node['benefits'] as List;
    final prerequisites = node['prerequisites'] as List;

    final canAfford = availablePoints >= cost;
    final canStart = isUnlocked && !isCompleted && !isResearching && canAfford;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getNodeColor(),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getBorderColor(),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: node['icon'] as String,
                                color: AppTheme.darkTheme.colorScheme.onSurface,
                                size: 28,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  node['name'] as String,
                                  style: AppTheme
                                      .darkTheme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor()
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getCategoryColor(),
                                    ),
                                  ),
                                  child: Text(
                                    node['category'] as String,
                                    style: AppTheme
                                        .darkTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: _getCategoryColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getStatusColor()),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: _getStatusIcon(),
                              color: _getStatusColor(),
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _getStatusText(),
                              style: AppTheme.darkTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: _getStatusColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Description
                      Text(
                        'Description',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        node['description'] as String,
                        style: AppTheme.darkTheme.textTheme.bodyMedium,
                      ),

                      SizedBox(height: 3.h),

                      // Research Cost & Duration
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Cost',
                              cost.toString(),
                              'science',
                              canAfford
                                  ? AppTheme.successColor
                                  : AppTheme.darkTheme.colorScheme.error,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildInfoCard(
                              'Duration',
                              _formatDuration(duration),
                              'schedule',
                              AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Prerequisites
                      if (prerequisites.isNotEmpty) ...[
                        Text(
                          'Prerequisites',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.darkTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.darkTheme.dividerColor,
                            ),
                          ),
                          child: Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: prerequisites.map((prereq) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme
                                      .darkTheme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  prereq as String,
                                  style: AppTheme.darkTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.darkTheme.colorScheme.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],

                      // Benefits
                      Text(
                        'Benefits',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.successColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: benefits.map((benefit) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: AppTheme.successColor,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      benefit as String,
                                      style: AppTheme
                                          .darkTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .darkTheme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.darkTheme.dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: canStart
                            ? () => onStartResearch(node['id'] as String)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canStart
                              ? AppTheme.darkTheme.colorScheme.primary
                              : AppTheme.darkTheme.colorScheme.surface,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child: Text(
                          _getActionButtonText(),
                          style: TextStyle(
                            color: canStart
                                ? AppTheme.darkTheme.colorScheme.onPrimary
                                : AppTheme.darkTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, String icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor() {
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final isUnlocked = node['isUnlocked'] as bool;

    if (isCompleted) return AppTheme.successColor;
    if (isResearching) return AppTheme.darkTheme.colorScheme.primary;
    if (isUnlocked) return AppTheme.darkTheme.colorScheme.surface;
    return AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.3);
  }

  Color _getBorderColor() {
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final isUnlocked = node['isUnlocked'] as bool;

    if (isCompleted) return AppTheme.successColor;
    if (isResearching) return AppTheme.darkTheme.colorScheme.primary;
    if (isUnlocked) return AppTheme.darkTheme.colorScheme.primary;
    return AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.3);
  }

  Color _getCategoryColor() {
    switch (node['category'] as String) {
      case 'Military':
        return const Color(0xFFE53E3E);
      case 'Economic':
        return const Color(0xFF38A169);
      case 'Diplomatic':
        return const Color(0xFF3182CE);
      case 'Magical':
        return const Color(0xFF805AD5);
      default:
        return AppTheme.darkTheme.colorScheme.primary;
    }
  }

  Color _getStatusColor() {
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final isUnlocked = node['isUnlocked'] as bool;

    if (isCompleted) return AppTheme.successColor;
    if (isResearching) return AppTheme.accentColor;
    if (isUnlocked) return AppTheme.darkTheme.colorScheme.primary;
    return AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.5);
  }

  String _getStatusIcon() {
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final isUnlocked = node['isUnlocked'] as bool;

    if (isCompleted) return 'check_circle';
    if (isResearching) return 'hourglass_empty';
    if (isUnlocked) return 'radio_button_unchecked';
    return 'lock';
  }

  String _getStatusText() {
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final isUnlocked = node['isUnlocked'] as bool;

    if (isCompleted) return 'Completed';
    if (isResearching) return 'Researching';
    if (isUnlocked) return 'Available';
    return 'Locked';
  }

  String _getActionButtonText() {
    final isCompleted = node['isCompleted'] as bool;
    final isResearching = node['isResearching'] as bool;
    final isUnlocked = node['isUnlocked'] as bool;
    final cost = node['cost'] as int;

    if (isCompleted) return 'Completed';
    if (isResearching) return 'Researching...';
    if (!isUnlocked) return 'Locked';
    if (availablePoints < cost) return 'Insufficient Points';
    return 'Start Research';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
