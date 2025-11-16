import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_3v3_lobby_page.dart';

class Battle3v3EntryPage extends StatefulWidget {
  const Battle3v3EntryPage({super.key});

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('3v3 Team Battle'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Create team'),
            Tab(text: 'Join by code'),
          ],
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

  Widget _buildCreateTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Một trận 3v3 sẽ luôn có đủ 3 phần: Listening, Reading, Writing.\nMỗi người pick 1 vai trò duy nhất.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // TODO: tạo room 3v3
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const Battle3v3LobbyPage(
                      roomCode: 'TEAM1',
                      isHost: true,
                    ),
                  ),
                );
              },
              child: const Text(
                'Create team room',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã phòng',
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
              hintText: 'VD: TEAM1',
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
            'Bạn sẽ được gán vào Team A hoặc Team B tùy theo slot trống.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Battle3v3LobbyPage(
                      roomCode: _codeCtrl.text.trim().isEmpty
                          ? 'TEAM'
                          : _codeCtrl.text.trim().toUpperCase(),
                      isHost: false,
                    ),
                  ),
                );
              },
              child: const Text(
                'Join team room',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
