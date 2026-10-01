import '../domain/class_model.dart';

class MockClassRepository {
  Future<List<ClassModel>> fetchEnrolledClasses() async {
    // Return empty list so student begins with no classes until joined with a teacher's code
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }
}
