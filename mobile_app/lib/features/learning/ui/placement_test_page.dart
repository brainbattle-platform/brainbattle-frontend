import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../learning_routes.dart';
import '../core/placement_service.dart';

class PlacementTestPage extends StatefulWidget {
  final String domainId;

  const PlacementTestPage({
    super.key,
    this.domainId = 'english',
  });

  static const routeName = LearningRoutes.placementTest;

  @override
  State<PlacementTestPage> createState() => _PlacementTestPageState();
}

class _PlacementTestPageState extends State<PlacementTestPage> {
  int _currentQuestion = 0;
  final int _totalQuestions = 10;
  final Map<int, String> _answers = {};
  final Map<int, String> _correctAnswers = {
    0: 'Option 1',
    1: 'Option 2',
    2: 'Option 1',
    3: 'Option 3',
    4: 'Option 2',
    5: 'Option 1',
    6: 'Option 4',
    7: 'Option 2',
    8: 'Option 3',
    9: 'Option 1',
  }; // Mock correct answers
  DateTime? _startTime;
  final PlacementService _placementService = PlacementService.instance;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  int _calculateScore() {
    int correctCount = 0;
    for (int i = 0; i < _totalQuestions; i++) {
      if (_answers[i] == _correctAnswers[i]) {
        correctCount++;
      }
    }
    return correctCount;
  }

  Future<void> _finishTest() async {
    final correctCount = _calculateScore();
    final level = PlacementService.calculateLevel(correctCount, _totalQuestions);
    await _placementService.savePlacementLevel(widget.domainId, level);
    
    if (mounted) {
      setState(() {
        _currentQuestion = _totalQuestions; // Trigger result view
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentQuestion >= _totalQuestions) {
      // Show result
      final correctCount = _calculateScore();
      final level = PlacementService.calculateLevel(correctCount, _totalQuestions);
      final timeSpent = _startTime != null
          ? DateTime.now().difference(_startTime!).inSeconds
          : 0;

      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: const Text('Placement Test'),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Test Complete',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your level: ${level.label}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? BBColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  children: [
                    _ResultRow(
                      label: 'Score',
                      value: '$correctCount/$_totalQuestions',
                    ),
                    const SizedBox(height: 8),
                    _ResultRow(
                      label: 'Time',
                      value: '${(timeSpent / 60).ceil()} min',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to GalaxyMap (unlock logic already applied)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Start Learning'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text('Question ${_currentQuestion + 1}/$_totalQuestions'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestion + 1) / _totalQuestions,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Question (stub)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? BBColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Text(
                'Placement test question ${_currentQuestion + 1} (stub)',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options (stub)
            ...List.generate(4, (index) {
              final option = 'Option ${index + 1}';
              final isSelected = _answers[_currentQuestion] == option;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() => _answers[_currentQuestion] = option);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : (isDark ? BBColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white10 : Colors.black12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.white30 : Colors.black26),
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),

            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answers[_currentQuestion] == null
                    ? null
                    : () {
                        if (_currentQuestion < _totalQuestions - 1) {
                          setState(() => _currentQuestion++);
                        } else {
                          _finishTest();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestion < _totalQuestions - 1 ? 'Next' : 'Finish',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

