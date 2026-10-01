import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStats {
  final int streakDays;
  final int chatsToday;
  final int dailyGoal;

  UserStats({
    required this.streakDays,
    required this.chatsToday,
    required this.dailyGoal,
  });
}

final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    return UserStats(streakDays: 0, chatsToday: 0, dailyGoal: 5);
  }

  try {
    // Fetch user's chat logs to determine activity
    final logs = await supabase
        .from('ai_chat_logs')
        .select('created_at')
        .eq('student_id', userId)
        .order('created_at', ascending: false);

    if (logs.isEmpty) {
      return UserStats(streakDays: 0, chatsToday: 0, dailyGoal: 5);
    }

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    int chatsToday = 0;
    Set<String> activeDates = {};
    
    for (final log in logs) {
      final date = DateTime.parse(log['created_at'].toString()).toLocal();
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      activeDates.add(dateStr);
      if (dateStr == todayStr) {
        chatsToday++;
      }
    }

    // Calculate streak
    int streak = 0;
    DateTime checkDate = now;
    
    // Check if they were active today
    if (activeDates.contains(todayStr)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // If not active today, check if they were active yesterday to see if streak is still alive
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
      
      if (activeDates.contains(yesterdayStr)) {
        streak++;
        checkDate = yesterday.subtract(const Duration(days: 1));
      } else {
        // Streak broken
        return UserStats(streakDays: 0, chatsToday: chatsToday, dailyGoal: 5);
      }
    }

    // Count backwards for consecutive days
    while (true) {
      final checkStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      if (activeDates.contains(checkStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return UserStats(
      streakDays: streak,
      chatsToday: chatsToday,
      dailyGoal: 5,
    );
  } catch (e) {
    print('Error fetching user stats: $e');
    return UserStats(streakDays: 0, chatsToday: 0, dailyGoal: 5);
  }
});
