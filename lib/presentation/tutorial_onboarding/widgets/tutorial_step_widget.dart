import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import './gesture_hint_widget.dart';
import './tutorial_battlefield_widget.dart';

class TutorialStepWidget extends StatefulWidget {
  final Map<String, dynamic> step;
  final VoidCallback onPracticeCompleted;

  const TutorialStepWidget({
    super.key,
    required this.step,
    required this.onPracticeCompleted,
  });

  @override
  State<TutorialStepWidget> createState() => _TutorialStepWidgetState();
}

class _TutorialStepWidgetState extends State<TutorialStepWidget>
    with TickerProviderStateMixin {
  late AnimationController _highlightController;
  late AnimationController _gestureController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gestureAnimation;

  bool _practiceCompleted = false;
  bool _showPractice = false;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _gestureController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));

    _gestureAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gestureController,
      curve: Curves.easeInOut,
    ));

    _highlightController.repeat(reverse: true);
    _gestureController.repeat();

    // Show practice mode after introduction
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && widget.step["practiceRequired"] == true) {
        setState(() {
          _showPractice = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _gestureController.dispose();
    super.dispose();
  }

  void _onPracticeInteraction() {
    if (!_practiceCompleted) {
      HapticFeedback.mediumImpact();
      setState(() {
        _practiceCompleted = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onPracticeCompleted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header section
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.step["title"] ?? "",
                style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.step["description"] ?? "",
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Battlefield demonstration area
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  // Battlefield background
                  TutorialBattlefieldWidget(
                    stepType: widget.step["type"] ?? "",
                    onInteraction: _onPracticeInteraction,
                    practiceCompleted: _practiceCompleted,
                  ),

                  // Highlight overlay
                  if (widget.step["highlightArea"] != null)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final highlight = widget.step["highlightArea"];
                        return Positioned(
                          left: MediaQuery.of(context).size.width *
                              highlight["x"],
                          top: MediaQuery.of(context).size.height *
                              0.3 *
                              highlight["y"],
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  highlight["width"],
                              height: MediaQuery.of(context).size.height *
                                  0.3 *
                                  highlight["height"],
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.accentColor,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Gesture hint
                  if (_showPractice && !_practiceCompleted)
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: GestureHintWidget(
                        gestureType: widget.step["gestureHint"] ?? "tap",
                        animation: _gestureAnimation,
                      ),
                    ),

                  // Success overlay
                  if (_practiceCompleted)
                    Container(
                      color: AppTheme.successColor.withValues(alpha: 0.2),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.successColor,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Well Done!',
                              style: AppTheme.darkTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Practice instruction
        if (widget.step["practiceRequired"] == true && !_practiceCompleted)
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'touch_app',
                  color: AppTheme.darkTheme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Try it yourself! ${_getPracticeInstruction(widget.step["type"])}',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 80), // Space for navigation buttons
      ],
    );
  }

  String _getPracticeInstruction(String stepType) {
    switch (stepType) {
      case "unit_selection":
        return "Tap on the highlighted unit to select it.";
      case "movement":
        return "Drag from the unit to move it to a new position.";
      case "resources":
        return "Move your unit to the resource node.";
      case "combat":
        return "Select your unit and tap on the enemy to attack.";
      case "multi_select":
        return "Drag to select multiple units at once.";
      case "victory":
        return "Tap on the enemy structure to destroy it.";
      default:
        return "Follow the on-screen instructions.";
    }
  }
}
