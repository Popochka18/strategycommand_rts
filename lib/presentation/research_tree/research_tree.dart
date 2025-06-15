import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../core/app_export.dart';
import './widgets/research_detail_sheet.dart';
import './widgets/research_filter_widget.dart';
import './widgets/research_header_widget.dart';
import './widgets/research_node_widget.dart';
import './widgets/research_queue_widget.dart';

class ResearchTree extends StatefulWidget {
  const ResearchTree({super.key});

  @override
  State<ResearchTree> createState() => _ResearchTreeState();
}

class _ResearchTreeState extends State<ResearchTree>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _progressAnimationController;
  late AnimationController _particleAnimationController;

  String _selectedCategory = 'All';
  bool _showOnlyAvailable = false;
  String? _selectedNodeId;
  bool _showResearchQueue = false;

  // Mock research data
  final List<Map<String, dynamic>> _researchNodes = [
{ "id": "military_1",
"name": "Basic Infantry Training",
"category": "Military",
"description": "Improves infantry unit combat effectiveness by 15%",
"cost": 100,
"duration": 300, // seconds "prerequisites": [],
"isUnlocked": true,
"isCompleted": false,
"isResearching": true,
"progress": 0.65,
"position": {"x": 100.0, "y": 200.0},
"benefits": ["Infantry damage +15%", "Infantry health +10%"],
"icon": "military_tech" },
{ "id": "military_2",
"name": "Advanced Weaponry",
"category": "Military",
"description": "Unlocks advanced weapon technologies for all units",
"cost": 250,
"duration": 600,
"prerequisites": ["military_1"],
"isUnlocked": false,
"isCompleted": false,
"isResearching": false,
"progress": 0.0,
"position": {"x": 300.0, "y": 200.0},
"benefits": ["All units damage +20%", "Unlocks new weapon types"],
"icon": "gps_fixed" },
{ "id": "economic_1",
"name": "Resource Management",
"category": "Economic",
"description": "Increases resource generation efficiency by 25%",
"cost": 150,
"duration": 450,
"prerequisites": [],
"isUnlocked": true,
"isCompleted": true,
"isResearching": false,
"progress": 1.0,
"position": {"x": 100.0, "y": 400.0},
"benefits": ["Resource generation +25%", "Storage capacity +30%"],
"icon": "account_balance" },
{ "id": "economic_2",
"name": "Trade Networks",
"category": "Economic",
"description": "Establishes trade routes for additional income",
"cost": 300,
"duration": 720,
"prerequisites": ["economic_1"],
"isUnlocked": true,
"isCompleted": false,
"isResearching": false,
"progress": 0.0,
"position": {"x": 300.0, "y": 400.0},
"benefits": ["Passive income +50%", "Unlocks trade buildings"],
"icon": "trending_up" },
{ "id": "diplomatic_1",
"name": "Basic Diplomacy",
"category": "Diplomatic",
"description": "Enables basic diplomatic actions and treaties",
"cost": 120,
"duration": 360,
"prerequisites": [],
"isUnlocked": true,
"isCompleted": false,
"isResearching": false,
"progress": 0.0,
"position": {"x": 100.0, "y": 600.0},
"benefits": ["Unlocks alliance system", "Reduces war penalty"],
"icon": "handshake" },
{ "id": "magical_1",
"name": "Arcane Studies",
"category": "Magical",
"description": "Introduces magical research and spell casting",
"cost": 200,
"duration": 540,
"prerequisites": [],
"isUnlocked": true,
"isCompleted": false,
"isResearching": false,
"progress": 0.0,
"position": {"x": 100.0, "y": 800.0},
"benefits": ["Unlocks magic units", "Enables spell research"],
"icon": "auto_fix_high" }
];

  final List<Map<String, dynamic>> _researchQueue = [
{ "id": "military_1",
"name": "Basic Infantry Training",
"progress": 0.65,
"timeRemaining": 105, // seconds 
"priority": 1 },
{ "id": "economic_2",
"name": "Trade Networks",
"progress": 0.0,
"timeRemaining": 720,
"priority": 2 }
];

  int _availableResearchPoints = 450;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _particleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _progressAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNodes {
    return _researchNodes.where((node) {
      bool categoryMatch = _selectedCategory == 'All' || 
          node['category'] == _selectedCategory;
      bool availabilityMatch = !_showOnlyAvailable || 
          (node['isUnlocked'] as bool);
      return categoryMatch && availabilityMatch;
    }).toList();
  }

  void _onNodeTap(String nodeId) {
    setState(() {
      _selectedNodeId = nodeId;
    });
    _showResearchDetailSheet(nodeId);
  }

  void _showResearchDetailSheet(String nodeId) {
    final node = _researchNodes.firstWhere((n) => n['id'] == nodeId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResearchDetailSheet(
        node: node,
        onStartResearch: _startResearch,
        availablePoints: _availableResearchPoints,
      ),
    );
  }

  void _startResearch(String nodeId) {
    setState(() {
      final nodeIndex = _researchNodes.indexWhere((n) => n['id'] == nodeId);
      if (nodeIndex != -1) {
        _researchNodes[nodeIndex]['isResearching'] = true;
        _availableResearchPoints -= _researchNodes[nodeIndex]['cost'] as int;
        
        // Add to queue if not already there
        if (!_researchQueue.any((q) => q['id'] == nodeId)) {
          _researchQueue.add({
            "id": nodeId,
            "name": _researchNodes[nodeIndex]['name'],
            "progress": 0.0,
            "timeRemaining": _researchNodes[nodeIndex]['duration'],
            "priority": _researchQueue.length + 1
          });
        }
      }
    });
    Navigator.pop(context);
  }

  void _onCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _toggleAvailableOnly() {
    setState(() {
      _showOnlyAvailable = !_showOnlyAvailable;
    });
  }

  void _toggleResearchQueue() {
    setState(() {
      _showResearchQueue = !_showResearchQueue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.darkTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.darkTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Research Tree',
          style: AppTheme.darkTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _toggleResearchQueue,
            icon: CustomIconWidget(
              iconName: 'queue',
              color: _showResearchQueue 
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // Research Header
          ResearchHeaderWidget(
            availablePoints: _availableResearchPoints,
            activeResearchCount: _researchQueue.length,
          ),
          
          // Research Filters
          ResearchFilterWidget(
            selectedCategory: _selectedCategory,
            showOnlyAvailable: _showOnlyAvailable,
            onCategoryChanged: _onCategoryFilter,
            onAvailableToggle: _toggleAvailableOnly,
          ),
          
          // Research Tree View
          Expanded(
            child: Stack(
              children: [
                // Main research tree
                InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 3.0,
                  constrained: false,
                  child: SizedBox(
                    width: 120.w,
                    height: 200.h,
                    child: CustomPaint(
                      painter: ResearchTreePainter(
                        nodes: _filteredNodes,
                        selectedNodeId: _selectedNodeId,
                      ),
                      child: Stack(
                        children: _filteredNodes.map((node) {
                          return Positioned(
                            left: (node['position']['x'] as double) - 30,
                            top: (node['position']['y'] as double) - 30,
                            child: ResearchNodeWidget(
                              node: node,
                              isSelected: _selectedNodeId == node['id'],
                              onTap: () => _onNodeTap(node['id'] as String),
                              progressAnimation: _progressAnimationController,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                
                // Research Queue Overlay
                if (_showResearchQueue)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: ResearchQueueWidget(
                      queue: _researchQueue,
                      onClose: _toggleResearchQueue,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _researchQueue.removeAt(oldIndex);
                          _researchQueue.insert(newIndex, item);
                          // Update priorities
                          for (int i = 0; i < _researchQueue.length; i++) {
                            _researchQueue[i]['priority'] = i + 1;
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset zoom and pan to center
          _transformationController.value = Matrix4.identity();
        },
        backgroundColor: AppTheme.darkTheme.floatingActionButtonTheme.backgroundColor,
        child: CustomIconWidget(
          iconName: 'center_focus_strong',
          color: AppTheme.darkTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }
}

class ResearchTreePainter extends CustomPainter {
  final List<Map<String, dynamic>> nodes;
  final String? selectedNodeId;

  ResearchTreePainter({
    required this.nodes,
    this.selectedNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw connection lines between nodes
    for (final node in nodes) {
      final prerequisites = node['prerequisites'] as List;
      final nodePos = Offset(
        node['position']['x'] as double,
        node['position']['y'] as double,
      );

      for (final prereqId in prerequisites) {
        final prereqNode = nodes.firstWhere(
          (n) => n['id'] == prereqId,
          orElse: () => <String, dynamic>{},
        );
        
        if (prereqNode.isNotEmpty) {
          final prereqPos = Offset(
            prereqNode['position']['x'] as double,
            prereqNode['position']['y'] as double,
          );

          // Set line color based on unlock status
          paint.color = (node['isUnlocked'] as bool)
              ? AppTheme.darkTheme.colorScheme.primary
              : AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.3);

          canvas.drawLine(prereqPos, nodePos, paint);

          // Draw arrow at the end
          _drawArrow(canvas, prereqPos, nodePos, paint);
        }
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 8.0;
    final direction = (end - start).direction;
    final arrowPoint1 = Offset(
      end.dx - arrowSize * cos(direction - 0.5),
      end.dy - arrowSize * sin(direction - 0.5),
    );
    final arrowPoint2 = Offset(
      end.dx - arrowSize * cos(direction + 0.5),
      end.dy - arrowSize * sin(direction + 0.5),
    );

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}