import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/class_model.dart';
import '../domain/topic_model.dart';

class MockClassRepository {
  Future<List<ClassModel>> fetchEnrolledClasses() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        final response = await client
            .from('user_classes')
            .select('''
              progress_percentage,
              classes (
                id,
                title,
                instructor_name,
                department,
                code
              )
            ''')
            .eq('user_id', userId);

        final List<ClassModel> loaded = [];
        for (final item in (response as List)) {
          final c = item['classes'];
          if (c != null) {
            loaded.add(ClassModel(
              id: c['id'].toString(),
              courseCode: c['code']?.toString() ?? 'CLS',
              name: c['title']?.toString() ?? 'Class',
              professor: c['instructor_name']?.toString() ?? 'Faculty Instructor',
              progress: (item['progress_percentage'] as num?)?.toDouble() ?? 0.0,
              topics: [
                TopicModel(
                  id: 't-${c['id']}',
                  title: 'Curriculum & Study Materials',
                  description: '${c['department'] ?? 'Course'} syllabus overview',
                ),
              ],
            ));
          }
        }
        return loaded;
      }
    } catch (_) {}

    return [];
  }
}
