import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/tutorial_overlay_widget.dart';
import './widgets/tutorial_progress_widget.dart';
import './widgets/tutorial_step_widget.dart';

class TutorialOnboarding extends StatefulWidget {
  const TutorialOnboarding({super.key});

  @override
  State<TutorialOnboarding> createState() => _TutorialOnboardingState();
}

class _TutorialOnboardingState extends State<TutorialOnboarding>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  bool _isAnimating = false;
  bool _showSkipDialog = false;

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      "id": 1,
      "title": "Welcome to StrategyCommand",
      "description":
          "Master the art of real-time strategy warfare on mobile. Let's begin your tactical training.",
      "type": "introduction",
      "highlightArea": null,
      "gestureHint": "tap",
      "practiceRequired": false,
    },
    {
      "id": 2,
      "title": "Unit Selection",
      "description":
          "Tap on units to select them. Selected units will show a green highlight ring.",
      "type": "unit_selection",
      "highlightArea": {"x": 0.3, "y": 0.6, "width": 0.15, "height": 0.15},
      "gestureHint": "tap",
      "practiceRequired": true,
    },
    {
      "id": 3,
      "title": "Movement Commands",
      "description":
          "Drag from selected units to move them. Watch the movement path preview.",
      "type": "movement",
      "highlightArea": {"x": 0.6, "y": 0.4, "width": 0.2, "height": 0.2},
      "gestureHint": "drag",
      "practiceRequired": true,
    },
    {
      "id": 4,
      "title": "Resource Collection",
      "description":
          "Move units near resource nodes to automatically collect materials for your army.",
      "type": "resources",
      "highlightArea": {"x": 0.1, "y": 0.3, "width": 0.12, "height": 0.12},
      "gestureHint": "tap",
      "practiceRequired": true,
    },
    {
      "id": 5,
      "title": "Combat Basics",
      "description":
          "Select units and tap on enemies to attack. Different units have different combat ranges.",
      "type": "combat",
      "highlightArea": {"x": 0.7, "y": 0.5, "width": 0.18, "height": 0.18},
      "gestureHint": "tap",
      "practiceRequired": true,
    },
    {
      "id": 6,
      "title": "Multi-Unit Selection",
      "description":
          "Pinch and drag to select multiple units at once for coordinated attacks.",
      "type": "multi_select",
      "highlightArea": {"x": 0.2, "y": 0.4, "width": 0.4, "height": 0.3},
      "gestureHint": "pinch",
      "practiceRequired": true,
    },
    {
      "id": 7,
      "title": "Camera Controls",
      "description":
          "Pinch to zoom in/out and drag with two fingers to pan around the battlefield.",
      "type": "camera",
      "highlightArea": null,
      "gestureHint": "pinch",
      "practiceRequired": false,
    },
    {
      "id": 8,
      "title": "Victory Conditions",
      "description":
          "Destroy enemy structures and eliminate their forces to claim victory in battle.",
      "type": "victory",
      "highlightArea": {"x": 0.8, "y": 0.2, "width": 0.15, "height": 0.15},
      "gestureHint": "tap",
      "practiceRequired": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_isAnimating) return;

    HapticFeedback.lightImpact();

    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _isAnimating = true;
      });

      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      setState(() {
        _currentStep++;
        _isAnimating = false;
      });

      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() async {
    if (_isAnimating || _currentStep == 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isAnimating = true;
    });

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentStep--;
      _isAnimating = false;
    });

    _animationController.reset();
    _animationController.forward();
  }

  void _skipTutorial() {
    setState(() {
      _showSkipDialog = true;
    });
  }

  void _completeTutorial() async {
    HapticFeedback.heavyImpact();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/campaign-map');
    }
  }

  void _onPracticeCompleted() {
    HapticFeedback.mediumImpact();
    _nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkTheme.scaffoldBackgroundColor,
                    AppTheme.darkTheme.scaffoldBackgroundColor
                        .withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Main tutorial content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tutorialSteps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemBuilder: (context, index) {
                final step = _tutorialSteps[index];
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TutorialStepWidget(
                      step: step,
                      onPracticeCompleted: _onPracticeCompleted,
                    ),
                  ),
                );
              },
            ),

            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipTutorial,
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.darkTheme.colorScheme.surface
                      .withValues(alpha: 0.8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Skip',
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.darkTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Progress indicator
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: TutorialProgressWidget(
                currentStep: _currentStep,
                totalSteps: _tutorialSteps.length,
              ),
            ),

            // Navigation buttons
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isAnimating ? null : _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppTheme.darkTheme.colorScheme.primary,
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.darkTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _isAnimating ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkTheme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentStep == _tutorialSteps.length - 1
                            ? 'Complete'
                            : 'Next',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Skip confirmation dialog
            if (_showSkipDialog)
              TutorialOverlayWidget(
                title: 'Skip Tutorial?',
                description:
                    'Are you sure you want to skip the tutorial? You can always replay it from the settings menu.',
                onConfirm: () {
                  Navigator.pushReplacementNamed(context, '/campaign-map');
                },
                onCancel: () {
                  setState(() {
                    _showSkipDialog = false;
                  });
                },
              ),

            // Particle effects for completion
            if (_particleController.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter:
                            ParticleEffectPainter(_particleController.value),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ParticleEffectPainter extends CustomPainter {
  final double progress;

  ParticleEffectPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * 0.5) + (i * 30 * progress);
      final y = (size.height * 0.5) + (i * 20 * progress);
      final radius = 4 * (1.0 - progress);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
