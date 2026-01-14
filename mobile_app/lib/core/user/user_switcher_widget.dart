import 'package:flutter/material.dart';
import 'user_context_service.dart';

/// Demo widget to switch between users (user_1, user_2, etc.)
/// Useful for testing multi-user scenarios without full auth
class UserSwitcherWidget extends StatefulWidget {
  const UserSwitcherWidget({super.key});

  @override
  State<UserSwitcherWidget> createState() => _UserSwitcherWidgetState();
}

class _UserSwitcherWidgetState extends State<UserSwitcherWidget> {
  final UserContextService _userContext = UserContextService.instance;
  String _currentUserId = 'user_1';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _userContext.getUserId();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _switchUser(String userId) async {
    setState(() {
      _loading = true;
    });

    try {
      await _userContext.setUserId(userId);
      setState(() {
        _currentUserId = userId;
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to $userId'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current User',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentUserId,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Switch User (Demo)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildUserButton('user_1', isDark),
                _buildUserButton('user_2', isDark),
                _buildUserButton('user_3', isDark),
                _buildUserButton('user_4', isDark),
                _buildUserButton('user_5', isDark),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserButton(String userId, bool isDark) {
    final isSelected = _currentUserId == userId;

    return ElevatedButton(
      onPressed: _loading ? null : () => _switchUser(userId),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        foregroundColor: isSelected
            ? Colors.white
            : (isDark ? Colors.white : Colors.black87),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(userId),
    );
  }
}

