import '../domain/class_model.dart';
import '../domain/topic_model.dart';

class MockClassRepository {
  Future<List<ClassModel>> fetchEnrolledClasses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return const [
      ClassModel(
        id: 'c1',
        courseCode: 'MATH 402',
        name: 'Advanced Mathematics',
        professor: 'Dr. Aris Thorne',
        progress: 0.82,
        topics: [
          TopicModel(id: 't1', title: 'Derivatives & Rates of Change', description: 'Calculus derivatives'),
          TopicModel(id: 't2', title: 'Integrals', description: 'Area under the curve'),
          TopicModel(id: 't3', title: 'Limits', description: 'Approaching infinity'),
        ],
      ),
      ClassModel(
        id: 'c2',
        courseCode: 'CS 101',
        name: 'Computer Science 101',
        professor: 'Prof. Sarah Jenkins',
        progress: 0.64,
        topics: [
          TopicModel(id: 't4', title: 'Data Structures', description: 'Arrays and Linked Lists'),
          TopicModel(id: 't5', title: 'Algorithms', description: 'Sorting and Searching'),
        ],
      ),
    ];
  }
}
