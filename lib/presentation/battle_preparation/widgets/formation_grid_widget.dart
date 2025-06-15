import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class FormationGridWidget extends StatefulWidget {
  final List<Map<String, dynamic>> deployedUnits;
  final List<Map<String, dynamic>> availableUnits;
  final Function(int) onRemoveUnit;

  const FormationGridWidget({
    super.key,
    required this.deployedUnits,
    required this.availableUnits,
    required this.onRemoveUnit,
  });

  @override
  State<FormationGridWidget> createState() => _FormationGridWidgetState();
}

class _FormationGridWidgetState extends State<FormationGridWidget> {
  static const int gridRows = 4;
  static const int gridCols = 4;

  Map<String, dynamic>? _getUnitAtPosition(int row, int col) {
    for (var deployedUnit in widget.deployedUnits) {
      final position = deployedUnit["position"] as List;
      if (position[0] == col && position[1] == row) {
        return deployedUnit;
      }
    }
    return null;
  }

  Map<String, dynamic>? _getUnitData(int unitId) {
    try {
      return widget.availableUnits.firstWhere((unit) => unit["id"] == unitId);
    } catch (e) {
      return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Battlefield minimap indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.darkTheme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'map',
                  color: AppTheme.darkTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Battlefield Preview',
                  style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.darkTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Formation grid
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.surface
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.darkTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCols,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: gridRows * gridCols,
                  itemBuilder: (context, index) {
                    final row = index ~/ gridCols;
                    final col = index % gridCols;
                    final deployedUnit = _getUnitAtPosition(row, col);

                    return _buildGridCell(row, col, deployedUnit);
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Tactical advantage indicators
          if (widget.deployedUnits.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formation Analysis',
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAdvantageIndicator(
                          'Offense', _calculateOffensiveStrength(), Colors.red),
                      SizedBox(width: 16),
                      _buildAdvantageIndicator('Defense',
                          _calculateDefensiveStrength(), Colors.blue),
                      SizedBox(width: 16),
                      _buildAdvantageIndicator(
                          'Mobility', _calculateMobility(), Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridCell(int row, int col, Map<String, dynamic>? deployedUnit) {
    final bool isEmpty = deployedUnit == null;
    final bool isFrontLine = row == 0;
    final bool isBackLine = row == gridRows - 1;

    return GestureDetector(
      onTap: isEmpty
          ? null
          : () {
              _showUnitOptions(deployedUnit);
            },
      onLongPress: isEmpty
          ? null
          : () {
              HapticFeedback.mediumImpact();
              widget.onRemoveUnit(deployedUnit["unitId"]);
            },
      child: Container(
        decoration: BoxDecoration(
          color: isEmpty
              ? (isFrontLine
                  ? AppTheme.darkTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : isBackLine
                      ? AppTheme.darkTheme.colorScheme.secondary
                          .withValues(alpha: 0.1)
                      : AppTheme.darkTheme.colorScheme.surface
                          .withValues(alpha: 0.05))
              : AppTheme.darkTheme.cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEmpty
                ? AppTheme.darkTheme.dividerColor.withValues(alpha: 0.3)
                : AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.5),
            width: isEmpty ? 1 : 2,
          ),
        ),
        child: isEmpty
            ? Center(
                child: CustomIconWidget(
                  iconName: isFrontLine
                      ? 'shield'
                      : isBackLine
                          ? 'support'
                          : 'add',
                  color: AppTheme.darkTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
                  size: 16,
                ),
              )
            : _buildDeployedUnitCell(deployedUnit),
      ),
    );
  }

  Widget _buildDeployedUnitCell(Map<String, dynamic> deployedUnit) {
    final unitData = _getUnitData(deployedUnit["unitId"]);
    if (unitData == null) return Container();

    final int count = deployedUnit["count"];
    final String type = unitData["type"];

    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomImageWidget(
                imageUrl: unitData["image"],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _getTypeColor(type).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              count > 1
                  ? '${count}x'
                  : unitData["name"].substring(0, 3).toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantageIndicator(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateOffensiveStrength() {
    if (widget.deployedUnits.isEmpty) return "Low";

    int totalAttack = 0;
    for (var deployedUnit in widget.deployedUnits) {
      final unitData = _getUnitData(deployedUnit["unitId"]);
      if (unitData != null) {
        totalAttack +=
            (unitData["attack"] as int) * (deployedUnit["count"] as int);
      }
    }

    if (totalAttack > 200) return "High";
    if (totalAttack > 100) return "Medium";
    return "Low";
  }

  String _calculateDefensiveStrength() {
    if (widget.deployedUnits.isEmpty) return "Low";

    int totalDefense = 0;
    for (var deployedUnit in widget.deployedUnits) {
      final unitData = _getUnitData(deployedUnit["unitId"]);
      if (unitData != null) {
        totalDefense +=
            (unitData["defense"] as int) * (deployedUnit["count"] as int);
      }
    }

    if (totalDefense > 100) return "High";
    if (totalDefense > 50) return "Medium";
    return "Low";
  }

  String _calculateMobility() {
    if (widget.deployedUnits.isEmpty) return "Low";

    double avgSpeed = 0;
    int totalUnits = 0;

    for (var deployedUnit in widget.deployedUnits) {
      final unitData = _getUnitData(deployedUnit["unitId"]);
      if (unitData != null) {
        final count = deployedUnit["count"] as int;
        avgSpeed += (unitData["speed"] as int) * count;
        totalUnits += count;
      }
    }

    if (totalUnits > 0) {
      avgSpeed /= totalUnits;
      if (avgSpeed > 4) return "High";
      if (avgSpeed > 2) return "Medium";
    }

    return "Low";
  }

  void _showUnitOptions(Map<String, dynamic> deployedUnit) {
    final unitData = _getUnitData(deployedUnit["unitId"]);
    if (unitData == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.bottomSheetTheme.backgroundColor,
      shape: AppTheme.darkTheme.bottomSheetTheme.shape,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: unitData["image"],
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unitData["name"],
                          style: AppTheme.darkTheme.textTheme.titleMedium,
                        ),
                        Text(
                          'Count: ${deployedUnit["count"]}',
                          style: AppTheme.darkTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to upgrade screen
                        Navigator.pushNamed(context, '/army-management');
                      },
                      icon: CustomIconWidget(
                        iconName: 'upgrade',
                        color: AppTheme.darkTheme.colorScheme.primary,
                        size: 18,
                      ),
                      label: Text('Upgrade'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onRemoveUnit(deployedUnit["unitId"]);
                      },
                      icon: CustomIconWidget(
                        iconName: 'remove_circle',
                        color: AppTheme.darkTheme.colorScheme.onError,
                        size: 18,
                      ),
                      label: Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
