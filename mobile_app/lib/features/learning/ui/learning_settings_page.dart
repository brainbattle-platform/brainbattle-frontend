import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../learning_routes.dart';

class LearningSettingsPage extends StatefulWidget {
  const LearningSettingsPage({super.key});

  static const routeName = LearningRoutes.learningSettings;

  @override
  State<LearningSettingsPage> createState() => _LearningSettingsPageState();
}

class _LearningSettingsPageState extends State<LearningSettingsPage> {
  bool _soundEnabled = true;
  bool _speakingEnabled = true;
  bool _remindersEnabled = true;
  int _dailyGoal = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Learning Settings'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Daily goal
          _SettingsSection(
            title: 'Daily Goal',
            children: [
              _SettingsTile(
                leading: const Icon(Icons.timer),
                title: 'Minutes per day',
                trailing: Text('$_dailyGoal min'),
                onTap: () {
                  // Navigate to goal picker
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Learning preferences
          _SettingsSection(
            title: 'Learning Preferences',
            children: [
              _SettingsTile(
                leading: const Icon(Icons.volume_up),
                title: 'Sound effects',
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                ),
              ),
              _SettingsTile(
                leading: const Icon(Icons.mic),
                title: 'Speaking exercises',
                trailing: Switch(
                  value: _speakingEnabled,
                  onChanged: (v) => setState(() => _speakingEnabled = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notifications
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                leading: const Icon(Icons.notifications),
                title: 'Practice reminders',
                trailing: Switch(
                  value: _remindersEnabled,
                  onChanged: (v) => setState(() => _remindersEnabled = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: leading,
        title: Text(title),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

