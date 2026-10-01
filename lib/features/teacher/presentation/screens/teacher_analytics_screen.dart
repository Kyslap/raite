import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherAnalyticsScreen extends ConsumerWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Mastery Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
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
                          value: 0.84,
                          strokeWidth: 8,
                          backgroundColor:
                              colorScheme.primary.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      Text(
                        '84%',
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
                          'Average Lesson Mastery',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Students have completed 84% of required lesson modules across your 3 classes.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Topic Inquiries Heatmap
            Text(
              'Most Asked Topics to Lai AI',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time student confusion signals captured during AI Tutor sessions:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _TopicBar(
              topic: 'Backpropagation Chain Rule',
              percentage: 0.72,
              questionsCount: 42,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 10),
            _TopicBar(
              topic: 'Stokes Theorem Vector Normal',
              percentage: 0.55,
              questionsCount: 31,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 10),
            _TopicBar(
              topic: 'Eigenvalues & Coordinate Transforms',
              percentage: 0.38,
              questionsCount: 19,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 28),

            // Students Needing Review
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topic,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
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
              backgroundColor: const Color(0xFFF3F4F6),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          name.substring(0, 1),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
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
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: const TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
