import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/domain_model.dart';
import '../data/unit_model.dart';
import '../data/lesson_model.dart';
import '../data/mock/mock_data.dart';
import '../learning_routes.dart';
import 'unit_detail_page.dart';
import 'domain_selector_bottom_sheet.dart';

class CurriculumBrowserPage extends StatefulWidget {
  const CurriculumBrowserPage({super.key});

  static const routeName = LearningRoutes.curriculumBrowser;

  @override
  State<CurriculumBrowserPage> createState() => _CurriculumBrowserPageState();
}

class _CurriculumBrowserPageState extends State<CurriculumBrowserPage> {
  Domain? _selectedDomain;

  @override
  void initState() {
    super.initState();
    _selectedDomain = MockLearningData.englishDomain();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Curriculum'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () async {
              final domain = await DomainSelectorBottomSheet.show(
                context,
                currentDomain: _selectedDomain,
              );
              if (domain != null) {
                setState(() => _selectedDomain = domain);
              }
            },
          ),
        ],
      ),
      body: _selectedDomain == null
          ? Center(
              child: Text(
                'Select a domain',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _selectedDomain!.color.withOpacity(0.2),
                          _selectedDomain!.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedDomain!.color.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDomain!.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDomain!.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Units
                  Text(
                    'Units',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedDomain!.units.map((unit) => _UnitCard(
                    unit: unit,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UnitDetailPage(unit: unit),
                        ),
                      );
                    },
                  )),
                ],
              ),
            ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Unit unit;
  final VoidCallback onTap;

  const _UnitCard({
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unit.color.withOpacity(0.2),
                  border: Border.all(color: unit.color),
                ),
                child: Icon(Icons.book, color: unit.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${unit.lessons.length} lessons',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

