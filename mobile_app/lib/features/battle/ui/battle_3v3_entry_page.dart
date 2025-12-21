import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../battle_routes.dart';

class Battle3v3EntryPage extends StatefulWidget {
  const Battle3v3EntryPage({super.key});
  static const routeName = BattleRoutes.v3Entry;

  @override
  State<Battle3v3EntryPage> createState() => _Battle3v3EntryPageState();
}

class _Battle3v3EntryPageState extends State<Battle3v3EntryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          '3v3 Team Battle',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),

        // ---- NEW TABBAR STYLE ----
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF141428),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 1.2,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
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
                  Tab(text: 'Create team'),
                  Tab(text: 'Join by code'),
                ],
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

  // ------------------------------------------------------------------------
  // --------------------------- CREATE TEAM TAB -----------------------------
  // ------------------------------------------------------------------------

  Widget _buildCreateTab(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A 3v3 battle always includes all three skills: Listening, Reading, and Writing.\nEach player must pick exactly one unique role.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
          ),

          const Spacer(),

          // ---- CREATE TEAM BUTTON ----
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  BattleRoutes.v3Lobby,
                  arguments: {
                    'roomCode': 'TEAM1',
                    'isHost': true,
                  },
                );
              },
              child: const Text(
                'Create team room',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // ---------------------------- JOIN TEAM TAB -----------------------------
  // ------------------------------------------------------------------------

  Widget _buildJoinTab(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
          const SizedBox(height: 8),

          TextField(
            controller: _codeCtrl,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. TEAM1',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: const Color(0xFF141428),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            'You will automatically be placed in Team A or Team B depending on available slots.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              height: 1.3,
            ),
          ),

          const Spacer(),

          // ---- JOIN TEAM BUTTON ----
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  BattleRoutes.v3Lobby,
                  arguments: {
                    'roomCode': _codeCtrl.text.trim().isEmpty
                        ? 'TEAM'
                        : _codeCtrl.text.trim().toUpperCase(),
                    'isHost': false,
                  },
                );
              },
              child: const Text(
                'Join team room',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
