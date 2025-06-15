import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UnitCardWidget extends StatefulWidget {
  final Map<String, dynamic> unit;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onUpgrade;
  final Function(String) onEquip;
  final Function(String) onDismiss;
  final Function(String) onToggleFavorite;

  const UnitCardWidget({
    super.key,
    required this.unit,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onUpgrade,
    required this.onEquip,
    required this.onDismiss,
    required this.onToggleFavorite,
  });

  @override
  State<UnitCardWidget> createState() => _UnitCardWidgetState();
}

class _UnitCardWidgetState extends State<UnitCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Dismissible(
        key: Key(widget.unit["id"] as String),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomIconWidget(
                iconName: 'upgrade',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'build',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'delete',
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showActionDialog();
        },
        child: GestureDetector(
          onTap: widget.isSelectionMode ? widget.onTap : _toggleExpanded,
          onLongPress: widget.onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppTheme.darkTheme.colorScheme.primary
                      .withValues(alpha: 0.2)
                  : AppTheme.darkTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected
                  ? Border.all(
                      color: AppTheme.darkTheme.colorScheme.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkTheme.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMainCard(),
                AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: child,
                    );
                  },
                  child: _buildExpandedContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    final unit = widget.unit;
    final healthPercent = (unit["health"] as int) / (unit["maxHealth"] as int);
    final levelPercent = (unit["level"] as int) / (unit["maxLevel"] as int);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          // Unit Portrait
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CustomImageWidget(
                imageUrl: unit["portrait"] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 4.w),

          // Unit Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        unit["name"] as String,
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit["isFavorite"] as bool)
                      CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.darkTheme.colorScheme.tertiary,
                        size: 16,
                      ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () =>
                          widget.onToggleFavorite(unit["id"] as String),
                      child: CustomIconWidget(
                        iconName: (unit["isFavorite"] as bool)
                            ? 'star'
                            : 'star_border',
                        color: AppTheme.darkTheme.colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.secondary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit["type"] as String,
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Lv. ${unit["level"]}/${unit["maxLevel"]}',
                      style: AppTheme.darkTheme.textTheme.labelMedium,
                    ),
                    Spacer(),
                    Text(
                      'Power: ${unit["powerRating"]}',
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                // Stats with Progress Bars
                _buildStatBar('Health', unit["health"] as int,
                    unit["maxHealth"] as int, AppTheme.successColor),
                SizedBox(height: 0.5.h),
                _buildStatBar(
                    'Level',
                    unit["level"] as int,
                    unit["maxLevel"] as int,
                    AppTheme.darkTheme.colorScheme.primary),
              ],
            ),
          ),

          // Expand/Selection Indicator
          widget.isSelectionMode
              ? CustomIconWidget(
                  iconName: widget.isSelected
                      ? 'check_circle'
                      : 'radio_button_unchecked',
                  color: widget.isSelected
                      ? AppTheme.darkTheme.colorScheme.primary
                      : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                )
              : CustomIconWidget(
                  iconName: _isExpanded ? 'expand_less' : 'expand_more',
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int current, int max, Color color) {
    final percent = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.labelSmall,
            ),
            Text(
              '$current/$max',
              style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Container(
          height: 0.5.h,
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.outline,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    final unit = widget.unit;
    final upgradeCost = unit["upgradeCost"] as Map<String, dynamic>;
    final equipment = unit["equipment"] as Map<String, dynamic>;
    final abilities = unit["abilities"] as List<dynamic>;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.darkTheme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combat Stats
          Text(
            'Combat Statistics',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    'Attack', unit["attack"].toString(), 'sword'),
              ),
              Expanded(
                child: _buildStatItem(
                    'Defense', unit["defense"].toString(), 'shield'),
              ),
              Expanded(
                child: _buildStatItem('Maintenance',
                    '\$${unit["maintenanceCost"]}', 'attach_money'),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Abilities
          Text(
            'Abilities',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: abilities
                .map((ability) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.darkTheme.colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        ability as String,
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),

          SizedBox(height: 2.h),

          // Equipment
          Text(
            'Equipment',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          Column(
            children: equipment.entries
                .map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: _getEquipmentIcon(entry.key),
                            color: AppTheme.darkTheme.colorScheme.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${entry.key.toUpperCase()}:',
                            style: AppTheme.darkTheme.textTheme.labelMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              entry.value as String,
                              style: AppTheme.darkTheme.textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),

          SizedBox(height: 2.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (unit["canUpgrade"] as bool)
                      ? () => _showUpgradeDialog()
                      : null,
                  icon: CustomIconWidget(
                    iconName: 'upgrade',
                    color: (unit["canUpgrade"] as bool)
                        ? AppTheme.darkTheme.elevatedButtonTheme.style
                            ?.foregroundColor
                            ?.resolve({})
                        : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  label: Text('Upgrade'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onEquip(unit["id"] as String),
                  icon: CustomIconWidget(
                    iconName: 'build',
                    color: AppTheme
                        .darkTheme.outlinedButtonTheme.style?.foregroundColor
                        ?.resolve({}),
                    size: 16,
                  ),
                  label: Text('Equip'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.darkTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.labelSmall,
        ),
      ],
    );
  }

  String _getEquipmentIcon(String equipmentType) {
    switch (equipmentType.toLowerCase()) {
      case 'weapon':
        return 'sword';
      case 'armor':
        return 'shield';
      case 'accessory':
        return 'diamond';
      default:
        return 'build';
    }
  }

  Future<bool?> _showActionDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.dialogBackgroundColor,
        title: Text(
          'Unit Actions',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Choose an action for ${widget.unit["name"]}',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
              widget.onUpgrade(widget.unit["id"] as String);
            },
            icon: CustomIconWidget(
              iconName: 'upgrade',
              color: AppTheme.darkTheme.colorScheme.primary,
              size: 16,
            ),
            label: Text('Upgrade'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
              widget.onEquip(widget.unit["id"] as String);
            },
            icon: CustomIconWidget(
              iconName: 'build',
              color: AppTheme.darkTheme.colorScheme.secondary,
              size: 16,
            ),
            label: Text('Equip'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
              widget.onDismiss(widget.unit["id"] as String);
            },
            icon: CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.darkTheme.colorScheme.error,
              size: 16,
            ),
            label: Text('Dismiss'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    final unit = widget.unit;
    final upgradeCost = unit["upgradeCost"] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.dialogBackgroundColor,
        title: Text(
          'Upgrade ${unit["name"]}',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level ${unit["level"]} → ${(unit["level"] as int) + 1}',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Upgrade Cost:',
              style: AppTheme.darkTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),
            ...upgradeCost.entries
                .map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: _getResourceIcon(entry.key),
                            color: AppTheme.darkTheme.colorScheme.tertiary,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${entry.key.toUpperCase()}: ${entry.value}',
                            style: AppTheme.darkTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ))
                ,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onUpgrade(unit["id"] as String);
            },
            child: Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  String _getResourceIcon(String resourceType) {
    switch (resourceType.toLowerCase()) {
      case 'gold':
        return 'attach_money';
      case 'iron':
        return 'build';
      case 'gems':
        return 'diamond';
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
