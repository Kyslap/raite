import 'package:flutter/material.dart';

enum HabitGapSeverity {
  low,
  moderate,
  critical,
}

enum InterventionActionType {
  scheduleReview,
  assignQuiz,
  pushFlashcards,
  extendDeadline,
  peerStudyGroup,
}

class CohortHabitMetric {
  final String title;
  final String category; // e.g., 'Active Recall', 'Time Management', 'Tutor Usage'
  final String topCohortStat;
  final String atRiskCohortStat;
  final String gapExplanation;
  final HabitGapSeverity severity;
  final IconData icon;

  const CohortHabitMetric({
    required this.title,
    required this.category,
    required this.topCohortStat,
    required this.atRiskCohortStat,
    required this.gapExplanation,
    required this.severity,
    required this.icon,
  });
}

class TeacherIntervention {
  final String id;
  final String title;
  final String description;
  final InterventionActionType actionType;
  final String impactRationale;
  final bool isApplied;

  const TeacherIntervention({
    required this.id,
    required this.title,
    required this.description,
    required this.actionType,
    required this.impactRationale,
    this.isApplied = false,
  });

  TeacherIntervention copyWith({
    String? id,
    String? title,
    String? description,
    InterventionActionType? actionType,
    String? impactRationale,
    bool? isApplied,
  }) {
    return TeacherIntervention(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      impactRationale: impactRationale ?? this.impactRationale,
      isApplied: isApplied ?? this.isApplied,
    );
  }
}

class HiveMindReport {
  final String classId;
  final String className;
  final String courseCode;
  final int totalStudents;
  final int topCohortCount;
  final int atRiskCohortCount;
  final double gapVariancePercentage; // e.g., 34.5%
  final String narrativeSummary;
  final List<CohortHabitMetric> habitMetrics;
  final List<TeacherIntervention> interventions;
  final DateTime generatedAt;

  const HiveMindReport({
    required this.classId,
    required this.className,
    required this.courseCode,
    required this.totalStudents,
    required this.topCohortCount,
    required this.atRiskCohortCount,
    required this.gapVariancePercentage,
    required this.narrativeSummary,
    required this.habitMetrics,
    required this.interventions,
    required this.generatedAt,
  });

  HiveMindReport copyWith({
    String? classId,
    String? className,
    String? courseCode,
    int? totalStudents,
    int? topCohortCount,
    int? atRiskCohortCount,
    double? gapVariancePercentage,
    String? narrativeSummary,
    List<CohortHabitMetric>? habitMetrics,
    List<TeacherIntervention>? interventions,
    DateTime? generatedAt,
  }) {
    return HiveMindReport(
      classId: classId ?? this.classId,
      className: className ?? this.className,
      courseCode: courseCode ?? this.courseCode,
      totalStudents: totalStudents ?? this.totalStudents,
      topCohortCount: topCohortCount ?? this.topCohortCount,
      atRiskCohortCount: atRiskCohortCount ?? this.atRiskCohortCount,
      gapVariancePercentage: gapVariancePercentage ?? this.gapVariancePercentage,
      narrativeSummary: narrativeSummary ?? this.narrativeSummary,
      habitMetrics: habitMetrics ?? this.habitMetrics,
      interventions: interventions ?? this.interventions,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

class StudentPeerNudge {
  final String id;
  final String courseCode;
  final String headline;
  final String habitInsight;
  final String actionPrompt;
  final String targetRoute;
  final IconData icon;

  const StudentPeerNudge({
    required this.id,
    required this.courseCode,
    required this.headline,
    required this.habitInsight,
    required this.actionPrompt,
    required this.targetRoute,
    required this.icon,
  });
}
