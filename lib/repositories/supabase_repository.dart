import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Since we don't have auth fully wired up with a real user yet, 
  // we'll get the current user ID if logged in.
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Fetch user profile metrics
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    return response;
  }

  /// Fetch enrolled classes with progress
  Future<List<Map<String, dynamic>>> getEnrolledClasses() async {
    final userId = currentUserId;
    if (userId == null) return [];

    // We join user_classes with classes
    final response = await _client
        .from('user_classes')
        .select('''
          progress_percentage,
          classes (
            id,
            title,
            instructor_name,
            department,
            track_name,
            semester
          )
        ''')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch pending assignments for the user's classes
  Future<List<Map<String, dynamic>>> getPendingAssignments() async {
    final userId = currentUserId;
    if (userId == null) return [];

    // First get the classes the user is enrolled in
    final enrolledResponse = await _client
        .from('user_classes')
        .select('class_id')
        .eq('user_id', userId);
        
    final classIds = (enrolledResponse as List).map((e) => e['class_id']).toList();

    if (classIds.isEmpty) return [];

    // Then fetch assignments for those classes
    final assignments = await _client
        .from('assignments')
        .select()
        .inFilter('class_id', classIds)
        .eq('status', 'pending')
        .order('due_date', ascending: true);

    return List<Map<String, dynamic>>.from(assignments);
  }

  /// Fetch user achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('achievements')
        .select()
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

// Global instance for easy access (in a real app, use Riverpod, Provider, or GetIt)
final supabaseRepo = SupabaseRepository();
