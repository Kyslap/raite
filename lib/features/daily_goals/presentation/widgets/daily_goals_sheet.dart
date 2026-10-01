import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raite/main.dart';
import '../domain/daily_goal_model.dart';
import '../providers/daily_goals_provider.dart';
import 'study_timer_dialog.dart';

class DailyGoalsSheet extends ConsumerWidget {
  const DailyGoalsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DailyGoalsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final goal = ref.watch(dailyGoalsProvider);
    final notifier = ref.read(dailyGoalsProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFF97316),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${goal.streakDays}-Day Learning Streak',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Daily Study Desk Objectives',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Progress Banner Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TODAY\'S PROGRESS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${goal.completedMinutes} / ${goal.targetMinutes} mins',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(goal.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.isGoalMet ? const Color(0xFF4ADE80) : colorScheme.secondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            goal.isGoalMet ? Icons.verified_rounded : Icons.info_outline,
                            size: 16,
                            color: colorScheme.onPrimary.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              goal.isGoalMet
                                  ? '🎉 Daily goal achieved! Streak protected for today.'
                                  : '${goal.minutesLeft} minutes left to protect your streak',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary.withValues(alpha: 0.95),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Quick Actions: Focus Timer & Log Minutes
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          StudyTimerDialog.show(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.timer, size: 20),
                        label: const Text('Start Focus Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showQuickAddMinutesDialog(context, notifier);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text('Add Minutes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Daily Checklist Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DAILY ACTION TASKS',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${goal.completedTasksCount}/${goal.tasks.length} Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Checklist Items
                ...goal.tasks.map((task) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: task.isCompleted
                            ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                            : colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (val) {
                          notifier.toggleTask(task.id);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? colorScheme.onSurface.withValues(alpha: 0.6)
                              : colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        task.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${task.rewardMinutes}m',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildTaskActionButton(context, ref, task),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // 5. Customize Target Section
                Text(
                  'CUSTOMIZE DAILY TARGET',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [15, 30, 45, 60, 90].map((mins) {
                    final isSel = goal.targetMinutes == mins;
                    return ChoiceChip(
                      label: Text('$mins mins/day'),
                      selected: isSel,
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSel ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                      ),
                      onSelected: (val) {
                        if (val) {
                          notifier.setTargetMinutes(mins);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskActionButton(BuildContext context, WidgetRef ref, DailyTaskItem task) {
    return IconButton(
      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      tooltip: 'Go to action',
      onPressed: () {
        Navigator.of(context).pop();
        switch (task.type) {
          case DailyTaskType.lesson:
            // Switch to classes tab
            ref.read(studentBottomNavIndexProvider.notifier).setIndex(1);
            break;
          case DailyTaskType.aiTutor:
            // Switch to AI tutor tab
            ref.read(studentBottomNavIndexProvider.notifier).setIndex(2);
            break;
          case DailyTaskType.assignment:
            // Switch to classes tab to view assignments
            ref.read(studentBottomNavIndexProvider.notifier).setIndex(1);
            break;
          case DailyTaskType.focusTimer:
            StudyTimerDialog.show(context);
            break;
          case DailyTaskType.custom:
            break;
        }
      },
    );
  }

  void _showQuickAddMinutesDialog(BuildContext context, DailyGoalsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) {
        int selected = 15;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Quick Add Study Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select study duration to add to your daily goal:'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [5, 10, 15, 30, 45].map((m) {
                      final isSel = selected == m;
                      return ChoiceChip(
                        label: Text('+$m mins'),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => selected = m);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    notifier.addMinutes(selected);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Added +$selected mins to Daily Goal!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('Add +$selected Mins'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
