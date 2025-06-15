import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/army_overview_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/recruitment_dialog_widget.dart';
import './widgets/unit_card_widget.dart';

class ArmyManagement extends StatefulWidget {
  const ArmyManagement({super.key});

  @override
  State<ArmyManagement> createState() => _ArmyManagementState();
}

class _ArmyManagementState extends State<ArmyManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _selectedUnits = [];
  bool _isSelectionMode = false;

  // Mock data for army units
  final List<Map<String, dynamic>> _armyUnits = [
    {
      "id": "unit_001",
      "name": "Elite Knight",
      "type": "Infantry",
      "level": 15,
      "maxLevel": 20,
      "health": 850,
      "maxHealth": 1000,
      "attack": 120,
      "defense": 95,
      "portrait":
          "https://images.pexels.com/photos/163036/mario-luigi-yoschi-figures-163036.jpeg",
      "abilities": ["Shield Wall", "Charge Attack", "Battle Cry"],
      "upgradeCost": {"gold": 2500, "iron": 150, "gems": 5},
      "equipment": {
        "weapon": "Legendary Sword",
        "armor": "Plate Mail",
        "accessory": "Power Ring"
      },
      "maintenanceCost": 45,
      "powerRating": 1250,
      "canUpgrade": true,
      "isFavorite": true
    },
    {
      "id": "unit_002",
      "name": "Arcane Mage",
      "type": "Magic",
      "level": 12,
      "maxLevel": 20,
      "health": 420,
      "maxHealth": 600,
      "attack": 180,
      "defense": 45,
      "portrait":
          "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg",
      "abilities": ["Fireball", "Ice Shield", "Lightning Storm"],
      "upgradeCost": {"gold": 3000, "mana": 200, "gems": 8},
      "equipment": {
        "weapon": "Staff of Power",
        "armor": "Mystic Robes",
        "accessory": "Mana Crystal"
      },
      "maintenanceCost": 60,
      "powerRating": 1450,
      "canUpgrade": true,
      "isFavorite": false
    },
    {
      "id": "unit_003",
      "name": "Shadow Assassin",
      "type": "Stealth",
      "level": 18,
      "maxLevel": 20,
      "health": 520,
      "maxHealth": 650,
      "attack": 200,
      "defense": 65,
      "portrait":
          "https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg",
      "abilities": ["Stealth Strike", "Poison Blade", "Shadow Step"],
      "upgradeCost": {"gold": 4000, "shadow": 100, "gems": 12},
      "equipment": {
        "weapon": "Twin Daggers",
        "armor": "Shadow Cloak",
        "accessory": "Stealth Boots"
      },
      "maintenanceCost": 55,
      "powerRating": 1680,
      "canUpgrade": true,
      "isFavorite": true
    },
    {
      "id": "unit_004",
      "name": "Heavy Archer",
      "type": "Ranged",
      "level": 10,
      "maxLevel": 20,
      "health": 380,
      "maxHealth": 500,
      "attack": 140,
      "defense": 55,
      "portrait":
          "https://images.pexels.com/photos/1040879/pexels-photo-1040879.jpeg",
      "abilities": ["Multi Shot", "Piercing Arrow", "Eagle Eye"],
      "upgradeCost": {"gold": 1800, "wood": 120, "gems": 3},
      "equipment": {
        "weapon": "Composite Bow",
        "armor": "Leather Vest",
        "accessory": "Quiver of Holding"
      },
      "maintenanceCost": 35,
      "powerRating": 980,
      "canUpgrade": true,
      "isFavorite": false
    },
    {
      "id": "unit_005",
      "name": "War Beast",
      "type": "Cavalry",
      "level": 8,
      "maxLevel": 15,
      "health": 720,
      "maxHealth": 900,
      "attack": 110,
      "defense": 80,
      "portrait":
          "https://images.pexels.com/photos/1040878/pexels-photo-1040878.jpeg",
      "abilities": ["Trample", "Roar", "Charge"],
      "upgradeCost": {"gold": 2200, "meat": 80, "gems": 4},
      "equipment": {
        "weapon": "Battle Saddle",
        "armor": "Beast Armor",
        "accessory": "Speed Horseshoe"
      },
      "maintenanceCost": 50,
      "powerRating": 1100,
      "canUpgrade": true,
      "isFavorite": false
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUnits {
    List<Map<String, dynamic>> filtered = _armyUnits;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((unit) =>
              (unit["name"] as String)
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              (unit["type"] as String)
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Apply type filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Upgradeable') {
        filtered =
            filtered.where((unit) => unit["canUpgrade"] as bool).toList();
      } else if (_selectedFilter == 'Favorites') {
        filtered =
            filtered.where((unit) => unit["isFavorite"] as bool).toList();
      } else {
        filtered =
            filtered.where((unit) => unit["type"] == _selectedFilter).toList();
      }
    }

    return filtered;
  }

  void _toggleUnitSelection(String unitId) {
    setState(() {
      if (_selectedUnits.contains(unitId)) {
        _selectedUnits.remove(unitId);
      } else {
        _selectedUnits.add(unitId);
      }
      _isSelectionMode = _selectedUnits.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUnits.clear();
      _isSelectionMode = false;
    });
  }

  void _showRecruitmentDialog() {
    showDialog(
      context: context,
      builder: (context) => RecruitmentDialogWidget(
        onRecruit: (unitType) {
          // Handle unit recruitment
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _performBulkAction(String action) {
    // Handle bulk actions (upgrade, equip, dismiss)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.dialogBackgroundColor,
        title: Text(
          'Confirm $action',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to $action ${_selectedUnits.length} selected units?',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform action
              _clearSelection();
              Navigator.of(context).pop();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
        title: Text(
          'Army Management',
          style: AppTheme.darkTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.darkTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: () => _performBulkAction('upgrade'),
              icon: CustomIconWidget(
                iconName: 'upgrade',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () => _performBulkAction('equip'),
              icon: CustomIconWidget(
                iconName: 'build',
                color: AppTheme.darkTheme.colorScheme.secondary,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: _clearSelection,
              icon: CustomIconWidget(
                iconName: 'clear',
                color: AppTheme.darkTheme.colorScheme.error,
                size: 24,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/battle-preparation'),
              icon: CustomIconWidget(
                iconName: 'military_tech',
                color: AppTheme.darkTheme.colorScheme.tertiary,
                size: 24,
              ),
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'groups',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 20,
              ),
              text: 'Units',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'build',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 20,
              ),
              text: 'Equipment',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'star',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 20,
              ),
              text: 'Favorites',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUnitsTab(),
          _buildEquipmentTab(),
          _buildFavoritesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecruitmentDialog,
        backgroundColor:
            AppTheme.darkTheme.floatingActionButtonTheme.backgroundColor,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.darkTheme.floatingActionButtonTheme.foregroundColor!,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildUnitsTab() {
    return Column(
      children: [
        // Army Overview
        ArmyOverviewWidget(units: _armyUnits),

        // Search Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: AppTheme.darkTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search units by name or type...',
              prefixIcon: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Filter Chips
        FilterChipsWidget(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),

        // Units List
        Expanded(
          child: _filteredUnits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'search_off',
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No units found',
                        style: AppTheme.darkTheme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Try adjusting your search or filters',
                        style: AppTheme.darkTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _filteredUnits.length,
                  itemBuilder: (context, index) {
                    final unit = _filteredUnits[index];
                    final isSelected = _selectedUnits.contains(unit["id"]);

                    return UnitCardWidget(
                      unit: unit,
                      isSelected: isSelected,
                      isSelectionMode: _isSelectionMode,
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleUnitSelection(unit["id"] as String);
                        }
                      },
                      onLongPress: () {
                        _toggleUnitSelection(unit["id"] as String);
                      },
                      onUpgrade: (unitId) {
                        // Handle unit upgrade
                      },
                      onEquip: (unitId) {
                        // Handle equipment change
                      },
                      onDismiss: (unitId) {
                        // Handle unit dismissal
                      },
                      onToggleFavorite: (unitId) {
                        setState(() {
                          final unitIndex =
                              _armyUnits.indexWhere((u) => u["id"] == unitId);
                          if (unitIndex != -1) {
                            _armyUnits[unitIndex]["isFavorite"] =
                                !(_armyUnits[unitIndex]["isFavorite"] as bool);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEquipmentTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'build',
            color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Equipment Management',
            style: AppTheme.darkTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'Drag and drop equipment to assign to units',
            style: AppTheme.darkTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteUnits =
        _armyUnits.where((unit) => unit["isFavorite"] as bool).toList();

    return favoriteUnits.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'star_border',
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No Favorite Units',
                  style: AppTheme.darkTheme.textTheme.titleLarge,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Mark units as favorites for quick battle deployment',
                  style: AppTheme.darkTheme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: favoriteUnits.length,
            itemBuilder: (context, index) {
              final unit = favoriteUnits[index];

              return UnitCardWidget(
                unit: unit,
                isSelected: false,
                isSelectionMode: false,
                onTap: () {},
                onLongPress: () {},
                onUpgrade: (unitId) {},
                onEquip: (unitId) {},
                onDismiss: (unitId) {},
                onToggleFavorite: (unitId) {
                  setState(() {
                    final unitIndex =
                        _armyUnits.indexWhere((u) => u["id"] == unitId);
                    if (unitIndex != -1) {
                      _armyUnits[unitIndex]["isFavorite"] =
                          !(_armyUnits[unitIndex]["isFavorite"] as bool);
                    }
                  });
                },
              );
            },
          );
  }
}
