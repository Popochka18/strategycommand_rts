import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ResourceCounterWidget extends StatefulWidget {
  final String resourceType;
  final int value;
  final AnimationController animationController;

  const ResourceCounterWidget({
    super.key,
    required this.resourceType,
    required this.value,
    required this.animationController,
  });

  @override
  State<ResourceCounterWidget> createState() => _ResourceCounterWidgetState();
}

class _ResourceCounterWidgetState extends State<ResourceCounterWidget>
    with SingleTickerProviderStateMixin {
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _countAnimation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(ResourceCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _countAnimation = IntTween(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOutCubic,
      ));
    }
  }

  String _getResourceIcon() {
    switch (widget.resourceType) {
      case 'gold':
        return 'monetization_on';
      case 'wood':
        return 'park';
      case 'stone':
        return 'landscape';
      case 'food':
        return 'restaurant';
      default:
        return 'inventory';
    }
  }

  Color _getResourceColor() {
    switch (widget.resourceType) {
      case 'gold':
        return Color(0xFFFFD700);
      case 'wood':
        return Color(0xFF8B4513);
      case 'stone':
        return Color(0xFF708090);
      case 'food':
        return Color(0xFF32CD32);
      default:
        return AppTheme.darkTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getResourceColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getResourceIcon(),
            color: _getResourceColor(),
            size: 16,
          ),
          SizedBox(height: 2),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return Text(
                _formatNumber(_countAnimation.value),
                style: AppTheme.dataTextStyle(
                  isLight: false,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ).copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '\${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '\${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
