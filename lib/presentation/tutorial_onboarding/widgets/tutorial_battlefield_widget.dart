import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class TutorialBattlefieldWidget extends StatefulWidget {
  final String stepType;
  final VoidCallback onInteraction;
  final bool practiceCompleted;

  const TutorialBattlefieldWidget({
    super.key,
    required this.stepType,
    required this.onInteraction,
    required this.practiceCompleted,
  });

  @override
  State<TutorialBattlefieldWidget> createState() =>
      _TutorialBattlefieldWidgetState();
}

class _TutorialBattlefieldWidgetState extends State<TutorialBattlefieldWidget>
    with TickerProviderStateMixin {
  late AnimationController _unitController;
  late Animation<Offset> _unitAnimation;

  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _enemies = [];
  List<Map<String, dynamic>> _structures = [];

  Offset? _selectedUnit;
  final List<Offset> _selectedUnits = [];
  bool _isSelecting = false;
  Offset _selectionStart = Offset.zero;
  Offset _selectionEnd = Offset.zero;

  @override
  void initState() {
    super.initState();
    _unitController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _unitAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.6),
      end: const Offset(0.6, 0.4),
    ).animate(CurvedAnimation(
      parent: _unitController,
      curve: Curves.easeInOut,
    ));

    _initializeBattlefield();
  }

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  void _initializeBattlefield() {
    _units = [
      {
        "id": 1,
        "type": "infantry",
        "position": const Offset(0.3, 0.6),
        "selected": false,
        "health": 100,
        "maxHealth": 100,
      },
      {
        "id": 2,
        "type": "infantry",
        "position": const Offset(0.25, 0.65),
        "selected": false,
        "health": 100,
        "maxHealth": 100,
      },
      {
        "id": 3,
        "type": "tank",
        "position": const Offset(0.35, 0.55),
        "selected": false,
        "health": 200,
        "maxHealth": 200,
      },
    ];

    _resources = [
      {
        "id": 1,
        "type": "crystal",
        "position": const Offset(0.1, 0.3),
        "amount": 500,
      },
      {
        "id": 2,
        "type": "metal",
        "position": const Offset(0.85, 0.7),
        "amount": 300,
      },
    ];

    _enemies = [
      {
        "id": 1,
        "type": "enemy_infantry",
        "position": const Offset(0.7, 0.5),
        "health": 80,
        "maxHealth": 80,
      },
    ];

    _structures = [
      {
        "id": 1,
        "type": "enemy_base",
        "position": const Offset(0.8, 0.2),
        "health": 300,
        "maxHealth": 300,
      },
    ];
  }

  void _handleTap(Offset localPosition, Size size) {
    final relativePosition = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );

    switch (widget.stepType) {
      case "unit_selection":
        _handleUnitSelection(relativePosition);
        break;
      case "movement":
        _handleMovement(relativePosition);
        break;
      case "resources":
        _handleResourceCollection(relativePosition);
        break;
      case "combat":
        _handleCombat(relativePosition);
        break;
      case "victory":
        _handleVictory(relativePosition);
        break;
    }
  }

  void _handleUnitSelection(Offset position) {
    for (int i = 0; i < _units.length; i++) {
      final unit = _units[i];
      final unitPos = unit["position"] as Offset;
      final distance = (position - unitPos).distance;

      if (distance < 0.08) {
        setState(() {
          _units[i]["selected"] = true;
          _selectedUnit = unitPos;
        });
        HapticFeedback.lightImpact();
        widget.onInteraction();
        break;
      }
    }
  }

  void _handleMovement(Offset position) {
    if (_selectedUnit != null) {
      _unitController.reset();
      _unitAnimation = Tween<Offset>(
        begin: _selectedUnit!,
        end: position,
      ).animate(CurvedAnimation(
        parent: _unitController,
        curve: Curves.easeInOut,
      ));

      _unitController.forward().then((_) {
        setState(() {
          for (int i = 0; i < _units.length; i++) {
            if (_units[i]["selected"] == true) {
              _units[i]["position"] = position;
            }
          }
        });
        widget.onInteraction();
      });
    }
  }

  void _handleResourceCollection(Offset position) {
    for (final resource in _resources) {
      final resourcePos = resource["position"] as Offset;
      final distance = (position - resourcePos).distance;

      if (distance < 0.1) {
        widget.onInteraction();
        break;
      }
    }
  }

  void _handleCombat(Offset position) {
    for (final enemy in _enemies) {
      final enemyPos = enemy["position"] as Offset;
      final distance = (position - enemyPos).distance;

      if (distance < 0.1) {
        widget.onInteraction();
        break;
      }
    }
  }

  void _handleVictory(Offset position) {
    for (final structure in _structures) {
      final structurePos = structure["position"] as Offset;
      final distance = (position - structurePos).distance;

      if (distance < 0.1) {
        widget.onInteraction();
        break;
      }
    }
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    if (widget.stepType == "multi_select") {
      setState(() {
        _isSelecting = true;
        _selectionStart = Offset(
          details.localPosition.dx / size.width,
          details.localPosition.dy / size.height,
        );
        _selectionEnd = _selectionStart;
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (widget.stepType == "multi_select" && _isSelecting) {
      setState(() {
        _selectionEnd = Offset(
          details.localPosition.dx / size.width,
          details.localPosition.dy / size.height,
        );
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.stepType == "multi_select" && _isSelecting) {
      final rect = Rect.fromPoints(_selectionStart, _selectionEnd);
      int selectedCount = 0;

      for (int i = 0; i < _units.length; i++) {
        final unitPos = _units[i]["position"] as Offset;
        if (rect.contains(unitPos)) {
          _units[i]["selected"] = true;
          selectedCount++;
        }
      }

      setState(() {
        _isSelecting = false;
      });

      if (selectedCount > 1) {
        widget.onInteraction();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) =>
              _handleTap(details.localPosition, constraints.biggest),
          onPanStart: (details) =>
              _handlePanStart(details, constraints.biggest),
          onPanUpdate: (details) =>
              _handlePanUpdate(details, constraints.biggest),
          onPanEnd: _handlePanEnd,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2D4A3E),
                  const Color(0xFF1A2F26),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Grid pattern
                CustomPaint(
                  size: constraints.biggest,
                  painter: GridPainter(),
                ),

                // Resources
                ..._resources.map((resource) =>
                    _buildResource(resource, constraints.biggest)),

                // Enemy structures
                ..._structures.map((structure) =>
                    _buildStructure(structure, constraints.biggest)),

                // Enemy units
                ..._enemies
                    .map((enemy) => _buildEnemy(enemy, constraints.biggest)),

                // Player units
                ..._units.map((unit) => _buildUnit(unit, constraints.biggest)),

                // Selection rectangle
                if (_isSelecting)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SelectionPainter(_selectionStart, _selectionEnd),
                    ),
                  ),

                // Movement path preview
                if (widget.stepType == "movement" && _selectedUnit != null)
                  CustomPaint(
                    size: constraints.biggest,
                    painter: PathPainter(_selectedUnit!, constraints.biggest),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnit(Map<String, dynamic> unit, Size size) {
    final position = unit["position"] as Offset;
    final isSelected = unit["selected"] as bool;
    final health = unit["health"] as int;
    final maxHealth = unit["maxHealth"] as int;

    return Positioned(
      left: position.dx * size.width - 20,
      top: position.dy * size.height - 20,
      child: Column(
        children: [
          // Health bar
          if (health < maxHealth)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: health / maxHealth,
                child: Container(
                  decoration: BoxDecoration(
                    color: health > maxHealth * 0.5 ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),

          // Unit icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.primary,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: AppTheme.accentColor,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: unit["type"] == "tank" ? 'directions_car' : 'person',
              color: AppTheme.darkTheme.colorScheme.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResource(Map<String, dynamic> resource, Size size) {
    final position = resource["position"] as Offset;
    final amount = resource["amount"] as int;

    return Positioned(
      left: position.dx * size.width - 15,
      top: position.dy * size.height - 15,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: resource["type"] == "crystal" ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: resource["type"] == "crystal" ? 'diamond' : 'build',
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount.toString(),
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnemy(Map<String, dynamic> enemy, Size size) {
    final position = enemy["position"] as Offset;
    final health = enemy["health"] as int;
    final maxHealth = enemy["maxHealth"] as int;

    return Positioned(
      left: position.dx * size.width - 20,
      top: position.dy * size.height - 20,
      child: Column(
        children: [
          // Health bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: health / maxHealth,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Enemy unit
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: 'person',
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructure(Map<String, dynamic> structure, Size size) {
    final position = structure["position"] as Offset;
    final health = structure["health"] as int;
    final maxHealth = structure["maxHealth"] as int;

    return Positioned(
      left: position.dx * size.width - 30,
      top: position.dy * size.height - 30,
      child: Column(
        children: [
          // Health bar
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: health / maxHealth,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Structure
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: 'home',
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SelectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  SelectionPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromPoints(
      Offset(start.dx * size.width, start.dy * size.height),
      Offset(end.dx * size.width, end.dy * size.height),
    );

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PathPainter extends CustomPainter {
  final Offset start;
  final Size canvasSize;

  PathPainter(this.start, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(start.dx * size.width, start.dy * size.height);
    path.lineTo(size.width * 0.6, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
