import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'name': 'All', 'icon': 'select_all'},
      {'name': 'Infantry', 'icon': 'person'},
      {'name': 'Magic', 'icon': 'auto_awesome'},
      {'name': 'Stealth', 'icon': 'visibility_off'},
      {'name': 'Ranged', 'icon': 'my_location'},
      {'name': 'Cavalry', 'icon': 'directions_run'},
      {'name': 'Upgradeable', 'icon': 'upgrade'},
      {'name': 'Favorites', 'icon': 'star'},
    ];

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['name'];

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: filter['icon']!,
                    color: isSelected
                        ? AppTheme.darkTheme.colorScheme.onPrimary
                        : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    filter['name']!,
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.darkTheme.colorScheme.onPrimary
                          : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                onFilterChanged(filter['name']!);
              },
              backgroundColor: AppTheme.darkTheme.colorScheme.surface,
              selectedColor: AppTheme.darkTheme.colorScheme.primary,
              checkmarkColor: AppTheme.darkTheme.colorScheme.onPrimary,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.darkTheme.colorScheme.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
    );
  }
}
