import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/daily_goal_model.dart';
import 'package:raite/features/contributions/presentation/providers/contribution_provider.dart';

final dailyGoalsProvider =
    NotifierProvider<DailyGoalsNotifier, DailyGoalModel>(DailyGoalsNotifier.new);

class DailyGoalsNotifier extends Notifier<DailyGoalModel> {
  @override
  DailyGoalModel build() {
    return _initialGoal();
  }

  static DailyGoalModel _initialGoal() {
    return DailyGoalModel(
      targetMinutes: 45,
      completedMinutes: 20,
      streakDays: 4,
      date: DateTime.now(),
      isStreakExtendedToday: false,
      tasks: [
        const DailyTaskItem(
          id: 'task-read-lesson',
          title: 'Review Course Material',
          subtitle: 'Read through today\'s syllabus topic or lesson',
          rewardMinutes: 15,
          type: DailyTaskType.lesson,
          isCompleted: false,
        ),
        const DailyTaskItem(
          id: 'task-ai-tutor',
          title: 'Ask Lai AI Tutor',
          subtitle: 'Clarify a concept or solve a problem with AI',
          rewardMinutes: 10,
          type: DailyTaskType.aiTutor,
          isCompleted: false,
        ),
        const DailyTaskItem(
          id: 'task-assignment',
          title: 'Check Deadlines & Assignments',
          subtitle: 'Work on an upcoming submission or review feedback',
          rewardMinutes: 15,
          type: DailyTaskType.assignment,
          isCompleted: false,
        ),
        const DailyTaskItem(
          id: 'task-focus-timer',
          title: 'Dedicated Study Focus',
          subtitle: 'Complete at least 15 mins of focused study timer',
          rewardMinutes: 15,
          type: DailyTaskType.focusTimer,
          isCompleted: false,
        ),
      ],
    );
  }

  void setTargetMinutes(int target) {
    if (target <= 0) return;
    state = state.copyWith(targetMinutes: target);
    _checkGoalStreak();
  }

  void addMinutes(int minutes, {String? reason}) {
    if (minutes <= 0) return;
    final newMinutes = state.completedMinutes + minutes;
    state = state.copyWith(completedMinutes: newMinutes);
    _checkGoalStreak();
    // Record study time contribution
    ref.read(contributionProvider.notifier).recordFocusMinutes(minutes);
  }

  void toggleTask(String taskId) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == taskId) {
        final willBeCompleted = !task.isCompleted;
        return task.copyWith(
          isCompleted: willBeCompleted,
          completedAt: willBeCompleted ? DateTime.now() : null,
        );
      }
      return task;
    }).toList();

    // Recalculate completed minutes based on task rewards
    final changedTask = state.tasks.firstWhere((t) => t.id == taskId);
    int newMinutes = state.completedMinutes;
    if (!changedTask.isCompleted) {
      newMinutes += changedTask.rewardMinutes;
    } else {
      newMinutes = (newMinutes - changedTask.rewardMinutes).clamp(0, 999);
    }

    state = state.copyWith(
      tasks: updatedTasks,
      completedMinutes: newMinutes,
    );
    _checkGoalStreak();
  }

  void completeTask(String taskId) {
    final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;
    final task = state.tasks[taskIndex];
    if (task.isCompleted) return;

    final updatedTasks = List<DailyTaskItem>.from(state.tasks);
    updatedTasks[taskIndex] = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    state = state.copyWith(
      tasks: updatedTasks,
      completedMinutes: state.completedMinutes + task.rewardMinutes,
    );
    _checkGoalStreak();
  }

  void recordAiTutorInteraction() {
    // Record AI Tutor query contribution
    ref.read(contributionProvider.notifier).recordTutorQuery();
    // If AI Tutor task isn't completed, mark it complete; otherwise add 5 study minutes
    final aiTask = state.tasks.firstWhere((t) => t.id == 'task-ai-tutor');
    if (!aiTask.isCompleted) {
      completeTask('task-ai-tutor');
    } else {
      addMinutes(5, reason: 'Lai AI Tutor Session');
    }
  }

  void recordLessonStudied(String title) {
    final lessonTask = state.tasks.firstWhere((t) => t.id == 'task-read-lesson');
    if (!lessonTask.isCompleted) {
      completeTask('task-read-lesson');
    } else {
      addMinutes(10, reason: 'Reviewed $title');
    }
  }

  void recordAssignmentWorked(String title) {
    // Record assignment contribution
    ref.read(contributionProvider.notifier).recordAssignmentSubmitted();
    final assignTask = state.tasks.firstWhere((t) => t.id == 'task-assignment');
    if (!assignTask.isCompleted) {
      completeTask('task-assignment');
    } else {
      addMinutes(15, reason: 'Assignment $title');
    }
  }

  void recordFocusSessionCompleted(int sessionMinutes) {
    final timerTask = state.tasks.firstWhere((t) => t.id == 'task-focus-timer');
    if (!timerTask.isCompleted) {
      completeTask('task-focus-timer');
    }
    addMinutes(sessionMinutes, reason: 'Focus Timer Session');
  }

  void logOfflineStudy(int minutes, String notes) {
    addMinutes(minutes, reason: notes.isEmpty ? 'Offline Study' : notes);
  }

  void _checkGoalStreak() {
    if (state.completedMinutes >= state.targetMinutes && !state.isStreakExtendedToday) {
      // Extend streak
      state = state.copyWith(
        streakDays: state.streakDays + 1,
        isStreakExtendedToday: true,
      );
    }
  }
}
