import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResearchQueueWidget extends StatelessWidget {
  final List<Map<String, dynamic>> queue;
  final VoidCallback onClose;
  final Function(int, int) onReorder;

  const ResearchQueueWidget({
    super.key,
    required this.queue,
    required this.onClose,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: AppTheme.darkTheme.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'queue',
                  color: AppTheme.darkTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Research Queue',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.darkTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Queue Items
          Expanded(
            child: queue.isEmpty
                ? _buildEmptyQueue()
                : ReorderableListView.builder(
                    padding: EdgeInsets.all(2.w),
                    itemCount: queue.length,
                    onReorder: onReorder,
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      return _buildQueueItem(item, index,
                          key: ValueKey(item['id']));
                    },
                  ),
          ),

          // Queue Actions
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.darkTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pauseAllResearch(),
                  icon: CustomIconWidget(
                    iconName: 'pause',
                    color: AppTheme.darkTheme.colorScheme.onPrimary,
                    size: 16,
                  ),
                  label: Text('Pause All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
                SizedBox(height: 1.h),
                OutlinedButton.icon(
                  onPressed: () => _clearQueue(),
                  icon: CustomIconWidget(
                    iconName: 'clear_all',
                    color: AppTheme.darkTheme.colorScheme.error,
                    size: 16,
                  ),
                  label: Text(
                    'Clear Queue',
                    style:
                        TextStyle(color: AppTheme.darkTheme.colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: AppTheme.darkTheme.colorScheme.error),
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'science',
            color:
                AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Active Research',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap on research nodes to start new research projects',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> item, int index,
      {required Key key}) {
    final progress = item['progress'] as double;
    final timeRemaining = item['timeRemaining'] as int;
    final priority = item['priority'] as int;

    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: index == 0
              ? AppTheme.darkTheme.colorScheme.primary
              : AppTheme.darkTheme.dividerColor,
          width: index == 0 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority and drag handle
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppTheme.darkTheme.colorScheme.primary
                      : AppTheme.darkTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkTheme.colorScheme.primary,
                  ),
                ),
                child: Center(
                  child: Text(
                    priority.toString(),
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: index == 0
                          ? AppTheme.darkTheme.colorScheme.onPrimary
                          : AppTheme.darkTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  item['name'] as String,
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    fontWeight:
                        index == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              CustomIconWidget(
                iconName: 'drag_handle',
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppTheme.darkTheme.dividerColor,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppTheme.darkTheme.colorScheme.primary
                      : AppTheme.darkTheme.colorScheme.primary
                          .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Progress Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: AppTheme.darkTheme.textTheme.labelSmall,
              ),
              Text(
                _formatTime(timeRemaining),
                style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _pauseResearch(item['id'] as String),
                  icon: CustomIconWidget(
                    iconName: index == 0 ? 'pause' : 'play_arrow',
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  label: Text(
                    index == 0 ? 'Pause' : 'Resume',
                    style: TextStyle(color: AppTheme.warningColor),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _cancelResearch(item['id'] as String),
                  icon: CustomIconWidget(
                    iconName: 'cancel',
                    color: AppTheme.darkTheme.colorScheme.error,
                    size: 16,
                  ),
                  label: Text(
                    'Cancel',
                    style:
                        TextStyle(color: AppTheme.darkTheme.colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  void _pauseAllResearch() {
    // Implement pause all research logic
  }

  void _clearQueue() {
    // Implement clear queue logic
  }

  void _pauseResearch(String researchId) {
    // Implement pause specific research logic
  }

  void _cancelResearch(String researchId) {
    // Implement cancel specific research logic
  }
}
