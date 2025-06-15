import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/army_template_widget.dart';
import './widgets/formation_grid_widget.dart';
import './widgets/resource_counter_widget.dart';
import './widgets/unit_card_widget.dart';

class BattlePreparation extends StatefulWidget {
  const BattlePreparation({super.key});

  @override
  State<BattlePreparation> createState() => _BattlePreparationState();
}

class _BattlePreparationState extends State<BattlePreparation>
    with TickerProviderStateMixin {
  late TabController _templateController;
  int _selectedTemplateIndex = 0;
  final int _currentBudget = 1500;
  int _usedBudget = 0;
  List<Map<String, dynamic>> _deployedUnits = [];
  final bool _isMultiplayer = false;
  final String _opponentStrength = "Medium";
  final String _estimatedDuration = "8-12 min";

  // Mock data for available units
  final List<Map<String, dynamic>> _availableUnits = [
    {
      "id": 1,
      "name": "Infantry",
      "type": "Ground",
      "cost": 50,
      "health": 100,
      "attack": 25,
      "defense": 15,
      "speed": 3,
      "range": 1,
      "special": "Fortify",
      "description":
          "Basic ground unit with balanced stats and defensive capabilities",
      "image":
          "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=400",
      "count": 10,
    },
    {
      "id": 2,
      "name": "Archer",
      "type": "Ranged",
      "cost": 75,
      "health": 80,
      "attack": 35,
      "defense": 10,
      "speed": 2,
      "range": 4,
      "special": "Piercing Shot",
      "description":
          "Long-range unit effective against light armor with piercing abilities",
      "image":
          "https://images.pexels.com/photos/163064/play-stone-network-networked-interactive-163064.jpeg?auto=compress&cs=tinysrgb&w=400",
      "count": 8,
    },
    {
      "id": 3,
      "name": "Cavalry",
      "type": "Mounted",
      "cost": 120,
      "health": 150,
      "attack": 40,
      "defense": 20,
      "speed": 6,
      "range": 1,
      "special": "Charge",
      "description": "Fast-moving heavy unit with devastating charge attacks",
      "image":
          "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=400",
      "count": 5,
    },
    {
      "id": 4,
      "name": "Mage",
      "type": "Magic",
      "cost": 200,
      "health": 60,
      "attack": 50,
      "defense": 5,
      "speed": 2,
      "range": 3,
      "special": "Fireball",
      "description":
          "Powerful spellcaster with area damage and magical abilities",
      "image":
          "https://images.pixabay.com/photo/2016/03/31/19/58/avatar-1295429_640.png",
      "count": 3,
    },
    {
      "id": 5,
      "name": "Siege Engine",
      "type": "Siege",
      "cost": 300,
      "health": 200,
      "attack": 80,
      "defense": 30,
      "speed": 1,
      "range": 5,
      "special": "Demolish",
      "description":
          "Heavy siege weapon for destroying fortifications and structures",
      "image":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&auto=format&fit=crop&q=60",
      "count": 2,
    },
    {
      "id": 6,
      "name": "Scout",
      "type": "Support",
      "cost": 40,
      "health": 70,
      "attack": 20,
      "defense": 8,
      "speed": 5,
      "range": 2,
      "special": "Stealth",
      "description":
          "Fast reconnaissance unit with stealth and vision abilities",
      "image":
          "https://images.pexels.com/photos/163064/play-stone-network-networked-interactive-163064.jpeg?auto=compress&cs=tinysrgb&w=400",
      "count": 6,
    },
  ];

  // Mock army templates
  final List<Map<String, dynamic>> _armyTemplates = [
    {
      "name": "Balanced Force",
      "description": "Well-rounded army composition",
      "units": [
        {
          "unitId": 1,
          "count": 4,
          "position": [0, 0]
        },
        {
          "unitId": 2,
          "count": 3,
          "position": [1, 0]
        },
        {
          "unitId": 3,
          "count": 2,
          "position": [0, 1]
        },
      ],
    },
    {
      "name": "Heavy Assault",
      "description": "Aggressive melee-focused formation",
      "units": [
        {
          "unitId": 1,
          "count": 6,
          "position": [0, 0]
        },
        {
          "unitId": 3,
          "count": 4,
          "position": [1, 0]
        },
        {
          "unitId": 5,
          "count": 1,
          "position": [2, 0]
        },
      ],
    },
    {
      "name": "Ranged Support",
      "description": "Long-range tactical advantage",
      "units": [
        {
          "unitId": 2,
          "count": 5,
          "position": [0, 0]
        },
        {
          "unitId": 4,
          "count": 2,
          "position": [1, 0]
        },
        {
          "unitId": 6,
          "count": 3,
          "position": [0, 1]
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _templateController =
        TabController(length: _armyTemplates.length, vsync: this);
    _calculateUsedBudget();
  }

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  void _calculateUsedBudget() {
    int total = 0;
    for (var unit in _deployedUnits) {
      final unitData =
          _availableUnits.firstWhere((u) => u["id"] == unit["unitId"]);
      total += (unitData["cost"] as int) * (unit["count"] as int);
    }
    setState(() {
      _usedBudget = total;
    });
  }

  void _addUnitToFormation(Map<String, dynamic> unit, int count) {
    HapticFeedback.lightImpact();

    final existingIndex =
        _deployedUnits.indexWhere((u) => u["unitId"] == unit["id"]);
    if (existingIndex != -1) {
      setState(() {
        _deployedUnits[existingIndex]["count"] += count;
      });
    } else {
      setState(() {
        _deployedUnits.add({
          "unitId": unit["id"],
          "count": count,
          "position": [_deployedUnits.length % 4, _deployedUnits.length ~/ 4],
        });
      });
    }
    _calculateUsedBudget();
  }

  void _removeUnitFromFormation(int unitId) {
    HapticFeedback.lightImpact();
    setState(() {
      _deployedUnits.removeWhere((u) => u["unitId"] == unitId);
    });
    _calculateUsedBudget();
  }

  void _loadTemplate(int templateIndex) {
    setState(() {
      _selectedTemplateIndex = templateIndex;
      _deployedUnits = List.from(_armyTemplates[templateIndex]["units"]);
    });
    _calculateUsedBudget();
  }

  void _deployArmy() {
    if (_deployedUnits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please deploy at least one unit before battle!'),
          backgroundColor: AppTheme.darkTheme.colorScheme.error,
        ),
      );
      return;
    }

    if (_usedBudget > _currentBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Army cost exceeds available budget!'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/real-time-battle');
  }

  void _autoDeployArmy() {
    // Auto-deploy balanced composition
    setState(() {
      _deployedUnits = [
        {
          "unitId": 1,
          "count": 3,
          "position": [0, 0]
        },
        {
          "unitId": 2,
          "count": 2,
          "position": [1, 0]
        },
        {
          "unitId": 3,
          "count": 1,
          "position": [2, 0]
        },
        {
          "unitId": 6,
          "count": 2,
          "position": [0, 1]
        },
      ];
    });
    _calculateUsedBudget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
        title: Text(
          'Battle Preparation',
          style: AppTheme.darkTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.darkTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/army-management'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.darkTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Resource Counter
            ResourceCounterWidget(
              currentBudget: _currentBudget,
              usedBudget: _usedBudget,
              isMultiplayer: _isMultiplayer,
              opponentStrength: _opponentStrength,
              estimatedDuration: _estimatedDuration,
            ),

            // Main Content Area
            Expanded(
              child: Row(
                children: [
                  // Available Units Section (Left)
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.darkTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'groups',
                                  color: AppTheme.darkTheme.colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Available Units',
                                  style:
                                      AppTheme.darkTheme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              itemCount: _availableUnits.length,
                              itemBuilder: (context, index) {
                                return UnitCardWidget(
                                  unit: _availableUnits[index],
                                  onAddToFormation: _addUnitToFormation,
                                  currentBudget: _currentBudget,
                                  usedBudget: _usedBudget,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Formation Grid Section (Right)
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.darkTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'grid_view',
                                  color: AppTheme.darkTheme.colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Battle Formation',
                                  style:
                                      AppTheme.darkTheme.textTheme.titleMedium,
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: _autoDeployArmy,
                                  child: Text('Auto Deploy'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FormationGridWidget(
                              deployedUnits: _deployedUnits,
                              availableUnits: _availableUnits,
                              onRemoveUnit: _removeUnitFromFormation,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Army Templates Section
            Container(
              height: 120,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Army Templates',
                      style: AppTheme.darkTheme.textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _templateController,
                      children: _armyTemplates.map((template) {
                        return ArmyTemplateWidget(
                          template: template,
                          onLoadTemplate: () =>
                              _loadTemplate(_armyTemplates.indexOf(template)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Save formation logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Formation saved successfully!')),
                        );
                      },
                      child: Text('Save Formation'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _deployArmy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _usedBudget <= _currentBudget &&
                                _deployedUnits.isNotEmpty
                            ? AppTheme.darkTheme.colorScheme.primary
                            : AppTheme.darkTheme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'play_arrow',
                            color: AppTheme.darkTheme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Deploy Army',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
}
