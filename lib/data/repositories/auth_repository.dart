// lib/data/repositories/auth_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AuthRepository {
  final Account account;

  AuthRepository(this.account);

  Future<void> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    // Registra el usuario en Appwrite
    await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Crea sesión con email+password
    await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  Future<bool> isLoggedIn() async {
    try {
      await account.get();         // Si no está logueado lanza excepción
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    // Borra la sesión actual
    await account.deleteSession(sessionId: 'current');
  }
  Future<User> getCurrentUser() {
    return account.get(); // Appwrite devuelve un modelo User
  }
}
