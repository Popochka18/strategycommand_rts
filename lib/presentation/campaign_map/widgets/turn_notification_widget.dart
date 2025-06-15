import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class TurnNotificationWidget extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDismiss;

  const TurnNotificationWidget({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<TurnNotificationWidget> createState() => _TurnNotificationWidgetState();
}

class _TurnNotificationWidgetState extends State<TurnNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  Color _getNotificationColor() {
    switch (widget.notification['type']) {
      case 'battle_victory':
        return AppTheme.successColor;
      case 'battle_defeat':
        return AppTheme.darkTheme.colorScheme.error;
      case 'alliance_request':
        return AppTheme.darkTheme.colorScheme.tertiary;
      case 'resource_bonus':
        return AppTheme.warningColor;
      default:
        return AppTheme.darkTheme.colorScheme.primary;
    }
  }

  String _getNotificationIcon() {
    switch (widget.notification['type']) {
      case 'battle_victory':
        return 'military_tech';
      case 'battle_defeat':
        return 'warning';
      case 'alliance_request':
        return 'handshake';
      case 'resource_bonus':
        return 'monetization_on';
      default:
        return 'notifications';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: Key('notification_${widget.notification['id']}'),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onDismiss(),
          background: Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16),
            child: CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.darkTheme.colorScheme.onError,
              size: 24,
            ),
          ),
          secondaryBackground: Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16),
            child: CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.darkTheme.colorScheme.onError,
              size: 24,
            ),
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getNotificationColor().withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkTheme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor().withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getNotificationIcon(),
                      color: _getNotificationColor(),
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notification['title'],
                        style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                          color: _getNotificationColor(),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.notification['message'],
                        style: AppTheme.darkTheme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatTimestamp(widget.notification['timestamp']),
                        style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _handleDismiss,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}