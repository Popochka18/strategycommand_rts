import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResearchFilterWidget extends StatelessWidget {
  final String selectedCategory;
  final bool showOnlyAvailable;
  final Function(String) onCategoryChanged;
  final VoidCallback onAvailableToggle;

  const ResearchFilterWidget({
    super.key,
    required this.selectedCategory,
    required this.showOnlyAvailable,
    required this.onCategoryChanged,
    required this.onAvailableToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'All',
        'icon': 'apps',
        'color': AppTheme.darkTheme.colorScheme.primary
      },
      {
        'name': 'Military',
        'icon': 'military_tech',
        'color': const Color(0xFFE53E3E)
      },
      {
        'name': 'Economic',
        'icon': 'account_balance',
        'color': const Color(0xFF38A169)
      },
      {
        'name': 'Diplomatic',
        'icon': 'handshake',
        'color': const Color(0xFF3182CE)
      },
      {
        'name': 'Magical',
        'icon': 'auto_fix_high',
        'color': const Color(0xFF805AD5)
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filters
          Row(
            children: [
              Text(
                'Categories:',
                style: AppTheme.darkTheme.textTheme.labelLarge,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category['name'];
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: GestureDetector(
                          onTap: () =>
                              onCategoryChanged(category['name'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (category['color'] as Color)
                                      .withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (category['color'] as Color)
                                    : AppTheme.darkTheme.dividerColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: category['icon'] as String,
                                  color: isSelected
                                      ? (category['color'] as Color)
                                      : AppTheme
                                          .darkTheme.colorScheme.onSurface,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  category['name'] as String,
                                  style: AppTheme
                                      .darkTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: isSelected
                                        ? (category['color'] as Color)
                                        : AppTheme
                                            .darkTheme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Additional Filters
          Row(
            children: [
              // Available Only Toggle
              GestureDetector(
                onTap: onAvailableToggle,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: showOnlyAvailable
                        ? AppTheme.successColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: showOnlyAvailable
                          ? AppTheme.successColor
                          : AppTheme.darkTheme.dividerColor,
                      width: showOnlyAvailable ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: showOnlyAvailable
                            ? 'check_circle'
                            : 'radio_button_unchecked',
                        color: showOnlyAvailable
                            ? AppTheme.successColor
                            : AppTheme.darkTheme.colorScheme.onSurface,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Available Only',
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: showOnlyAvailable
                              ? AppTheme.successColor
                              : AppTheme.darkTheme.colorScheme.onSurface,
                          fontWeight: showOnlyAvailable
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Quick Stats
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.darkTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Available', '3', AppTheme.successColor),
                      Container(
                        width: 1,
                        height: 20,
                        color: AppTheme.darkTheme.dividerColor,
                      ),
                      _buildStatItem('Researching', '2', AppTheme.accentColor),
                      Container(
                        width: 1,
                        height: 20,
                        color: AppTheme.darkTheme.dividerColor,
                      ),
                      _buildStatItem('Completed', '1',
                          AppTheme.darkTheme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
            color:
                AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
