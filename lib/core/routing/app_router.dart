import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';

import '../../features/teacher/presentation/screens/teacher_navigation_screen.dart';
import '../../main.dart';
import '../../features/class/presentation/screens/class_screen.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../features/class/domain/topic_model.dart';
import 'package:flutter/foundation.dart';
import '../../features/study_deck/presentation/screens/study_deck_screen.dart';
import '../../features/study_deck/presentation/screens/flashcard_study_screen.dart';
import '../../features/study_deck/presentation/screens/quiz_play_screen.dart';
import '../../features/study_deck/presentation/screens/ocr_scanner_screen.dart';
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
  final listenable = ValueNotifier<bool>(false);
  ref.listen(authStateProvider, (_, __) {
    listenable.value = !listenable.value;
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      
      if (authState.isLoading) {
        return null; // Stay where we are while loading
      }
      
      final isAuthenticated = authState.value != null;
      final isGoingToLoginOrSignup = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      final isAtSplash = state.matchedLocation == '/';
      
      if (!isAuthenticated && !isGoingToLoginOrSignup && !isAtSplash) {
        return '/';
      }
      
      if (isAuthenticated && (isGoingToLoginOrSignup || isAtSplash)) {
        final user = authState.value;
        if (user != null && (user.role == 'teacher' || user.role == 'professor')) {
          return '/teacher';
        }
        return '/home';
      }
      
      return null;
    },
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
          
          final extra = state.extra;
          if (extra is TopicModel) {
            topic = extra;
          } else if (extra is Map) {
            topic = extra['topic'] as TopicModel?;
            pdfUrl = extra['pdfUrl'] as String?;
            pdfTitle = extra['pdfTitle'] as String?;
            showTopicContent = extra['showTopicContent'] as bool? ?? false;
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
      GoRoute(
        path: '/study-deck',
        builder: (context, state) => const StudyDeckScreen(),
      ),
      GoRoute(
        path: '/flashcards/:id',
        builder: (context, state) => FlashcardStudyScreen(
          deckId: state.pathParameters['id'] ?? 'deck-math201',
        ),
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (context, state) => QuizPlayScreen(
          quizId: state.pathParameters['id'] ?? 'quiz-math201',
        ),
      ),
      GoRoute(
        path: '/ocr-scanner',
        builder: (context, state) => const OcrScannerScreen(),
      ),
    ],
  );
});
