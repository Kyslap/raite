import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/class_model.dart';
import '../../data/mock_class_repository.dart';

final classRepositoryProvider = Provider((ref) => MockClassRepository());

final enrolledClassesProvider = FutureProvider<List<ClassModel>>((ref) async {
  final repository = ref.watch(classRepositoryProvider);
  return repository.fetchEnrolledClasses();
});

final classDetailProvider = Provider.family<ClassModel?, String>((ref, id) {
  final classes = ref.watch(enrolledClassesProvider);
  return classes.maybeWhen(
    data: (list) {
      try {
        return list.firstWhere((c) => c.id == id);
      } catch (e) {
        return null;
      }
    },
    orElse: () => null,
  );
});
