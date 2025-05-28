import 'package:get/get.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite/appwrite.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/home_page.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  /// Estado de carga
  final RxBool isLoading = false.obs;
  /// Error de autenticación
  final RxString error = ''.obs;
  /// Usuario actual
  final Rxn<User> user = Rxn<User>();

  AuthController(this._authRepository);

  /// Chequea si hay sesión activa. Si devuelve true, carga el user en memoria.
  Future<bool> checkAuth() async {
    isLoading.value = true;
    try {
      final loggedIn = await _authRepository.isLoggedIn();
      if (!loggedIn) {
        return false;
      }
      // Si está logueado, cargamos datos básicos del usuario
      final u = await _authRepository.getCurrentUser();
      user.value = u;
      return true;
    } on AppwriteException catch (e) {
      // Si es 401, asumimos que no hay sesión
      if (e.code == 401) {
        return false;
      }
      // Otros errores los almacenamos para mostrar
      error.value = e.message ?? e.toString();
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _authRepository.login(email: email, password: password);
      // Carga el usuario
      final u = await _authRepository.getCurrentUser();
      user.value = u;

      // Navega al Home
      Get.offAll(() => HomePage());
    } on AppwriteException catch (e) {
      error.value = e.message ?? e.toString();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _authRepository.createAccount(
        email: email,
        password: password,
        name: name,
      );
      // Tras registro, logueamos al usuario
      await login(email, password);
    } on AppwriteException catch (e) {
      error.value = e.message ?? e.toString();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
      user.value = null;
      Get.offAll(() => LoginPage());
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
