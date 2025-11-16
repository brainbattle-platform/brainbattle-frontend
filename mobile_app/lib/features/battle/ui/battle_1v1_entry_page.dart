import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_1v1_lobby_page.dart';

class Battle1v1EntryPage extends StatefulWidget {
  const Battle1v1EntryPage({super.key});

  @override
  State<Battle1v1EntryPage> createState() => _Battle1v1EntryPageState();
}

class _Battle1v1EntryPageState extends State<Battle1v1EntryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _battleType = 'MIXED';
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: BBColors.darkBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '1v1 Duel',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF241837),
                    Color(0xFF141424),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFF0D0D18),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Create duel'),
                    Tab(text: 'Join by code'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildCreateTab(context),
          _buildJoinTab(context),
        ],
      ),
    );
  }

  // ---------- CREATE DUEL TAB ----------

  Widget _buildCreateTab(BuildContext context) {
    final theme = Theme.of(context);

    Widget modeTile({
      required String title,
      required String subtitle,
      required String value,
      required IconData icon,
    }) {
      final selected = _battleType == value;

      return GestureDetector(
        onTap: () => setState(() => _battleType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF151528),
                Color(0xFF10101E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : Colors.white.withOpacity(0.10),
              width: 1.4,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // left icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selected ? theme.colorScheme.primary : Colors.white10,
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.black : Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 10 questions
              const Text(
                '10 questions',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose battle mode',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          modeTile(
            title: 'Listening battle',
            subtitle: 'Listen to audio clips and pick the correct answer.',
            value: 'LISTENING',
            icon: Icons.headphones_rounded,
          ),
          modeTile(
            title: 'Reading battle',
            subtitle: 'Read passages and answer comprehension questions.',
            value: 'READING',
            icon: Icons.menu_book_rounded,
          ),
          modeTile(
            title: 'Writing battle',
            subtitle: 'Complete sentences or fix grammar & spelling.',
            value: 'WRITING',
            icon: Icons.edit_note_rounded,
          ),
          modeTile(
            title: 'Mixed (Listening + Reading + Writing)',
            subtitle: 'A mix of all three skills in a single duel.',
            value: 'MIXED',
            icon: Icons.auto_awesome_rounded,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                // TODO: call API create duel
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Battle1v1LobbyPage(
                      roomCode: 'AB37X',
                      battleType: _battleType,
                      isHost: true,
                    ),
                  ),
                );
              },
              child: const Text(
                'Create duel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- JOIN BY CODE TAB ----------

  Widget _buildJoinTab(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter room code',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _codeCtrl,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. AB37X',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF141428),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You will join a duel with mode chosen by the host.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                // TODO: call API join duel
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Battle1v1LobbyPage(
                      roomCode: _codeCtrl.text.trim().isEmpty
                          ? 'JOIN'
                          : _codeCtrl.text.trim().toUpperCase(),
                      battleType: 'UNKNOWN',
                      isHost: false,
                    ),
                  ),
                );
              },
              child: const Text(
                'Join duel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
