import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final AuthController _authCtrl = Get.find<AuthController>();

  final avatarFile = Rxn<File>();
  final isLoading   = false.obs;

  /// Escoge y sube avatar (puedes reutilizar tu lógica de Appwrite Storage)
  Future<void> pickAvatar() async {
    final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    avatarFile.value = File(picked.path);
    // TODO: sube a Storage y actualiza prefs como antes
  }

  Future<void> changeName(String newName) async {
    isLoading.value = true;
    try {
      final updated = await _authRepo.updateName(newName);
      _authCtrl.user.value = updated;
      Get.snackbar('Éxito', 'Nombre actualizado');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar nombre: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeEmail(String newEmail, String currentPassword) async {
    isLoading.value = true;
    try {
      final updated = await _authRepo.updateEmail(newEmail, currentPassword);
      _authCtrl.user.value = updated;
      Get.snackbar('Éxito', 'Email actualizado');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar email: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    isLoading.value = true;
    try {
      await _authRepo.updatePassword(oldPassword: oldPass, newPassword: newPass);
      Get.snackbar('Éxito', 'Contraseña actualizada');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cambiar contraseña: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
