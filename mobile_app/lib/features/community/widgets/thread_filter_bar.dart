import 'package:flutter/material.dart';

enum ThreadFilter { all, unread, groups }

class ThreadFilterBar extends StatelessWidget {
  final ThreadFilter value;
  final Color accent;
  final ValueChanged<ThreadFilter> onChanged;

  const ThreadFilterBar({
    super.key,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterPill(
          label: 'All',
          selected: value == ThreadFilter.all,
          accent: accent,
          onTap: () => onChanged(ThreadFilter.all),
        ),
        const SizedBox(width: 8),
        _FilterPill(
          label: 'Unread',
          selected: value == ThreadFilter.unread,
          accent: accent,
          onTap: () => onChanged(ThreadFilter.unread),
        ),
        const SizedBox(width: 8),
        _FilterPill(
          label: 'Clans',
          selected: value == ThreadFilter.groups,
          accent: accent,
          onTap: () => onChanged(ThreadFilter.groups),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.25) : const Color(0xFF2F2941),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
