import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SmartLearningApp(),
    ),
  );
}

class SmartLearningApp extends ConsumerWidget {
  const SmartLearningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smart Learning Platform Hub',
      theme: AppTheme.retroTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
