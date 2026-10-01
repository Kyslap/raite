import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';

import '../../features/teacher/presentation/screens/teacher_navigation_screen.dart';
import '../../main.dart';
import '../../features/class/presentation/screens/class_screen.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../features/class/domain/topic_model.dart';
// Temporarily returning a basic screen until we build the features
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title, 
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          )
        )
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/class/:id',
        builder: (context, state) => ClassScreen(classId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ai-tutor',
        builder: (context, state) {
          TopicModel? topic;
          String? pdfUrl;
          String? pdfTitle;
          bool showTopicContent = false;
          
          if (state.extra is TopicModel) {
            topic = state.extra as TopicModel;
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            topic = map['topic'] as TopicModel?;
            pdfUrl = map['pdfUrl'] as String?;
            pdfTitle = map['pdfTitle'] as String?;
            showTopicContent = map['showTopicContent'] as bool? ?? false;
          }
          
          return AiTutorScreen(
            initialTopic: topic,
            initialPdfUrl: pdfUrl,
            initialPdfTitle: pdfTitle,
            showTopicContent: showTopicContent,
          );
        },
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherNavigationScreen(),
      ),
    ],
  );
});
