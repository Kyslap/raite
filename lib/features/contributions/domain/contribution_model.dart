class ContributionDay {
  final DateTime date;
  final int count;
  final int flashcardsReviewed;
  final int quizzesTaken;
  final int tutorQueries;
  final int focusMinutes;
  final int assignmentsSubmitted;

  const ContributionDay({
    required this.date,
    required this.count,
    this.flashcardsReviewed = 0,
    this.quizzesTaken = 0,
    this.tutorQueries = 0,
    this.focusMinutes = 0,
    this.assignmentsSubmitted = 0,
  });

  int get intensity {
    if (count == 0) return 0;
    if (count <= 3) return 1;
    if (count <= 7) return 2;
    if (count <= 12) return 3;
    return 4;
  }

  ContributionDay copyWith({
    DateTime? date,
    int? count,
    int? flashcardsReviewed,
    int? quizzesTaken,
    int? tutorQueries,
    int? focusMinutes,
    int? assignmentsSubmitted,
  }) {
    return ContributionDay(
      date: date ?? this.date,
      count: count ?? this.count,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      tutorQueries: tutorQueries ?? this.tutorQueries,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      assignmentsSubmitted: assignmentsSubmitted ?? this.assignmentsSubmitted,
    );
  }
}

class ContributionStats {
  final int totalCount;
  final int currentStreak;
  final int longestStreak;
  final int activeDays;
  final int bestDayCount;
  final DateTime? bestDayDate;

  const ContributionStats({
    required this.totalCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDays,
    required this.bestDayCount,
    this.bestDayDate,
  });
}
