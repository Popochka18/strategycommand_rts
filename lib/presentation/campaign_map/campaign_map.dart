import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/map_layer_widget.dart';
import './widgets/resource_counter_widget.dart';
import './widgets/territory_card_widget.dart';
import './widgets/turn_notification_widget.dart';
import 'widgets/map_layer_widget.dart';
import 'widgets/resource_counter_widget.dart';
import 'widgets/territory_card_widget.dart';
import 'widgets/turn_notification_widget.dart';

class CampaignMap extends StatefulWidget {
  const CampaignMap({super.key});

  @override
  State<CampaignMap> createState() => _CampaignMapState();
}

class _CampaignMapState extends State<CampaignMap>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _resourceAnimationController;
  late AnimationController _conquestAnimationController;
  
  final TransformationController _mapController = TransformationController();
  int _currentTurn = 15;
  int _selectedMapLayer = 0;
  bool _showLeaderboard = false;
  
  // Mock data for resources
  final Map<String, dynamic> _playerResources = {
    "gold": 2450,
    "wood": 1850,
    "stone": 1200,
    "food": 3100,
  };
  
  // Mock data for territories
  final List<Map<String, dynamic>> _territories = [
{ "id": 1,
"name": "Northern Highlands",
"status": "controlled",
"resourceIncome": {"gold": 150, "wood": 200, "stone": 100},
"garrisonStrength": 85,
"strategicValue": "High",
"position": {"x": 0.3, "y": 0.2},
"color": Color(0xFF2C5F41),
},
{ "id": 2,
"name": "Eastern Plains",
"status": "enemy",
"resourceIncome": {"gold": 120, "food": 180, "wood": 80},
"garrisonStrength": 65,
"strategicValue": "Medium",
"position": {"x": 0.7, "y": 0.3},
"color": Color(0xFFF44336),
},
{ "id": 3,
"name": "Southern Marshes",
"status": "neutral",
"resourceIncome": {"gold": 80, "stone": 150, "food": 120},
"garrisonStrength": 45,
"strategicValue": "Low",
"position": {"x": 0.5, "y": 0.8},
"color": Color(0xFF666666),
},
{ "id": 4,
"name": "Western Forests",
"status": "controlled",
"resourceIncome": {"wood": 300, "food": 150, "gold": 100},
"garrisonStrength": 70,
"strategicValue": "High",
"position": {"x": 0.2, "y": 0.6},
"color": Color(0xFF2C5F41),
},
];
  
  // Mock data for turn notifications
  final List<Map<String, dynamic>> _turnNotifications = [
{ "id": 1,
"type": "battle_victory",
"title": "Victory at Eastern Outpost",
"message": "Your forces have successfully captured the strategic outpost. +200 Gold, +150 Wood",
"timestamp": DateTime.now().subtract(Duration(minutes: 5)),
"dismissed": false,
},
{ "id": 2,
"type": "alliance_request",
"title": "Alliance Proposal",
"message": "Commander Alexis requests a military alliance. Accept to share intelligence and coordinate attacks.",
"timestamp": DateTime.now().subtract(Duration(minutes: 15)),
"dismissed": false,
},
];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _resourceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _conquestAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Start resource counter animation
    _resourceAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _resourceAnimationController.dispose();
    _conquestAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _showTerritoryDetails(Map<String, dynamic> territory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTerritoryBottomSheet(territory),
    );
  }

  void _showTerritoryContextMenu(Map<String, dynamic> territory, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'attack',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'military_tech',
                color: AppTheme.darkTheme.colorScheme.error,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Attack'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'fortify',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Fortify'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'trade',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'swap_horiz',
                color: AppTheme.darkTheme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Trade'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleTerritoryAction(value, territory);
      }
    });
  }

  void _handleTerritoryAction(String action, Map<String, dynamic> territory) {
    switch (action) {
      case 'attack':
        Navigator.pushNamed(context, '/battle-preparation');
        break;
      case 'fortify':
        Navigator.pushNamed(context, '/army-management');
        break;
      case 'trade':
        // Show trade dialog
        break;
    }
  }

  void _endTurn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        title: Text(
          'End Turn',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to end Turn $_currentTurn? This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentTurn++;
              });
              _resourceAnimationController.reset();
              _resourceAnimationController.forward();
            },
            child: Text('End Turn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _showLeaderboard = !_showLeaderboard;
          });
          await Future.delayed(Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverFillRemaining(
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: _showLeaderboard 
                        ? _buildLeaderboard()
                        : _buildMapView(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _endTurn,
        backgroundColor: AppTheme.darkTheme.colorScheme.tertiary,
        icon: CustomIconWidget(
          iconName: 'schedule',
          color: AppTheme.darkTheme.colorScheme.onTertiary,
          size: 24,
        ),
        label: Text(
          'End Turn',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onTertiary,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomToolbar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Turn $_currentTurn',
                    style: AppTheme.darkTheme.textTheme.headlineSmall,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'science',
                          color: AppTheme.darkTheme.colorScheme.onPrimary,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '75%',
                          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.darkTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ResourceCounterWidget(
                      resourceType: 'gold',
                      value: _playerResources['gold'],
                      animationController: _resourceAnimationController,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ResourceCounterWidget(
                      resourceType: 'wood',
                      value: _playerResources['wood'],
                      animationController: _resourceAnimationController,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ResourceCounterWidget(
                      resourceType: 'stone',
                      value: _playerResources['stone'],
                      animationController: _resourceAnimationController,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ResourceCounterWidget(
                      resourceType: 'food',
                      value: _playerResources['food'],
                      animationController: _resourceAnimationController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.darkTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'map',
              color: _tabController.index == 0 
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            text: 'Campaign',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'military_tech',
              color: _tabController.index == 1 
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            text: 'Battles',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'groups',
              color: _tabController.index == 2 
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            text: 'Army',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _tabController.index == 3 
                  ? AppTheme.darkTheme.colorScheme.primary
                  : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            text: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map layers
        Positioned.fill(
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                _selectedMapLayer = index;
              });
            },
            children: [
              MapLayerWidget(
                layerType: 'political',
                territories: _territories,
                onTerritoryTap: _showTerritoryDetails,
                onTerritoryLongPress: _showTerritoryContextMenu,
                mapController: _mapController,
              ),
              MapLayerWidget(
                layerType: 'resources',
                territories: _territories,
                onTerritoryTap: _showTerritoryDetails,
                onTerritoryLongPress: _showTerritoryContextMenu,
                mapController: _mapController,
              ),
              MapLayerWidget(
                layerType: 'military',
                territories: _territories,
                onTerritoryTap: _showTerritoryDetails,
                onTerritoryLongPress: _showTerritoryContextMenu,
                mapController: _mapController,
              ),
            ],
          ),
        ),
        
        // Territory cards overlay
        ..._territories.map((territory) {
          final position = territory['position'] as Map<String, double>;
          return Positioned(
            left: MediaQuery.of(context).size.width * position['x']! - 60,
            top: MediaQuery.of(context).size.height * position['y']! - 40,
            child: TerritoryCardWidget(
              territory: territory,
              onTap: () => _showTerritoryDetails(territory),
            ),
          );
        }),
        
        // Turn notifications
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: _turnNotifications
                .where((notification) => !notification['dismissed'])
                .map((notification) => TurnNotificationWidget(
                      notification: notification,
                      onDismiss: () {
                        setState(() {
                          notification['dismissed'] = true;
                        });
                      },
                    ))
                .toList(),
          ),
        ),
        
        // Map layer indicator
        Positioned(
          bottom: 100,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: _selectedMapLayer == 0 
                      ? 'public' 
                      : _selectedMapLayer == 1 
                          ? 'inventory' 
                          : 'military_tech',
                  color: AppTheme.darkTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _selectedMapLayer == 0 
                      ? 'Political' 
                      : _selectedMapLayer == 1 
                          ? 'Resources' 
                          : 'Military',
                  style: AppTheme.darkTheme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    final List<Map<String, dynamic>> leaderboardData = [
{ "rank": 1,
"playerName": "Commander Steel",
"territories": 12,
"totalResources": 8500,
"alliance": "Iron Legion",
},
{ "rank": 2,
"playerName": "General Storm",
"territories": 10,
"totalResources": 7200,
"alliance": "Thunder Hawks",
},
{ "rank": 3,
"playerName": "You",
"territories": 8,
"totalResources": 6600,
"alliance": "Northern Alliance",
},
];

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Leaderboard',
            style: AppTheme.darkTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: leaderboardData.length,
              itemBuilder: (context, index) {
                final player = leaderboardData[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: player['rank'] <= 3 
                          ? AppTheme.darkTheme.colorScheme.tertiary
                          : AppTheme.darkTheme.colorScheme.surface,
                      child: Text(
                        '${player['rank']}',
                        style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                          color: player['rank'] <= 3 
                              ? AppTheme.darkTheme.colorScheme.onTertiary
                              : AppTheme.darkTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    title: Text(
                      player['playerName'],
                      style: AppTheme.darkTheme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Alliance: ${player['alliance']}',
                      style: AppTheme.darkTheme.textTheme.bodySmall,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${player['territories']} territories',
                          style: AppTheme.darkTheme.textTheme.labelMedium,
                        ),
                        Text(
                          '${player['totalResources']} resources',
                          style: AppTheme.darkTheme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            icon: 'handshake',
            label: 'Diplomacy',
            onTap: () {
              // Show diplomacy screen
            },
          ),
          _buildToolbarButton(
            icon: 'science',
            label: 'Research',
            onTap: () => Navigator.pushNamed(context, '/research-tree'),
          ),
          _buildToolbarButton(
            icon: 'groups',
            label: 'Army',
            onTap: () => Navigator.pushNamed(context, '/army-management'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.darkTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerritoryBottomSheet(Map<String, dynamic> territory) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: territory['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          territory['name'],
                          style: AppTheme.darkTheme.textTheme.headlineSmall,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: territory['status'] == 'controlled'
                              ? AppTheme.successColor.withValues(alpha: 0.2)
                              : territory['status'] == 'enemy'
                                  ? AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.2)
                                  : AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          territory['status'].toString().toUpperCase(),
                          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: territory['status'] == 'controlled'
                                ? AppTheme.successColor
                                : territory['status'] == 'enemy'
                                    ? AppTheme.darkTheme.colorScheme.error
                                    : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Resource Income',
                    style: AppTheme.darkTheme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: (territory['resourceIncome'] as Map<String, dynamic>)
                        .entries
                        .map((entry) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.darkTheme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: entry.key == 'gold' 
                                        ? 'monetization_on'
                                        : entry.key == 'wood'
                                            ? 'park'
                                            : entry.key == 'stone'
                                                ? 'landscape'
                                                : 'restaurant',
                                    color: AppTheme.darkTheme.colorScheme.onPrimaryContainer,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '+${entry.value}',
                                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                                      color: AppTheme.darkTheme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Garrison Strength',
                              style: AppTheme.darkTheme.textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${territory['garrisonStrength']}%',
                              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.darkTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Strategic Value',
                              style: AppTheme.darkTheme.textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              territory['strategicValue'],
                              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                                color: territory['strategicValue'] == 'High'
                                    ? AppTheme.darkTheme.colorScheme.tertiary
                                    : territory['strategicValue'] == 'Medium'
                                        ? AppTheme.warningColor
                                        : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  if (territory['status'] != 'controlled')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/battle-preparation');
                        },
                        icon: CustomIconWidget(
                          iconName: 'military_tech',
                          color: AppTheme.darkTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        label: Text('Attack Territory'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}