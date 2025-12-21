import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../battle_routes.dart';
import '../widgets/battle_mode_card.dart';

class BattleQueuePage extends StatefulWidget {
  const BattleQueuePage({super.key});
  static const routeName = BattleRoutes.mode;

  @override
  State<BattleQueuePage> createState() => _BattleQueuePageState();
}

class _BattleQueuePageState extends State<BattleQueuePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.02, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open1v1Entry() async {
    await Navigator.of(context).pushNamed(BattleRoutes.v1Entry);
  }

  Future<void> _open3v3Entry() async {
    await Navigator.of(context).pushNamed(BattleRoutes.v3Entry);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BBColors.darkBg,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(   // <— FIX OVERFLOW
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BattleHeader(),
                  const SizedBox(height: 14),

                  // Quick 1v1
                  BattleModeCard(
                    title: 'Quick 1v1 battle',
                    subtitle:
                        'Instantly match with a random opponent. Mode is auto-picked.',
                    icon: Icons.flash_on_rounded,
                    gradientColors: const [
                      Color(0xFFF3B4C3),
                      Color(0xFFE86FFF),
                    ],
                    onTap: _open1v1Entry,
                  ),

                  const SizedBox(height: 16),

                  // Create & Join
                  Row(
                    children: [
                      Expanded(
                        child: BattleModeCard(
                          compact: true,
                          title: 'Create 1v1',
                          subtitle: 'Choose Listening / Reading / Writing.',
                          icon: Icons.add_circle_outline_rounded,
                          gradientColors: const [
                            Color(0xFF7C4DFF),
                            Color(0xFFB388FF),
                          ],
                          onTap: _open1v1Entry,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BattleModeCard(
                          compact: true,
                          title: 'Join room',
                          subtitle: 'Enter a room code from your friend.',
                          icon: Icons.meeting_room_rounded,
                          gradientColors: const [
                            Color(0xFF4DD0E1),
                            Color(0xFF26C6DA),
                          ],
                          onTap: _open1v1Entry,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3v3 Team battle
                  BattleModeCard(
                    title: '3v3 Team battle',
                    subtitle:
                        'Split into Listening / Reading / Writing roles like a MOBA.',
                    icon: Icons.groups_3_rounded,
                    gradientColors: const [
                      Color(0xFF4DD0E1),
                      Color(0xFF7C4DFF),
                    ],
                    onTap: _open3v3Entry,
                  ),

                  const SizedBox(height: 20),

                  // Leaderboard
                  const _LeaderboardSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================== HEADER ==================

class _BattleHeader extends StatelessWidget {
  const _BattleHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF241837),
            Color(0xFF141424),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE86FFF).withOpacity(0.18),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Glowing icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF3B4C3),
                  Color(0xFFE86FFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battle Arena',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Real-time English battles with players worldwide.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== LEADERBOARD ==================

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection();

  List<_Leader> get _topPlayers => const [
        _Leader(rank: 1, name: 'A', rating: 1820, streak: 7),
        _Leader(rank: 2, name: 'B', rating: 1765, streak: 5),
        _Leader(rank: 3, name: 'C', rating: 1710, streak: 3),
        _Leader(rank: 4, name: 'D', rating: 1690, streak: 2),
        _Leader(rank: 5, name: 'E', rating: 1655, streak: 1),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top players today',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Leaderboard container
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141428),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topPlayers.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              return _LeaderboardRow(player: _topPlayers[index]);
            },
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Recent battles (coming soon)',
          style: TextStyle(
            color: Colors.white30,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// Player Model
class _Leader {
  final int rank;
  final String name;
  final int rating;
  final int streak;

  const _Leader({
    required this.rank,
    required this.name,
    required this.rating,
    required this.streak,
  });
}

// UI Row
class _LeaderboardRow extends StatelessWidget {
  final _Leader player;

  const _LeaderboardRow({required this.player});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData? badgeIcon;

    switch (player.rank) {
      case 1:
        badgeColor = const Color(0xFFFFD54F);
        badgeIcon = Icons.emoji_events_rounded;
        break;
      case 2:
        badgeColor = const Color(0xFFB0BEC5);
        badgeIcon = Icons.emoji_events_rounded;
        break;
      case 3:
        badgeColor = const Color(0xFF8D6E63);
        badgeIcon = Icons.emoji_events_rounded;
        break;
      default:
        badgeColor = Colors.white24;
        badgeIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor.withOpacity(0.18),
            ),
            alignment: Alignment.center,
            child: badgeIcon != null
                ? Icon(badgeIcon, size: 18, color: badgeColor)
                : Text(
                    '#${player.rank}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),

          const SizedBox(width: 10),

          // Player name & rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rating • ${player.rating}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Win streak
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 14, color: Colors.orangeAccent),
              const SizedBox(width: 3),
              Text(
                '${player.streak} win streak',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
