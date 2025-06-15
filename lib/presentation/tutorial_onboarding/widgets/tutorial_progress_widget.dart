import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TutorialProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const TutorialProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentStep + 1) / totalSteps,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              final isCurrent = index == currentStep;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 12 : 8,
                  height: isCurrent ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.darkTheme.colorScheme.primary
                        : AppTheme.darkTheme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: AppTheme.accentColor,
                            width: 2,
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Step counter
          Text(
            '${currentStep + 1} of $totalSteps',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
