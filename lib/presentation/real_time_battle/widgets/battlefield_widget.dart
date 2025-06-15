import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BattlefieldWidget extends StatefulWidget {
  final Map<String, dynamic> battleData;
  final List<Map<String, dynamic>> selectedUnits;
  final String currentAction;
  final Function(List<Map<String, dynamic>>) onUnitSelection;
  final bool showGestureHints;
  final AnimationController hintAnimation;

  const BattlefieldWidget({
    super.key,
    required this.battleData,
    required this.selectedUnits,
    required this.currentAction,
    required this.onUnitSelection,
    required this.showGestureHints,
    required this.hintAnimation,
  });

  @override
  State<BattlefieldWidget> createState() => _BattlefieldWidgetState();
}

class _BattlefieldWidgetState extends State<BattlefieldWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset? _dragStart;
  Offset? _selectionStart;
  Offset? _selectionEnd;
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.darkTheme.scaffoldBackgroundColor,
        child: Stack(
          children: [
            // Battlefield background
            Transform(
              transform: Matrix4.identity()
                ..scale(_scale)
                ..translate(_offset.dx, _offset.dy),
              child: Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      AppTheme.darkTheme.colorScheme.surface
                          .withValues(alpha: 0.3),
                      AppTheme.darkTheme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: BattlefieldPainter(
                    battleData: widget.battleData,
                    selectedUnits: widget.selectedUnits,
                    scale: _scale,
                    offset: _offset,
                  ),
                ),
              ),
            ),

            // Selection rectangle
            if (_isSelecting &&
                _selectionStart != null &&
                _selectionEnd != null)
              Positioned(
                left: _selectionStart!.dx < _selectionEnd!.dx
                    ? _selectionStart!.dx
                    : _selectionEnd!.dx,
                top: _selectionStart!.dy < _selectionEnd!.dy
                    ? _selectionStart!.dy
                    : _selectionEnd!.dy,
                child: Container(
                  width: (_selectionEnd!.dx - _selectionStart!.dx).abs(),
                  height: (_selectionEnd!.dy - _selectionStart!.dy).abs(),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.darkTheme.colorScheme.primary,
                      width: 2,
                    ),
                    color: AppTheme.darkTheme.colorScheme.primary
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),

            // Gesture hints
            if (widget.showGestureHints) _buildGestureHints(),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureHints() {
    return AnimatedBuilder(
      animation: widget.hintAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 20.h,
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.primary.withValues(
                  alpha: 0.5 + (widget.hintAnimation.value * 0.5),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Battle Controls',
                  style: AppTheme.darkTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHintItem('Pinch to zoom', 'zoom_in'),
                    _buildHintItem('Drag to pan', 'pan_tool'),
                    _buildHintItem('Tap to select', 'touch_app'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHintItem(String text, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.darkTheme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          text,
          style: AppTheme.darkTheme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_scale * details.scale).clamp(0.5, 3.0);

      if (details.scale == 1.0) {
        final delta = details.focalPoint - _dragStart!;
        _offset += delta / _scale;
        _dragStart = details.focalPoint;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _dragStart = null;
  }

  void _onTapDown(TapDownDetails details) {
    // Handle unit selection
  }

  void _onTapUp(TapUpDetails details) {
    final localPosition = details.localPosition;
    _selectUnitsAtPosition(localPosition);
  }

  void _onPanStart(DragStartDetails details) {
    _selectionStart = details.localPosition;
    _isSelecting = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _selectionEnd = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectionStart != null && _selectionEnd != null) {
      _selectUnitsInRectangle(_selectionStart!, _selectionEnd!);
    }

    setState(() {
      _isSelecting = false;
      _selectionStart = null;
      _selectionEnd = null;
    });
  }

  void _selectUnitsAtPosition(Offset position) {
    final units = widget.battleData["units"] as List;
    final selectedUnits = <Map<String, dynamic>>[];

    for (final dynamic unitData in units) {
      final unit = unitData as Map<String, dynamic>;
      final unitPosition = unit["position"] as Map<String, dynamic>;
      final unitX = (unitPosition["x"] as double) * _scale + _offset.dx;
      final unitY = (unitPosition["y"] as double) * _scale + _offset.dy;

      final distance = (Offset(unitX, unitY) - position).distance;
      if (distance < 30) {
        selectedUnits.add(unit);
        break; // Select only one unit on tap
      }
    }

    widget.onUnitSelection(selectedUnits);
    HapticFeedback.selectionClick();
  }

  void _selectUnitsInRectangle(Offset start, Offset end) {
    final units = widget.battleData["units"] as List;
    final selectedUnits = <Map<String, dynamic>>[];

    final rect = Rect.fromPoints(start, end);

    for (final dynamic unitData in units) {
      final unit = unitData as Map<String, dynamic>;
      final unitPosition = unit["position"] as Map<String, dynamic>;
      final unitX = (unitPosition["x"] as double) * _scale + _offset.dx;
      final unitY = (unitPosition["y"] as double) * _scale + _offset.dy;

      if (rect.contains(Offset(unitX, unitY))) {
        selectedUnits.add(unit);
      }
    }

    widget.onUnitSelection(selectedUnits);
    if (selectedUnits.isNotEmpty) {
      HapticFeedback.selectionClick();
    }
  }
}

class BattlefieldPainter extends CustomPainter {
  final Map<String, dynamic> battleData;
  final List<Map<String, dynamic>> selectedUnits;
  final double scale;
  final Offset offset;

  BattlefieldPainter({
    required this.battleData,
    required this.selectedUnits,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    _drawGrid(canvas, size);

    // Draw buildings
    _drawBuildings(canvas);

    // Draw units
    _drawUnits(canvas);

    // Draw selection highlights
    _drawSelectionHighlights(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawBuildings(Canvas canvas) {
    final buildings = battleData["buildings"] as List;

    for (final dynamic buildingData in buildings) {
      final building = buildingData as Map<String, dynamic>;
      final position = building["position"] as Map<String, dynamic>;
      final isPlayerOwned = building["isPlayerOwned"] as bool;

      final paint = Paint()
        ..color = isPlayerOwned
            ? AppTheme.darkTheme.colorScheme.primary
            : AppTheme.darkTheme.colorScheme.error;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            (position["x"] as double) + offset.dx,
            (position["y"] as double) + offset.dy,
          ),
          width: 40 * scale,
          height: 40 * scale,
        ),
        paint,
      );
    }
  }

  void _drawUnits(Canvas canvas) {
    final units = battleData["units"] as List;

    for (final dynamic unitData in units) {
      final unit = unitData as Map<String, dynamic>;
      final position = unit["position"] as Map<String, dynamic>;
      final health = unit["health"] as int;
      final maxHealth = unit["maxHealth"] as int;

      final center = Offset(
        (position["x"] as double) + offset.dx,
        (position["y"] as double) + offset.dy,
      );

      // Draw unit circle
      final unitPaint = Paint()
        ..color = AppTheme.darkTheme.colorScheme.secondary;

      canvas.drawCircle(center, 15 * scale, unitPaint);

      // Draw health bar
      final healthBarWidth = 20 * scale;
      final healthBarHeight = 3 * scale;
      final healthPercentage = health / maxHealth;

      // Background
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 25 * scale),
          width: healthBarWidth,
          height: healthBarHeight,
        ),
        Paint()
          ..color = AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.5),
      );

      // Health
      canvas.drawRect(
        Rect.fromLTWH(
          center.dx - healthBarWidth / 2,
          center.dy - 25 * scale - healthBarHeight / 2,
          healthBarWidth * healthPercentage,
          healthBarHeight,
        ),
        Paint()..color = AppTheme.successColor,
      );
    }
  }

  void _drawSelectionHighlights(Canvas canvas) {
    for (final unit in selectedUnits) {
      final position = unit["position"] as Map<String, dynamic>;
      final center = Offset(
        (position["x"] as double) + offset.dx,
        (position["y"] as double) + offset.dy,
      );

      final paint = Paint()
        ..color = AppTheme.darkTheme.colorScheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, 20 * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
