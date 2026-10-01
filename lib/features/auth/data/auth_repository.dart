import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  SupabaseClient? get _supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    final client = _supabaseClient;
    if (client != null) {
      try {
        final res = await client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        final user = res.user;
        if (user != null) {
          final meta = user.userMetadata ?? {};
          final name = meta['name'] as String? ?? (email.contains('@') ? email.split('@').first : 'Scholar');
          return UserModel(
            id: user.id,
            email: user.email ?? email.trim(),
            name: name,
          );
        }
      } catch (e) {
        throw Exception('Login failed: $e');
      }
    }

    throw Exception('Supabase client not initialized');
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'student',
    String? classCode,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Name, email, and password cannot be empty');
    }

    final client = _supabaseClient;
    if (client != null) {
      try {
        final res = await client.auth.signUp(
          email: email.trim(),
          password: password,
          data: {
            'name': name.trim(),
            'role': role,
            if (classCode != null && classCode.isNotEmpty)
              'initial_class_code': classCode.trim().toUpperCase(),
          },
        );
        final user = res.user;
        if (user != null) {
          return UserModel(
            id: user.id,
            email: user.email ?? email.trim(),
            name: name.trim(),
          );
        }
      } catch (e) {
        throw Exception('Sign up failed: $e');
      }
    }

    throw Exception('Supabase client not initialized');
  }

  Future<void> logout() async {
    final client = _supabaseClient;
    if (client != null) {
      await client.auth.signOut();
    }
  }
}

