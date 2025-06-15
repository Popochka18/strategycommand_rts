import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ResourceCounterWidget extends StatelessWidget {
  final Map<String, dynamic> resources;
  final AnimationController animationController;

  const ResourceCounterWidget({
    super.key,
    required this.resources,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResourceRow('Gold', resources["gold"] as int, 'monetization_on',
              AppTheme.warningColor),
          SizedBox(height: 4),
          _buildResourceRow(
              'Wood', resources["wood"] as int, 'park', Colors.brown),
          SizedBox(height: 4),
          _buildResourceRow(
              'Stone', resources["stone"] as int, 'landscape', Colors.grey),
          SizedBox(height: 4),
          _buildResourceRow(
              'Food', resources["food"] as int, 'restaurant', Colors.orange),
          SizedBox(height: 8),
          _buildPopulationRow(resources["population"] as String),
        ],
      ),
    );
  }

  Widget _buildResourceRow(
      String name, int amount, String iconName, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 16,
        ),
        SizedBox(width: 6),
        Text(
          '$amount',
          style: AppTheme.dataTextStyle(
            isLight: false,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPopulationRow(String population) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: 'people',
          color: AppTheme.darkTheme.colorScheme.primary,
          size: 16,
        ),
        SizedBox(width: 6),
        Text(
          population,
          style: AppTheme.dataTextStyle(
            isLight: false,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
