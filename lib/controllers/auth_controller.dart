// lib/controllers/auth_controller.dart

import 'package:get/get.dart';
import 'package:appwrite/models.dart';
import 'package:panic_button/controllers/panic_button_controller.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/home_page.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  /// Indica si estamos cargando
  final RxBool isLoading = false.obs;
  /// Error text
  final RxString error = ''.obs;
  /// Aquí guardamos el User de Appwrite
  final Rxn<User> user = Rxn<User>();

  AuthController(this._authRepository);

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    isLoading.value = true;
    try {
      final u = await _authRepository.getCurrentUser();
      user.value = u;
    } catch (_) {
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkAuth() async {
    isLoading.value = true;
    try {
      final loggedIn = await _authRepository.isLoggedIn();
      if (loggedIn) await _loadCurrentUser();
      return loggedIn;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _authRepository.login(email: email, password: password);
      await _loadCurrentUser();
      // **AL LOGUEAR**: recarga los botones del nuevo usuario
      Get.find<PanicButtonController>().loadButtons();
      Get.offAll(() => HomePage());
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
        email: email, password: password, name: name);
      await login(email, password);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
    // **AL LOGOUT**: limpia la lista de botones
    Get.find<PanicButtonController>().buttons.clear();
    Get.offAll(() => LoginPage());
  }
}
