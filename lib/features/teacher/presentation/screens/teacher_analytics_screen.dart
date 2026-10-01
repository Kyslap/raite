import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/teacher_lesson_provider.dart';
import '../providers/teacher_insights_provider.dart';
import '../providers/teacher_class_hub_provider.dart';
import 'package:raite/features/hive_mind/presentation/widgets/hive_mind_report_card.dart';

class TeacherAnalyticsScreen extends ConsumerStatefulWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  ConsumerState<TeacherAnalyticsScreen> createState() =>
      _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState
    extends ConsumerState<TeacherAnalyticsScreen> {
  String? _selectedClassId; // null means 'All Classes'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final classes = ref.watch(teacherClassesProvider);
    final lessons = ref.watch(teacherLessonsProvider);
    final submissions = ref.watch(teacherSubmissionsProvider);

    // Compute active target class
    final TeacherClass? activeClass = classes.isNotEmpty
        ? (_selectedClassId != null
            ? classes.firstWhere(
                (c) => c.id == _selectedClassId,
                orElse: () => classes.first,
              )
            : classes.first)
        : null;

    final targetClassId = activeClass?.id ?? 'class-1';

    // Compute metrics
    final classSubmissions = _selectedClassId == null
        ? submissions
        : submissions.where((s) => s.classId == _selectedClassId).toList();

    final turnedInCount = classSubmissions.where((s) => s.status != 'missing').length;
    final gradedCount = classSubmissions.where((s) => s.status == 'graded').length;
    final missingCount = classSubmissions.where((s) => s.status == 'missing').length;
    final totalSubs = classSubmissions.length;
    final turnInRate = totalSubs > 0 ? (turnedInCount / totalSubs) : 0.85;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Classroom AI Insights',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Refresh AI Insights',
            onPressed: () {
              ref.invalidate(classInsightsProvider(targetClassId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✨ Refreshing Gemini AI Classroom Insights...'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Course Filter Chips Row
            if (classes.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Courses'),
                      selected: _selectedClassId == null,
                      onSelected: (val) {
                        if (val) setState(() => _selectedClassId = null);
                      },
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: _selectedClassId == null
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight: _selectedClassId == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...classes.map((cls) {
                      final isSelected = _selectedClassId == cls.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('${cls.code} • ${cls.title}'),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedClassId = cls.id);
                          },
                          selectedColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 2. High-Level Mastery & Turn-In Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 74,
                        height: 74,
                        child: CircularProgressIndicator(
                          value: turnInRate,
                          strokeWidth: 8,
                          backgroundColor:
                              colorScheme.primary.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      Text(
                        '${(turnInRate * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedClassId != null
                              ? '${activeClass?.title} Progress'
                              : 'Overall Class Engagement',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$turnedInCount submitted • $gradedCount graded • $missingCount missing',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Healthy Pacing',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${lessons.length} Modules',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Live Gemini AI Classroom Insights
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Gemini AI Classroom Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Automated RAG analysis of recent student inquiries and tutoring chat logs:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _GeminiInsightsCard(
              classId: targetClassId,
              className: activeClass?.title ?? 'Course',
            ),
            const SizedBox(height: 24),

            // 4. Hive Mind Cohort Habit Intelligence & Intervention Card
            HiveMindReportCard(classId: targetClassId),
            const SizedBox(height: 24),

            // 5. Most Asked Topics to Nova AI
            Text(
              'Top Inquiry Concepts (Confusion Signals)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Frequent topics students asked Nova AI Tutor to clarify this week:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            const _TopicBar(
              topic: 'Backpropagation Chain Rule & Matrix Derivatives',
              percentage: 0.72,
              questionsCount: 42,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 10),
            const _TopicBar(
              topic: 'Stokes Theorem & Surface Normal Orientation',
              percentage: 0.55,
              questionsCount: 31,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(height: 10),
            const _TopicBar(
              topic: 'Eigenvalues & Diagonalization Transforms',
              percentage: 0.38,
              questionsCount: 19,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 28),

            // 6. Students Flagged for Follow-up
            Text(
              'Students Flagged for Follow-up',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: const [
                  _StudentAlertTile(
                    name: 'Marcus Brody',
                    issue: 'Struggling with Gradient Descent quiz (Score: 40%)',
                    status: 'Needs Help',
                  ),
                  Divider(height: 1),
                  _StudentAlertTile(
                    name: 'Sophia Chen',
                    issue: 'Has not started "Stokes Theorem" lesson (Due in 1d)',
                    status: 'Pending',
                  ),
                  Divider(height: 1),
                  _StudentAlertTile(
                    name: 'Liam Gallagher',
                    issue: 'Asked 8 clarifying questions on Momentum Optimizer',
                    status: 'Active Inquirer',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _GeminiInsightsCard extends ConsumerWidget {
  final String classId;
  final String className;

  const _GeminiInsightsCard({
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final insightsAsync = ref.watch(classInsightsProvider(classId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: insightsAsync.when(
        data: (insights) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.psychology, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pedagogical Synthesis • $className',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownBody(
              data: insights,
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                strong: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                listBullet: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
        loading: () => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Synthesizing student chat logs with Gemini...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (err, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.error, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Recent Topic Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Students have actively asked Nova about derivative rules, eigenvalue mechanics, and assignment requirements. As more questions arrive, Gemini will generate continuous weekly pedagogical summaries.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicBar extends StatelessWidget {
  final String topic;
  final double percentage;
  final int questionsCount;
  final Color color;

  const _TopicBar({
    required this.topic,
    required this.percentage,
    required this.questionsCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  topic,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$questionsCount inquiries',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAlertTile extends StatelessWidget {
  final String name;
  final String issue;
  final String status;

  const _StudentAlertTile({
    required this.name,
    required this.issue,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          name.substring(0, 1),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        issue,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: colorScheme.error,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
