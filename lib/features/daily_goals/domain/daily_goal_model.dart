enum DailyTaskType {
  lesson,
  aiTutor,
  assignment,
  focusTimer,
  custom,
}

class DailyTaskItem {
  final String id;
  final String title;
  final String subtitle;
  final int rewardMinutes;
  final bool isCompleted;
  final DailyTaskType type;
  final DateTime? completedAt;

  const DailyTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.rewardMinutes = 15,
    this.isCompleted = false,
    this.type = DailyTaskType.custom,
    this.completedAt,
  });

  DailyTaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? rewardMinutes,
    bool? isCompleted,
    DailyTaskType? type,
    DateTime? completedAt,
  }) {
    return DailyTaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      rewardMinutes: rewardMinutes ?? this.rewardMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class DailyGoalModel {
  final int targetMinutes;
  final int completedMinutes;
  final int streakDays;
  final DateTime date;
  final List<DailyTaskItem> tasks;
  final bool isStreakExtendedToday;

  const DailyGoalModel({
    this.targetMinutes = 45,
    this.completedMinutes = 30,
    this.streakDays = 4,
    required this.date,
    this.tasks = const [],
    this.isStreakExtendedToday = false,
  });

  double get progress => targetMinutes > 0
      ? (completedMinutes / targetMinutes).clamp(0.0, 1.0)
      : 0.0;

  bool get isGoalMet => completedMinutes >= targetMinutes;

  int get minutesLeft => (targetMinutes - completedMinutes).clamp(0, targetMinutes);

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  DailyGoalModel copyWith({
    int? targetMinutes,
    int? completedMinutes,
    int? streakDays,
    DateTime? date,
    List<DailyTaskItem>? tasks,
    bool? isStreakExtendedToday,
  }) {
    return DailyGoalModel(
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      streakDays: streakDays ?? this.streakDays,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      isStreakExtendedToday: isStreakExtendedToday ?? this.isStreakExtendedToday,
    );
  }
}
