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
    await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  Future<bool> isLoggedIn() async {
    try {
      await account.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  Future<User> getCurrentUser() {
    return account.get();
  }

  // ——— Nuevos métodos ———

  Future<User> updateName(String name) {
    return account.updateName(name: name);
  }

  Future<User> updateEmail(String email, String password) {
    // Appwrite pide password actual para cambiar email
    return account.updateEmail(
      email: email,
      password: password,
    );
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  Future<User> updatePrefs({ required Map<String, dynamic> prefs }) {
    return account.updatePrefs(prefs: prefs);
  }
}
