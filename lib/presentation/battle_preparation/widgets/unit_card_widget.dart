import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class UnitCardWidget extends StatefulWidget {
  final Map<String, dynamic> unit;
  final Function(Map<String, dynamic>, int) onAddToFormation;
  final int currentBudget;
  final int usedBudget;

  const UnitCardWidget({
    super.key,
    required this.unit,
    required this.onAddToFormation,
    required this.currentBudget,
    required this.usedBudget,
  });

  @override
  State<UnitCardWidget> createState() => _UnitCardWidgetState();
}

class _UnitCardWidgetState extends State<UnitCardWidget> {
  bool _isExpanded = false;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'ground':
        return AppTheme.darkTheme.colorScheme.secondary;
      case 'ranged':
        return AppTheme.accentColor;
      case 'mounted':
        return AppTheme.darkTheme.colorScheme.primary;
      case 'magic':
        return Colors.purple;
      case 'siege':
        return Colors.red;
      case 'support':
        return Colors.cyan;
      default:
        return AppTheme.darkTheme.colorScheme.onSurface;
    }
  }

  bool _canAfford() {
    return (widget.usedBudget + (widget.unit["cost"] as int)) <=
        widget.currentBudget;
  }

  @override
  Widget build(BuildContext context) {
    final bool canAfford = _canAfford();
    final int availableCount = widget.unit["count"] as int;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        color: AppTheme.darkTheme.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: canAfford
                ? _getTypeColor(widget.unit["type"]).withValues(alpha: 0.3)
                : AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          onLongPress: canAfford && availableCount > 0
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onAddToFormation(widget.unit, 1);
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main unit info
                Row(
                  children: [
                    // Unit image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CustomImageWidget(
                        imageUrl: widget.unit["image"],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),

                    // Unit details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.unit["name"],
                                style: AppTheme.darkTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color: canAfford
                                      ? AppTheme.darkTheme.colorScheme.onSurface
                                      : AppTheme.darkTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(widget.unit["type"])
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.unit["type"],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getTypeColor(widget.unit["type"]),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'attach_money',
                                color: canAfford
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                                size: 14,
                              ),
                              Text(
                                '\$${widget.unit["cost"]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: canAfford
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 16),
                              CustomIconWidget(
                                iconName: 'inventory',
                                color: AppTheme.darkTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                size: 14,
                              ),
                              Text(
                                ' $availableCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme
                                      .darkTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Add button
                    IconButton(
                      onPressed: canAfford && availableCount > 0
                          ? () {
                              widget.onAddToFormation(widget.unit, 1);
                            }
                          : null,
                      icon: CustomIconWidget(
                        iconName: 'add_circle',
                        color: canAfford && availableCount > 0
                            ? AppTheme.darkTheme.colorScheme.primary
                            : AppTheme.darkTheme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                        size: 24,
                      ),
                    ),
                  ],
                ),

                // Expanded details
                if (_isExpanded) ...[
                  SizedBox(height: 12),
                  Divider(color: AppTheme.darkTheme.dividerColor),
                  SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(
                          'HP', widget.unit["health"].toString(), Colors.green),
                      SizedBox(width: 8),
                      _buildStatChip(
                          'ATK', widget.unit["attack"].toString(), Colors.red),
                      SizedBox(width: 8),
                      _buildStatChip('DEF', widget.unit["defense"].toString(),
                          Colors.blue),
                      SizedBox(width: 8),
                      _buildStatChip('SPD', widget.unit["speed"].toString(),
                          Colors.orange),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Special ability
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'auto_awesome',
                        color: AppTheme.accentColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        widget.unit["special"],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Range: ${widget.unit["range"]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Description
                  Text(
                    widget.unit["description"],
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.darkTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
