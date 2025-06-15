import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/battle_timer_widget.dart';
import './widgets/battlefield_widget.dart';
import './widgets/chat_overlay_widget.dart';
import './widgets/minimap_widget.dart';
import './widgets/pause_menu_widget.dart';
import './widgets/resource_counter_widget.dart';

class RealTimeBattle extends StatefulWidget {
  const RealTimeBattle({super.key});

  @override
  State<RealTimeBattle> createState() => _RealTimeBattleState();
}

class _RealTimeBattleState extends State<RealTimeBattle>
    with TickerProviderStateMixin {
  // Battle state variables
  bool _isPaused = false;
  bool _showChat = false;
  bool _showGestureHints = true;
  final bool _isMultiplayer = true;
  List<Map<String, dynamic>> _selectedUnits = [];
  String _currentAction = 'move';

  // Animation controllers
  late AnimationController _resourceAnimationController;
  late AnimationController _hintAnimationController;

  // Mock battle data
  final Map<String, dynamic> _battleData = {
    "battleId": "battle_001",
    "battleType": "conquest",
    "timeLimit": 1800, // 30 minutes
    "currentTime": 1245,
    "isMultiplayer": true,
    "playerResources": {
      "gold": 2450,
      "wood": 1800,
      "stone": 950,
      "food": 1200,
      "population": "45/60"
    },
    "enemyResources": {
      "gold": 2100,
      "wood": 1600,
      "stone": 800,
      "food": 1000,
      "population": "38/60"
    },
    "units": [
      {
        "id": "unit_001",
        "type": "infantry",
        "health": 85,
        "maxHealth": 100,
        "position": {"x": 150.0, "y": 200.0},
        "isSelected": false,
        "level": 2
      },
      {
        "id": "unit_002",
        "type": "archer",
        "health": 70,
        "maxHealth": 80,
        "position": {"x": 180.0, "y": 220.0},
        "isSelected": true,
        "level": 1
      },
      {
        "id": "unit_003",
        "type": "cavalry",
        "health": 120,
        "maxHealth": 150,
        "position": {"x": 200.0, "y": 180.0},
        "isSelected": true,
        "level": 3
      }
    ],
    "buildings": [
      {
        "id": "building_001",
        "type": "barracks",
        "health": 800,
        "maxHealth": 1000,
        "position": {"x": 100.0, "y": 100.0},
        "isPlayerOwned": true
      },
      {
        "id": "building_002",
        "type": "tower",
        "health": 600,
        "maxHealth": 800,
        "position": {"x": 300.0, "y": 300.0},
        "isPlayerOwned": false
      }
    ],
    "chatMessages": [
      {
        "playerId": "player_001",
        "playerName": "Commander_Alpha",
        "message": "Advancing on the eastern flank",
        "timestamp": DateTime.now().subtract(Duration(minutes: 2)),
        "isAlly": true
      },
      {
        "playerId": "player_002",
        "playerName": "General_Beta",
        "message": "Need reinforcements at the bridge",
        "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
        "isAlly": true
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _hideSystemUI();
    _loadSelectedUnits();

    // Hide gesture hints after 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showGestureHints = false;
        });
      }
    });
  }

  void _initializeAnimations() {
    _resourceAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _hintAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _hintAnimationController.repeat(reverse: true);
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _loadSelectedUnits() {
    _selectedUnits = (_battleData["units"] as List)
        .where((dynamic unit) =>
            (unit as Map<String, dynamic>)["isSelected"] == true)
        .map((dynamic unit) => unit as Map<String, dynamic>)
        .toList();
  }

  void _onUnitSelection(List<Map<String, dynamic>> units) {
    setState(() {
      _selectedUnits = units;
    });

    // Haptic feedback for unit selection
    HapticFeedback.selectionClick();
  }

  void _onActionSelected(String action) {
    setState(() {
      _currentAction = action;
    });

    HapticFeedback.lightImpact();
  }

  void _togglePause() {
    if (!_isMultiplayer) {
      setState(() {
        _isPaused = !_isPaused;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _toggleChat() {
    setState(() {
      _showChat = !_showChat;
    });
  }

  void _onBattleComplete(Map<String, dynamic> results) {
    _showBattleResults(results);
  }

  void _showBattleResults(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'Battle Complete',
          style: AppTheme.darkTheme.textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              results["victory"] == true ? 'Victory!' : 'Defeat',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: results["victory"] == true
                    ? AppTheme.successColor
                    : AppTheme.darkTheme.colorScheme.error,
              ),
            ),
            SizedBox(height: 16),
            Text('Casualties: ${results["casualties"] ?? 0}'),
            Text('Resources Gained: \$${results["resourcesGained"] ?? 0}'),
            Text('Experience: +${results["experience"] ?? 0} XP'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/campaign-map');
            },
            child: Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveReplay();
            },
            child: Text('Save Replay'),
          ),
        ],
      ),
    );
  }

  void _saveReplay() {
    // Mock replay save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Battle replay saved successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    Navigator.pushReplacementNamed(context, '/campaign-map');
  }

  @override
  void dispose() {
    _resourceAnimationController.dispose();
    _hintAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main battlefield
          BattlefieldWidget(
            battleData: _battleData,
            selectedUnits: _selectedUnits,
            currentAction: _currentAction,
            onUnitSelection: _onUnitSelection,
            showGestureHints: _showGestureHints,
            hintAnimation: _hintAnimationController,
          ),

          // Top UI elements
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: ResourceCounterWidget(
              resources: _battleData["playerResources"] as Map<String, dynamic>,
              animationController: _resourceAnimationController,
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: MinimapWidget(
              battleData: _battleData,
              onMapTap: (Offset position) {
                // Center battlefield on tapped position
                HapticFeedback.lightImpact();
              },
            ),
          ),

          // Battle timer
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: BattleTimerWidget(
              currentTime: _battleData["currentTime"] as int,
              timeLimit: _battleData["timeLimit"] as int,
            ),
          ),

          // Bottom action buttons
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: ActionButtonsWidget(
              selectedUnits: _selectedUnits,
              currentAction: _currentAction,
              onActionSelected: _onActionSelected,
            ),
          ),

          // Pause button (single-player only)
          if (!_isMultiplayer)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 80,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppTheme.darkTheme.colorScheme.surface
                    .withValues(alpha: 0.8),
                onPressed: _togglePause,
                child: CustomIconWidget(
                  iconName: _isPaused ? 'play_arrow' : 'pause',
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),

          // Chat toggle button (multiplayer only)
          if (_isMultiplayer)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppTheme.darkTheme.colorScheme.surface
                    .withValues(alpha: 0.8),
                onPressed: _toggleChat,
                child: CustomIconWidget(
                  iconName: 'chat',
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),

          // Chat overlay
          if (_showChat && _isMultiplayer)
            ChatOverlayWidget(
              messages:
                  _battleData["chatMessages"] as List<Map<String, dynamic>>,
              onSendMessage: (String message) {
                // Handle message sending
                HapticFeedback.lightImpact();
              },
              onClose: () => _toggleChat(),
            ),

          // Pause menu overlay
          if (_isPaused)
            PauseMenuWidget(
              onResume: _togglePause,
              onSettings: () {
                // Navigate to settings
              },
              onExit: () {
                Navigator.pushReplacementNamed(context, '/campaign-map');
              },
            ),
        ],
      ),
    );
  }
}
