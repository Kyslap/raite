import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';
import '../../../class/presentation/providers/class_provider.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'student',
    String? classCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authRepositoryProvider).signUp(
        name: name,
        email: email,
        password: password,
        role: role,
        classCode: classCode,
      );

      // If student provided a class code, enroll them immediately!
      if (role == 'student' && classCode != null && classCode.trim().isNotEmpty) {
        await ref.read(enrolledClassesProvider.notifier).joinClassByCode(classCode.trim());
      }

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}

