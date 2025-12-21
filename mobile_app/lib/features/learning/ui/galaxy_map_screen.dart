import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/unit_service.dart';
import '../data/unit_model.dart';
import '../data/lesson_model.dart';
import '../data/lesson_service.dart';

import '../widgets/starfield.dart';
import '../widgets/orbit_ring.dart';
import '../widgets/skill_planet.dart';
import '../widgets/planet_fx.dart';
import '../widgets/lesson_card.dart';

import 'lesson_detail_screen.dart';
import 'unit_detail_page.dart';

class GalaxyMapScreen extends StatefulWidget {
  const GalaxyMapScreen({super.key});
  @override
  State<GalaxyMapScreen> createState() => _GalaxyMapScreenState();
}

class _GalaxyMapScreenState extends State<GalaxyMapScreen> {
  final _svc = UnitService();
  final _scroll = ScrollController();
  List<Unit> _units = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final units = await _svc.fetchUnits();
    setState(() {
      _units = units;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1020) : null,
      appBar: AppBar(
        title: const Text("Galaxy Map"),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                const Positioned.fill(child: Starfield(count: 160)),
                ListView.builder(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  itemCount: _units.length,
                  itemBuilder: (context, i) {
                    final alignLeft = i.isEven; // zích zắc trái/phải
                    return _UnitSystemStrip(unit: _units[i], alignLeft: alignLeft);
                  },
                ),
              ],
            ),
    );
  }
}

/// 1 “strip” cao ~90% viewport, căn trái/phải luân phiên (zích zắc)
class _UnitSystemStrip extends StatefulWidget {
  final Unit unit;
  final bool alignLeft;
  const _UnitSystemStrip({required this.unit, required this.alignLeft});

  @override
  State<_UnitSystemStrip> createState() => _UnitSystemStripState();
}

class _UnitSystemStripState extends State<_UnitSystemStrip> with TickerProviderStateMixin {
  late final AnimationController _rotation;
  String? _expandedLessonId;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final orbitR = min(w, h) * 0.34;

    final align = widget.alignLeft ? Alignment.centerLeft : Alignment.centerRight;
    final sidePad = w * 0.08;

    return SizedBox(
      height: h * 0.9,
      child: Padding(
        padding: EdgeInsets.only(top: 24, bottom: 24, left: sidePad, right: sidePad),
        child: Stack(
          children: [
            Align(
              alignment: widget.alignLeft ? Alignment.topLeft : Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnitDetailPage(unit: widget.unit),
                    ),
                  );
                },
                child: Chip(
                  label: Text(widget.unit.title, style: const TextStyle(color: Colors.white)),
                  backgroundColor: widget.unit.color.withOpacity(0.18),
                  side: BorderSide(color: widget.unit.color.withOpacity(0.5)),
                ),
              ),
            ),
            Align(
              alignment: align,
              child: AnimatedBuilder(
                animation: _rotation,
                builder: (_, __) {
                  return SizedBox(
                    width: min(w, 560),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        OrbitRing(radius: orbitR * 1.1, color: Colors.white12, dashed: true),
                        _buildSun(orbitR, widget.unit.color),
                        ..._buildLessonPlanets(orbitR, _rotation.value),
                        if (_expandedLessonId != null) ..._buildSkillOrbitAndPlanets(orbitR * 0.55),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSun(double orbitR, Color color) {
    return Container(
      width: orbitR * 0.44,
      height: orbitR * 0.44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0)],
          stops: const [0, 1],
        ),
      ),
      child: Center(
        child: Container(
          width: orbitR * 0.2,
          height: orbitR * 0.2,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }

  List<Widget> _buildLessonPlanets(double r, double t) {
    final lessons = widget.unit.lessons;
    if (lessons.isEmpty) return const [];

    final widgets = <Widget>[];
    for (var i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];

      final angle = (2 * pi * i / lessons.length) + (2 * pi * t);
      final x = r * cos(angle);
      final y = r * sin(angle);

      final selected = _expandedLessonId == lesson.id;

      // ✅ FIX: suy ra status nếu model không có field status
      final LessonStatus status = (lesson.status) ?? _resolveStatus(i, lessons);

      final double progress01 = _to01(lesson.progress);

      widgets.add(
        Transform.translate(
          offset: Offset(x, y),
          child: Tooltip(
            message: "${lesson.title} – ${(progress01 * 100).round()}% completed",
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF141C34),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            textStyle: const TextStyle(color: Colors.white, fontSize: 12),
            child: PlanetFX(
              expanded: selected,
              child: PlanetButton(
                size: selected ? 68 : 52,
                color: _accentColorFor(lesson) ?? widget.unit.color,
                label: lesson.title,
                glow: selected || status == LessonStatus.completed,
                status: status,
                progress: progress01,
                onTap: () {
                  if (status == LessonStatus.locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bài này chưa mở khóa. Hoàn thành bài trước để mở!')),
                    );
                    return;
                  }
                  HapticFeedback.selectionClick();
                  setState(() => _expandedLessonId = selected ? null : lesson.id);
                },
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // ✅ FIX: không dùng _lessons (không tồn tại). Nhận vào index + danh sách lessons.
  LessonStatus _resolveStatus(int idx, List<Lesson> lessons) {
    final double cur = _to01(lessons[idx].progress);

    // completed nếu progress >= 1
    if (cur >= 1.0) return LessonStatus.completed;

    // locked nếu bài trước chưa completed (trừ bài đầu)
    if (idx > 0) {
      final double prev = _to01(lessons[idx - 1].progress);
      if (prev < 1.0) return LessonStatus.locked;
    }

    // còn lại là unlocked
    return LessonStatus.unlocked;
  }

  // Chuẩn hoá progress về [0,1], tránh NaN/null, hỗ trợ progress 0..100
  double _to01(double? p) {
    final v = (p ?? 0).clamp(0, 100);
    return v > 1 ? v / 100 : v.toDouble();
  }

  List<Widget> _buildSkillOrbitAndPlanets(double r) {
    final lesson = widget.unit.lessons.firstWhere((e) => e.id == _expandedLessonId);
    final color = _accentColorFor(lesson) ?? widget.unit.color;

    final ring = Positioned.fill(
      child: Center(child: OrbitRing(radius: r * 1.05, color: color.withOpacity(0.22))),
    );

    final skills = const [Skill.listening, Skill.speaking, Skill.reading, Skill.writing];
    final nodes = <Widget>[];
    for (var i = 0; i < skills.length; i++) {
      final angle = (pi / 2) * i - pi / 2;
      final x = r * cos(angle), y = r * sin(angle);
      final tag = 'skill_${lesson.id}_${skills[i].name}';

      nodes.add(
        Transform.translate(
          offset: Offset(x, y),
          child: SkillPlanet(
            skill: skills[i],
            color: color,
            heroTag: tag,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonDetailScreen(
                    lesson: lesson,
                    initialSkill: skills[i],
                    heroTag: tag,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final label = Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              // bạn có thể dùng Theme.of(context).textTheme nếu muốn
              Text('Chọn kỹ năng',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );

    return [ring, ...nodes, label];
  }

  Color? _accentColorFor(Lesson l) {
    try {
      final dynamic d = l;
      final c = d.color;
      if (c is Color) return c;
    } catch (_) {}
    final palette = <Color>[
      const Color(0xFF00C2FF),
      const Color(0xFFFF6B6B),
      const Color(0xFFF7B500),
      const Color(0xFF7C4DFF),
      const Color(0xFF2ECC71),
      const Color(0xFFFF8A65),
      const Color(0xFF26A69A),
    ];
    return palette[l.title.hashCode.abs() % palette.length];
  }
}
