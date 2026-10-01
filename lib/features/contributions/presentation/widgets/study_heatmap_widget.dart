import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/contribution_model.dart';
import '../providers/contribution_provider.dart';

class StudyHeatmapWidget extends ConsumerWidget {
  final bool isCompact;
  final String? title;

  const StudyHeatmapWidget({
    super.key,
    this.isCompact = false,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(contributionProvider);
    final stats = state.stats;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Total Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.grid_view_rounded, size: 18, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? 'Study Activity Matrix',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${stats.totalCount} contributions in 16 wks',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFEA580C)),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.currentStreak}d Streak',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Heatmap Grid
          _HeatmapGrid(state: state),

          const SizedBox(height: 14),

          // Footer: Legend & Streak stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Best: ${stats.longestStreak}d • Active: ${stats.activeDays}d',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  _LegendCell(color: _getIntensityColor(0, colorScheme)),
                  _LegendCell(color: _getIntensityColor(1, colorScheme)),
                  _LegendCell(color: _getIntensityColor(2, colorScheme)),
                  _LegendCell(color: _getIntensityColor(3, colorScheme)),
                  _LegendCell(color: _getIntensityColor(4, colorScheme)),
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _getIntensityColor(int intensity, ColorScheme colorScheme) {
    switch (intensity) {
      case 1:
        return const Color(0xFFC0DAC6);
      case 2:
        return const Color(0xFF7FA88B);
      case 3:
        return colorScheme.primaryContainer; // #4F7059
      case 4:
        return colorScheme.primary; // #375742
      case 0:
      default:
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }
  }
}

class _HeatmapGrid extends StatelessWidget {
  final ContributionState state;

  const _HeatmapGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build 16 weeks of data arranged in 7 rows (Mon to Sun)
    final numWeeks = 16;
    final totalDays = numWeeks * 7;
    // Align so the last day corresponds to today, and grid ends on current week's day
    final startDay = today.subtract(Duration(days: totalDays - 1));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // scroll to show the most recent weeks first
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 7 Rows of Days (Mon through Sun)
          for (int weekday = 1; weekday <= 7; weekday++)
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Row(
                children: [
                  // Weekday label column
                  SizedBox(
                    width: 24,
                    child: Text(
                      _getWeekdayLabel(weekday),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Weeks for this weekday
                  for (int week = 0; week < numWeeks; week++) ...[
                    _buildCellForWeekAndDay(
                      context,
                      startDay,
                      week,
                      weekday,
                      today,
                    ),
                    const SizedBox(width: 3.0),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getWeekdayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'M';
      case 3:
        return 'W';
      case 5:
        return 'F';
      case 7:
        return 'S';
      default:
        return '';
    }
  }

  Widget _buildCellForWeekAndDay(
    BuildContext context,
    DateTime startDay,
    int week,
    int targetWeekday,
    DateTime today,
  ) {
    final cellDate = startDay.add(Duration(days: (week * 7) + (targetWeekday - 1)));
    final isFuture = cellDate.isAfter(today);

    if (isFuture) {
      return const SizedBox(width: 14, height: 14);
    }

    final dayData = state.getDay(cellDate);
    final colorScheme = Theme.of(context).colorScheme;
    final cellColor = StudyHeatmapWidget._getIntensityColor(dayData.intensity, colorScheme);

    return InkWell(
      onTap: () => _showDayInspectionSheet(context, dayData),
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(3),
          border: dayData.intensity == 0
              ? Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.25), width: 0.5)
              : null,
        ),
      ),
    );
  }

  void _showDayInspectionSheet(BuildContext context, ContributionDay day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(day.date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormatted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.count > 0
                          ? '${day.count} Study Contributions'
                          : 'No recorded study activity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: day.count > 0 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: StudyHeatmapWidget._getIntensityColor(day.intensity, colorScheme),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${day.count}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: day.intensity >= 3 ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (day.count > 0) ...[
              Text(
                'ACTIVITY BREAKDOWN',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              if (day.flashcardsReviewed > 0)
                _BreakdownItem(
                  icon: Icons.style_outlined,
                  title: '${day.flashcardsReviewed} Flashcards Reviewed',
                  subtitle: 'Active recall spaced repetition practice',
                ),
              if (day.quizzesTaken > 0)
                _BreakdownItem(
                  icon: Icons.quiz_outlined,
                  title: '${day.quizzesTaken} Quiz Evaluated',
                  subtitle: 'Formative concept mastery test',
                ),
              if (day.tutorQueries > 0)
                _BreakdownItem(
                  icon: Icons.psychology_outlined,
                  title: '${day.tutorQueries} AI Tutor Inquiries',
                  subtitle: 'Deep concept clarification with Nova AI',
                ),
              if (day.focusMinutes > 0)
                _BreakdownItem(
                  icon: Icons.timer_outlined,
                  title: '${day.focusMinutes} Mins Focused Study',
                  subtitle: 'Dedicated Pomodoro focus session',
                ),
              if (day.assignmentsSubmitted > 0)
                _BreakdownItem(
                  icon: Icons.assignment_turned_in_outlined,
                  title: '${day.assignmentsSubmitted} Assignment Submitted',
                  subtitle: 'Academic coursework completed on time',
                ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.bedtime_outlined, size: 36, color: colorScheme.outline),
                      const SizedBox(height: 8),
                      Text(
                        'Rest & Recovery Day',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BreakdownItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendCell extends StatelessWidget {
  final Color color;

  const _LegendCell({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
