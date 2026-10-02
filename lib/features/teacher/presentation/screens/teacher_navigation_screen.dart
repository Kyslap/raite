import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'teacher_dashboard_screen.dart';
import 'teacher_classes_screen.dart';
import 'teacher_create_lesson_screen.dart';
import 'teacher_analytics_screen.dart';
import 'teacher_profile_screen.dart';

class TeacherNavigationScreen extends ConsumerStatefulWidget {
  const TeacherNavigationScreen({super.key});

  @override
  ConsumerState<TeacherNavigationScreen> createState() =>
      _TeacherNavigationScreenState();
}

class _TeacherNavigationScreenState
    extends ConsumerState<TeacherNavigationScreen> {
  int _currentIndex = 0;

  void _onNavigateTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screens = [
      TeacherDashboardScreen(onNavigateTab: _onNavigateTab),
      TeacherClassesScreen(onNavigateTab: _onNavigateTab),
      TeacherCreateLessonScreen(onLessonPublished: () => _onNavigateTab(0)),
      const TeacherAnalyticsScreen(),
      TeacherProfileScreen(onNavigateTab: _onNavigateTab),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.outline,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add_outlined),
              activeIcon: Icon(Icons.post_add),
              label: 'Lesson',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
