import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MinimapWidget extends StatelessWidget {
  final Map<String, dynamic> battleData;
  final Function(Offset) onMapTap;

  const MinimapWidget({
    super.key,
    required this.battleData,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final localPosition = details.localPosition;
        onMapTap(localPosition);
      },
      child: Container(
        width: 25.w,
        height: 25.w,
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: CustomPaint(
          painter: MinimapPainter(battleData: battleData),
        ),
      ),
    );
  }
}

class MinimapPainter extends CustomPainter {
  final Map<String, dynamic> battleData;

  MinimapPainter({required this.battleData});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw minimap background
    final backgroundPaint = Paint()
      ..color =
          AppTheme.darkTheme.scaffoldBackgroundColor.withValues(alpha: 0.5);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw buildings on minimap
    _drawMinimapBuildings(canvas, size);

    // Draw units on minimap
    _drawMinimapUnits(canvas, size);

    // Draw viewport indicator
    _drawViewportIndicator(canvas, size);
  }

  void _drawMinimapBuildings(Canvas canvas, Size size) {
    final buildings = battleData["buildings"] as List;

    for (final dynamic buildingData in buildings) {
      final building = buildingData as Map<String, dynamic>;
      final position = building["position"] as Map<String, dynamic>;
      final isPlayerOwned = building["isPlayerOwned"] as bool;

      final paint = Paint()
        ..color = isPlayerOwned
            ? AppTheme.darkTheme.colorScheme.primary
            : AppTheme.darkTheme.colorScheme.error;

      final x = (position["x"] as double) / 400 * size.width;
      final y = (position["y"] as double) / 400 * size.height;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 6,
          height: 6,
        ),
        paint,
      );
    }
  }

  void _drawMinimapUnits(Canvas canvas, Size size) {
    final units = battleData["units"] as List;

    for (final dynamic unitData in units) {
      final unit = unitData as Map<String, dynamic>;
      final position = unit["position"] as Map<String, dynamic>;

      final paint = Paint()..color = AppTheme.darkTheme.colorScheme.secondary;

      final x = (position["x"] as double) / 400 * size.width;
      final y = (position["y"] as double) / 400 * size.height;

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  void _drawViewportIndicator(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.darkTheme.colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw current viewport rectangle
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.4,
        height: size.height * 0.4,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
