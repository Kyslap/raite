import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    return UserModel(id: '1', email: email, name: 'Retro Student');
  }

  Future<UserModel> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(id: '1', email: email, name: name);
  }
}
