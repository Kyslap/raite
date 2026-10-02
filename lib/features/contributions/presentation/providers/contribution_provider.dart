import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/contribution_model.dart';

class ContributionState {
  final Map<String, ContributionDay> history; // key: 'yyyy-MM-dd'
  final ContributionStats stats;

  const ContributionState({
    required this.history,
    required this.stats,
  });

  ContributionDay getDay(DateTime date) {
    final key = _formatDateKey(date);
    return history[key] ?? ContributionDay(date: date, count: 0);
  }

  static String _formatDateKey(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class ContributionNotifier extends Notifier<ContributionState> {
  @override
  ContributionState build() {
    return _generateInitialState();
  }

  static String _formatKey(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static ContributionState _generateInitialState() {
    final history = <String, ContributionDay>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final random = Random(42); // Seeded for consistent realistic distribution

    // Generate 16 weeks (112 days) of past study activity
    for (int i = 112; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = _formatKey(date);

      // Realistic academic patterns: weekdays more active, occasional rest days
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      // Fixed 4-day streak leading up to and including today (i = 0, 1, 2, 3)
      final isRecentStreakDay = i >= 0 && i <= 3;
      final isDayBeforeStreak = i == 4; // Rest day 4 days ago to anchor current streak to exactly 4

      final bool hasActivity;
      if (isRecentStreakDay) {
        hasActivity = true;
      } else if (isDayBeforeStreak) {
        hasActivity = false;
      } else {
        final chance = isWeekend ? 0.45 : 0.78;
        hasActivity = random.nextDouble() < chance;
      }

      if (hasActivity) {
        final count = isRecentStreakDay
            ? random.nextInt(6) + 4
            : (random.nextDouble() < 0.2
                ? random.nextInt(12) + 6
                : random.nextInt(6) + 1);

        final flashcards = (count * 0.4).round() * 5;
        final quizzes = count > 5 ? 1 : 0;
        final tutor = (count * 0.3).round();
        final focusMins = count * 5;

        history[key] = ContributionDay(
          date: date,
          count: count,
          flashcardsReviewed: flashcards,
          quizzesTaken: quizzes,
          tutorQueries: tutor,
          focusMinutes: focusMins,
        );
      } else {
        history[key] = ContributionDay(date: date, count: 0);
      }
    }

    final stats = _computeStats(history, today);
    return ContributionState(history: history, stats: stats);
  }

  static ContributionStats _computeStats(
    Map<String, ContributionDay> history,
    DateTime today,
  ) {
    int total = 0;
    int activeDays = 0;
    int bestDay = 0;
    DateTime? bestDate;

    for (final day in history.values) {
      total += day.count;
      if (day.count > 0) activeDays++;
      if (day.count > bestDay) {
        bestDay = day.count;
        bestDate = day.date;
      }
    }

    // Calculate current streak backward from today
    int currentStreak = 0;
    DateTime checkDate = today;
    while (true) {
      final key = _formatKey(checkDate);
      final day = history[key];
      if (day != null && day.count > 0) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate longest streak across history
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedKeys = history.keys.toList()..sort();
    for (final k in sortedKeys) {
      if ((history[k]?.count ?? 0) > 0) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    return ContributionStats(
      totalCount: total,
      currentStreak: currentStreak,
      longestStreak: max(longestStreak, currentStreak),
      activeDays: activeDays,
      bestDayCount: bestDay,
      bestDayDate: bestDate,
    );
  }

  void addContributionPoints({
    int points = 1,
    int flashcards = 0,
    int quizzes = 0,
    int tutorQueries = 0,
    int focusMinutes = 0,
    int assignments = 0,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final key = _formatKey(today);

    final currentDay = state.history[key] ?? ContributionDay(date: today, count: 0);
    final updatedDay = currentDay.copyWith(
      count: currentDay.count + points,
      flashcardsReviewed: currentDay.flashcardsReviewed + flashcards,
      quizzesTaken: currentDay.quizzesTaken + quizzes,
      tutorQueries: currentDay.tutorQueries + tutorQueries,
      focusMinutes: currentDay.focusMinutes + focusMinutes,
      assignmentsSubmitted: currentDay.assignmentsSubmitted + assignments,
    );

    final updatedHistory = Map<String, ContributionDay>.from(state.history);
    updatedHistory[key] = updatedDay;

    final updatedStats = _computeStats(updatedHistory, today);
    state = ContributionState(history: updatedHistory, stats: updatedStats);
  }

  void recordFlashcards(int count) {
    final points = max(1, (count / 5).ceil());
    addContributionPoints(points: points, flashcards: count);
  }

  void recordQuizCompleted() {
    addContributionPoints(points: 2, quizzes: 1);
  }

  void recordTutorQuery() {
    addContributionPoints(points: 1, tutorQueries: 1);
  }

  void recordFocusMinutes(int minutes) {
    final points = max(1, (minutes / 15).floor() * 2);
    addContributionPoints(points: points, focusMinutes: minutes);
  }

  void recordAssignmentSubmitted() {
    addContributionPoints(points: 3, assignments: 1);
  }
}

final contributionProvider =
    NotifierProvider<ContributionNotifier, ContributionState>(
  ContributionNotifier.new,
);
