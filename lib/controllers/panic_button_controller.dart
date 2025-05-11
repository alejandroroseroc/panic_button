import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/repositories/panic_button_repository.dart';
import '../models/panic_button_model.dart';
import 'settings_controller.dart';
import 'alert_log_controller.dart';

class PanicButtonController extends GetxController {
  final PanicButtonRepository _repo;
  final Account _account;

  PanicButtonController({
    required PanicButtonRepository repo,
    required Account account,
  })  : _repo = repo,
        _account = account;

  var buttons   = <PanicButtonModel>[].obs;
  var isLoading = false.obs;
  var error     = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadButtons();
  }

  Future<void> loadButtons() async {
    isLoading.value = true;
    try {
      final me = await _account.get();
      buttons.value = await _repo.fetchButtons(me.$id);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addButton(PanicButtonModel btn) async {
    isLoading.value = true;
    try {
      final me      = await _account.get();
      final toSave  = btn.copyWith(userId: me.$id);
      final newBtn  = await _repo.createButton(toSave);
      buttons.add(newBtn);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateButton(PanicButtonModel btn) async {
    isLoading.value = true;
    try {
      final updated = await _repo.updateButton(btn);
      final idx     = buttons.indexWhere((b) => b.id == updated.id);
      if (idx != -1) buttons[idx] = updated;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteButton(String id) async {
    try {
      await _repo.deleteButton(id);
      buttons.removeWhere((b) => b.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Dispara la alerta: guarda log, llama contactos y servicios de emergencia.
  Future<void> triggerAlert(PanicButtonModel btn) async {
    // 1) Guardar log local y remoto
    Get.find<AlertLogController>().logAlert(btn.id);

    // 2) Leer settings
    final settings = Get.find<SettingsController>().prefs.value;

    // 3) Mensajes/llamadas a cada contacto
    for (final contactId in btn.contactIds) {
      // Aquí podrías recuperar el ContactModel por id si lo tienes en memoria
      // y hacer algo como: launch('tel:${contact.phone}');
    }

    // 4) Emergencias
    if (btn.alertToPolice) {
      await launchUrl(Uri.parse('tel:911'));
    }
    if (btn.alertToAmbulance) {
      await launchUrl(Uri.parse('tel:912'));
    }

    // 5) Notificaciones push, voz o shake: manejarlo en AlertLogController o SettingsController
  }
}
