import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/class/presentation/screens/class_screen.dart';

import 'features/ai_tutor/presentation/screens/ai_tutor_list_screen.dart';
import 'features/metrics/presentation/screens/metrics_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

String? initError;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e, st) {
    initError = 'ERROR: $e\n$st';
  }

  runApp(
    ProviderScope(
      child: initError != null 
          ? MaterialApp(home: Scaffold(body: Center(child: Text(initError!))))
          : const SmartLearningApp(),
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

class StudentNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final studentBottomNavIndexProvider =
    NotifierProvider<StudentNavIndexNotifier, int>(() {
  return StudentNavIndexNotifier();
});

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const ClassScreen(),
    const AiTutorListScreen(),
    const MetricsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: ref.watch(studentBottomNavIndexProvider),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: ref.watch(studentBottomNavIndexProvider),
          onTap: (index) {
            ref.read(studentBottomNavIndexProvider.notifier).setIndex(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'AI Tutor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Metrics',
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
