import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_num.dart';
import '../widgets/skill_planet.dart';
import '../data/learning_api_client.dart';
import '../data/lesson_model.dart';
import '../learning_routes.dart';
import 'exercise_player_page.dart';
import 'widgets/learning_loading_skeleton.dart';
import 'widgets/learning_error_state.dart';

class PracticeHubPage extends StatefulWidget {
  const PracticeHubPage({super.key});

  static const routeName = LearningRoutes.practiceHub;

  @override
  State<PracticeHubPage> createState() => _PracticeHubPageState();
}

class _PracticeHubPageState extends State<PracticeHubPage> {
  final _apiClient = LearningApiClient();
  Map<String, dynamic>? _practiceData;
  List<dynamic> weakSkillsData = []; // Store for use in _startPractice
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPracticeHub();
  }

  Future<void> _loadPracticeHub() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 5.8: Call GET /api/learning/practice/hub
      final data = await _apiClient.getPracticeHub();
      setState(() {
        _practiceData = data;
        weakSkillsData = data['weakSkills'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load practice hub: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _startPractice(String practiceType, {String? targetId}) async {
    try {
      // 5.8: Call POST /api/learning/practice/start
      final result = await _apiClient.startPractice(practiceType, targetId: targetId);
      
      // Parse result to get lesson/session info
      final lessonId = result['lessonId'] as String?;
      final attemptId = result['attemptId'] as String?;
      final sessionData = result['sessionData'] as Map<String, dynamic>?;
      
      if (mounted) {
        if (lessonId != null && attemptId != null) {
          // Create a minimal lesson object for navigation
          final lesson = Lesson(
            id: lessonId,
            title: result['lessonTitle'] as String? ?? 'Practice Lesson',
            description: result['description'] as String? ?? '',
            level: 'A1',
            progress: 0.0,
          );
          
          // Determine skill from practice type or result
          Skill? skill;
          if (targetId != null) {
            // Try to find skill from weakSkillsData
            final skillData = weakSkillsData.firstWhere(
              (s) => (s['skillId'] as String?) == targetId,
              orElse: () => null,
            );
            if (skillData != null) {
              final mode = skillData['mode'] as String? ?? 'reading';
              switch (mode.toLowerCase()) {
                case 'listening':
                  skill = Skill.listening;
                  break;
                case 'speaking':
                  skill = Skill.speaking;
                  break;
                case 'reading':
                  skill = Skill.reading;
                  break;
                case 'writing':
                  skill = Skill.writing;
                  break;
              }
            }
          }
          
          // Navigate to exercise player with session data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExercisePlayerPage(
                lesson: lesson,
                skill: skill,
                sessionData: sessionData ?? result,
              ),
            ),
          );
        } else {
          // Fallback: show message if navigation data incomplete
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Practice session started')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start practice: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: const Text('Practice Hub'),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: LearningLoadingSkeleton(itemCount: 3),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: const Text('Practice Hub'),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningErrorState(
          message: _error!,
          onRetry: _loadPracticeHub,
        ),
      );
    }

    // Parse API data
    final mistakeQuestions = _practiceData?['mistakeQuestions'] as List<dynamic>? ?? [];
    final spacedRepetitionQueue = _practiceData?['spacedRepetitionQueue'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Practice Hub'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Weak Skills',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focus on areas that need improvement',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weak skills
            if (weakSkillsData.isNotEmpty) ...[
              Text(
                'Skills to practice',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...weakSkillsData.map((skillData) {
                final skillId = skillData['skillId'] as String? ?? '';
                final mode = skillData['mode'] as String? ?? 'reading';
                final bestScore = JsonNum.asDoubleOr(skillData['bestScore'], 0.0);
                
                // Map mode string to Skill enum
                Skill skill;
                switch (mode.toLowerCase()) {
                  case 'listening':
                    skill = Skill.listening;
                    break;
                  case 'speaking':
                    skill = Skill.speaking;
                    break;
                  case 'reading':
                    skill = Skill.reading;
                    break;
                  case 'writing':
                    skill = Skill.writing;
                    break;
                  default:
                    skill = Skill.reading;
                }
                
                return _SkillPracticeCard(
                  skill: skill,
                  bestScore: bestScore,
                  onTap: () {
                    // Start practice session for this skill
                    _startPractice('weak_skills', targetId: skillId);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 24),

            // Quick practice
            Text(
              'Quick practice',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (mistakeQuestions.isNotEmpty)
              _QuickPracticeCard(
                title: 'Review all mistakes',
                icon: Icons.rate_review,
                subtitle: '${mistakeQuestions.length} questions',
                onTap: () {
                  _startPractice('mistakes');
                },
              ),
            if (mistakeQuestions.isNotEmpty) const SizedBox(height: 12),
            if (spacedRepetitionQueue.isNotEmpty)
              _QuickPracticeCard(
                title: 'Spaced repetition',
                icon: Icons.refresh,
                subtitle: '${spacedRepetitionQueue.length} items',
                onTap: () {
                  _startPractice('spaced_repetition');
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SkillPracticeCard extends StatelessWidget {
  final Skill skill;
  final double bestScore;
  final VoidCallback onTap;

  const _SkillPracticeCard({
    required this.skill,
    this.bestScore = 0.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Icon(skill.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bestScore > 0 
                          ? 'Best score: ${(bestScore * 100).toStringAsFixed(0)}%'
                          : 'Practice this skill',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickPracticeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final VoidCallback onTap;

  const _QuickPracticeCard({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

