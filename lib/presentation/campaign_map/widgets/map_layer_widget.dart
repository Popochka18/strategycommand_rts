import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class MapLayerWidget extends StatefulWidget {
  final String layerType;
  final List<Map<String, dynamic>> territories;
  final Function(Map<String, dynamic>) onTerritoryTap;
  final Function(Map<String, dynamic>, Offset) onTerritoryLongPress;
  final TransformationController mapController;

  const MapLayerWidget({
    super.key,
    required this.layerType,
    required this.territories,
    required this.onTerritoryTap,
    required this.onTerritoryLongPress,
    required this.mapController,
  });

  @override
  State<MapLayerWidget> createState() => _MapLayerWidgetState();
}

class _MapLayerWidgetState extends State<MapLayerWidget> {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: widget.mapController,
      minScale: 0.5,
      maxScale: 3.0,
      constrained: false,
      child: Container(
        width: MediaQuery.of(context).size.width * 2,
        height: MediaQuery.of(context).size.height * 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkTheme.scaffoldBackgroundColor,
              AppTheme.darkTheme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: CustomPaint(
          painter: MapPainter(
            territories: widget.territories,
            layerType: widget.layerType,
            onTerritoryTap: widget.onTerritoryTap,
            onTerritoryLongPress: widget.onTerritoryLongPress,
          ),
          child: Stack(
            children: widget.territories.map((territory) {
              final position = territory['position'] as Map<String, double>;
              return Positioned(
                left:
                    MediaQuery.of(context).size.width * 2 * position['x']! - 40,
                top: MediaQuery.of(context).size.height * 2 * position['y']! -
                    40,
                child: GestureDetector(
                  onTap: () => widget.onTerritoryTap(territory),
                  onLongPressStart: (details) => widget.onTerritoryLongPress(
                    territory,
                    details.globalPosition,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          _getTerritoryColor(territory).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getTerritoryColor(territory),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: _buildTerritoryIcon(territory),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getTerritoryColor(Map<String, dynamic> territory) {
    switch (widget.layerType) {
      case 'political':
        return territory['color'] as Color;
      case 'resources':
        final resources = territory['resourceIncome'] as Map<String, dynamic>;
        final totalResources =
            resources.values.fold(0, (sum, value) => sum + (value as int));
        return totalResources > 300
            ? AppTheme.darkTheme.colorScheme.tertiary
            : totalResources > 200
                ? AppTheme.warningColor
                : AppTheme.darkTheme.colorScheme.onSurfaceVariant;
      case 'military':
        final strength = territory['garrisonStrength'] as int;
        return strength > 70
            ? AppTheme.successColor
            : strength > 50
                ? AppTheme.warningColor
                : AppTheme.darkTheme.colorScheme.error;
      default:
        return territory['color'] as Color;
    }
  }

  Widget _buildTerritoryIcon(Map<String, dynamic> territory) {
    String iconName;
    switch (widget.layerType) {
      case 'political':
        iconName = territory['status'] == 'controlled'
            ? 'flag'
            : territory['status'] == 'enemy'
                ? 'warning'
                : 'help_outline';
        break;
      case 'resources':
        final resources = territory['resourceIncome'] as Map<String, dynamic>;
        final dominantResource = resources.entries
            .reduce((a, b) => (a.value as int) > (b.value as int) ? a : b)
            .key;
        iconName = dominantResource == 'gold'
            ? 'monetization_on'
            : dominantResource == 'wood'
                ? 'park'
                : dominantResource == 'stone'
                    ? 'landscape'
                    : 'restaurant';
        break;
      case 'military':
        final strength = territory['garrisonStrength'] as int;
        iconName = strength > 70
            ? 'shield'
            : strength > 50
                ? 'security'
                : 'warning';
        break;
      default:
        iconName = 'place';
    }

    return CustomIconWidget(
      iconName: iconName,
      color: _getTerritoryColor(territory),
      size: 24,
    );
  }
}

class MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> territories;
  final String layerType;
  final Function(Map<String, dynamic>) onTerritoryTap;
  final Function(Map<String, dynamic>, Offset) onTerritoryLongPress;

  MapPainter({
    required this.territories,
    required this.layerType,
    required this.onTerritoryTap,
    required this.onTerritoryLongPress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3);

    // Draw grid lines for strategic overlay
    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw territory connections based on layer type
    if (layerType == 'military') {
      _drawMilitaryConnections(canvas, size);
    } else if (layerType == 'resources') {
      _drawTradeRoutes(canvas, size);
    }
  }

  void _drawMilitaryConnections(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.5);

    // Draw connections between enemy territories
    final enemyTerritories =
        territories.where((t) => t['status'] == 'enemy').toList();
    for (int i = 0; i < enemyTerritories.length - 1; i++) {
      final pos1 = enemyTerritories[i]['position'] as Map<String, double>;
      final pos2 = enemyTerritories[i + 1]['position'] as Map<String, double>;

      canvas.drawLine(
        Offset(size.width * pos1['x']!, size.height * pos1['y']!),
        Offset(size.width * pos2['x']!, size.height * pos2['y']!),
        paint,
      );
    }
  }

  void _drawTradeRoutes(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppTheme.darkTheme.colorScheme.tertiary.withValues(alpha: 0.5);

    // Draw connections between controlled territories
    final controlledTerritories =
        territories.where((t) => t['status'] == 'controlled').toList();
    for (int i = 0; i < controlledTerritories.length - 1; i++) {
      final pos1 = controlledTerritories[i]['position'] as Map<String, double>;
      final pos2 =
          controlledTerritories[i + 1]['position'] as Map<String, double>;

      canvas.drawLine(
        Offset(size.width * pos1['x']!, size.height * pos1['y']!),
        Offset(size.width * pos2['x']!, size.height * pos2['y']!),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
