import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../domain/domain_model.dart';
import '../data/mock/mock_data.dart';

class DomainSelectorBottomSheet extends StatelessWidget {
  final Domain? currentDomain;
  final Function(Domain domain) onDomainSelected;

  const DomainSelectorBottomSheet({
    super.key,
    this.currentDomain,
    required this.onDomainSelected,
  });

  static Future<Domain?> show(BuildContext context, {Domain? currentDomain}) {
    return showModalBottomSheet<Domain>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? BBColors.darkBg
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DomainSelectorBottomSheet(
        currentDomain: currentDomain,
        onDomainSelected: (domain) => Navigator.pop(context, domain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final domains = [
      MockLearningData.englishDomain(),
      MockLearningData.programmingDomain(),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Domain',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...domains.map((domain) => _DomainTile(
            domain: domain,
            isSelected: currentDomain?.id == domain.id,
            onTap: () => onDomainSelected(domain),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DomainTile extends StatelessWidget {
  final Domain domain;
  final bool isSelected;
  final VoidCallback onTap;

  const _DomainTile({
    required this.domain,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isSelected
          ? domain.color.withOpacity(0.2)
          : (isDark ? BBColors.darkCard : Colors.white),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? domain.color
                  : (isDark ? Colors.white10 : Colors.black12),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: domain.color.withOpacity(0.2),
                  border: Border.all(color: domain.color),
                ),
                child: Icon(Icons.language, color: domain.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      domain.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

