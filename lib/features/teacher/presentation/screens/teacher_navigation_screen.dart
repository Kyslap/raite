import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'teacher_dashboard_screen.dart';
import 'teacher_classes_screen.dart';
import 'teacher_create_lesson_screen.dart';
import 'teacher_analytics_screen.dart';

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
    ];

    return Scaffold(
      body: Column(
        children: [
          // Hackathon Demo Switcher Banner
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'TEACHER VIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Educator Portal Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.go('/home');
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text(
                      'Switch to Student',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
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
              label: 'Post Lesson',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
