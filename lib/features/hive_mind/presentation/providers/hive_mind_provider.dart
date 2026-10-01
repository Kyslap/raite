import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/hive_mind_service.dart';
import '../../domain/hive_mind_model.dart';
import '../../../class/presentation/providers/class_provider.dart';

final hiveMindServiceProvider = Provider<HiveMindService>((ref) {
  return HiveMindService();
});

class ClassReportParams {
  final String classId;
  final String className;
  final String courseCode;

  const ClassReportParams({
    required this.classId,
    required this.className,
    required this.courseCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassReportParams &&
          runtimeType == other.runtimeType &&
          classId == other.classId &&
          className == other.className &&
          courseCode == other.courseCode;

  @override
  int get hashCode => classId.hashCode ^ className.hashCode ^ courseCode.hashCode;
}

final hiveMindReportProvider =
    FutureProvider.family<HiveMindReport, ClassReportParams>((ref, params) async {
  final service = ref.watch(hiveMindServiceProvider);
  return service.generateReportForClass(
    classId: params.classId,
    className: params.className,
    courseCode: params.courseCode,
  );
});

// Interactive state to manage applied interventions across reports
class AppliedInterventionsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleIntervention(String interventionId) {
    if (state.contains(interventionId)) {
      state = Set.from(state)..remove(interventionId);
    } else {
      state = Set.from(state)..add(interventionId);
    }
  }

  bool isApplied(String interventionId) => state.contains(interventionId);
}

final appliedInterventionsProvider =
    NotifierProvider<AppliedInterventionsNotifier, Set<String>>(
  AppliedInterventionsNotifier.new,
);

// Student-facing peer habit nudges provider
final studentPeerNudgesProvider = Provider<List<StudentPeerNudge>>((ref) {
  final service = ref.watch(hiveMindServiceProvider);
  final enrolledClasses = ref.watch(enrolledClassesProvider).value ?? [];
  final courseCodes = enrolledClasses.map((c) => c.courseCode).toList();

  return service.getPeerNudgesForStudent(courseCodes);
});
