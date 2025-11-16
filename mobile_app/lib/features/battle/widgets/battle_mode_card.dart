import 'package:flutter/material.dart';

class BattleModeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool compact;

  const BattleModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<BattleModeCard> createState() => _BattleModeCardState();
}

class _BattleModeCardState extends State<BattleModeCard> {
  bool _hoverOrTap = false;

  @override
  Widget build(BuildContext context) {
    final scale = _hoverOrTap ? 1.03 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoverOrTap = true),
      onExit: (_) => setState(() => _hoverOrTap = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hoverOrTap = true),
        onTapCancel: () => setState(() => _hoverOrTap = false),
        onTapUp: (_) => setState(() => _hoverOrTap = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(widget.compact ? 12 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.compact ? 18 : 22),
              gradient: LinearGradient(
                colors: [
                  widget.gradientColors[0].withOpacity(0.22),
                  widget.gradientColors[1].withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _hoverOrTap
                    ? widget.gradientColors[0]
                    : Colors.white10,
                width: 1.4,
              ),
              boxShadow: _hoverOrTap
                  ? [
                      BoxShadow(
                        color: widget.gradientColors[0].withOpacity(0.7),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: widget.compact ? 44 : 52,
                  height: widget.compact ? 44 : 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.black,
                    size: widget.compact ? 24 : 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
