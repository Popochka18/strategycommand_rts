import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecruitmentDialogWidget extends StatefulWidget {
  final Function(String) onRecruit;

  const RecruitmentDialogWidget({
    super.key,
    required this.onRecruit,
  });

  @override
  State<RecruitmentDialogWidget> createState() =>
      _RecruitmentDialogWidgetState();
}

class _RecruitmentDialogWidgetState extends State<RecruitmentDialogWidget> {
  String? _selectedUnitType;

  // Mock data for available units to recruit
  final List<Map<String, dynamic>> _availableUnits = [
    {
      "type": "Infantry",
      "name": "Recruit Knight",
      "description": "Basic infantry unit with balanced stats",
      "cost": {"gold": 500, "iron": 25},
      "baseStats": {"health": 300, "attack": 45, "defense": 35},
      "icon": "person",
      "portrait":
          "https://images.pexels.com/photos/163036/mario-luigi-yoschi-figures-163036.jpeg"
    },
    {
      "type": "Magic",
      "name": "Apprentice Mage",
      "description": "Entry-level magic user with elemental spells",
      "cost": {"gold": 800, "mana": 50},
      "baseStats": {"health": 180, "attack": 65, "defense": 20},
      "icon": "auto_awesome",
      "portrait":
          "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg"
    },
    {
      "type": "Stealth",
      "name": "Scout Assassin",
      "description": "Fast and deadly stealth unit",
      "cost": {"gold": 750, "shadow": 30},
      "baseStats": {"health": 220, "attack": 70, "defense": 25},
      "icon": "visibility_off",
      "portrait":
          "https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg"
    },
    {
      "type": "Ranged",
      "name": "Archer",
      "description": "Long-range combat specialist",
      "cost": {"gold": 600, "wood": 40},
      "baseStats": {"health": 200, "attack": 55, "defense": 20},
      "icon": "my_location",
      "portrait":
          "https://images.pexels.com/photos/1040879/pexels-photo-1040879.jpeg"
    },
    {
      "type": "Cavalry",
      "name": "Mounted Warrior",
      "description": "Fast cavalry unit with charge attacks",
      "cost": {"gold": 1200, "meat": 30},
      "baseStats": {"health": 400, "attack": 60, "defense": 40},
      "icon": "directions_run",
      "portrait":
          "https://images.pexels.com/photos/1040878/pexels-photo-1040878.jpeg"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkTheme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'add_circle',
                    color: AppTheme.darkTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Recruit New Units',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Available Units List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(4.w),
                itemCount: _availableUnits.length,
                itemBuilder: (context, index) {
                  final unit = _availableUnits[index];
                  final isSelected = _selectedUnitType == unit["type"];

                  return Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUnitType =
                              isSelected ? null : unit["type"] as String;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.darkTheme.colorScheme.primary
                                  .withValues(alpha: 0.2)
                              : AppTheme.darkTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.darkTheme.colorScheme.primary
                                : AppTheme.darkTheme.colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Unit Portrait
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.darkTheme.colorScheme.outline,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: CustomImageWidget(
                                  imageUrl: unit["portrait"] as String,
                                  width: 12.w,
                                  height: 12.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            SizedBox(width: 3.w),

                            // Unit Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: unit["icon"] as String,
                                        color: AppTheme
                                            .darkTheme.colorScheme.primary,
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        unit["name"] as String,
                                        style: AppTheme
                                            .darkTheme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 0.5.h),

                                  Text(
                                    unit["description"] as String,
                                    style:
                                        AppTheme.darkTheme.textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 1.h),

                                  // Base Stats
                                  Row(
                                    children: [
                                      _buildStatChip(
                                          'HP',
                                          (unit["baseStats"] as Map)["health"]
                                              .toString()),
                                      SizedBox(width: 1.w),
                                      _buildStatChip(
                                          'ATK',
                                          (unit["baseStats"] as Map)["attack"]
                                              .toString()),
                                      SizedBox(width: 1.w),
                                      _buildStatChip(
                                          'DEF',
                                          (unit["baseStats"] as Map)["defense"]
                                              .toString()),
                                    ],
                                  ),

                                  SizedBox(height: 1.h),

                                  // Cost
                                  Row(
                                    children: (unit["cost"]
                                            as Map<String, dynamic>)
                                        .entries
                                        .map(
                                          (entry) => Container(
                                            margin: EdgeInsets.only(right: 2.w),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomIconWidget(
                                                  iconName: _getResourceIcon(
                                                      entry.key),
                                                  color: AppTheme.darkTheme
                                                      .colorScheme.tertiary,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 0.5.w),
                                                Text(
                                                  entry.value.toString(),
                                                  style: AppTheme.darkTheme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: AppTheme.darkTheme
                                                        .colorScheme.tertiary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),

                            // Selection Indicator
                            CustomIconWidget(
                              iconName: isSelected
                                  ? 'check_circle'
                                  : 'radio_button_unchecked',
                              color: isSelected
                                  ? AppTheme.darkTheme.colorScheme.primary
                                  : AppTheme
                                      .darkTheme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.darkTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedUnitType != null
                          ? () => widget.onRecruit(_selectedUnitType!)
                          : null,
                      child: Text('Recruit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
          color: AppTheme.darkTheme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getResourceIcon(String resourceType) {
    switch (resourceType.toLowerCase()) {
      case 'gold':
        return 'attach_money';
      case 'iron':
        return 'build';
      case 'mana':
        return 'auto_awesome';
      case 'shadow':
        return 'visibility_off';
      case 'wood':
        return 'park';
      case 'meat':
        return 'restaurant';
      default:
        return 'inventory';
    }
  }
}
