// lib/controllers/settings_controller.dart

import 'package:get/get.dart';
import '../data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  final SettingsRepository _repo;
  final prefs = Rx<SettingsModel>(SettingsModel.defaults());

  SettingsController({required SettingsRepository repo}) : _repo = repo;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs.value = await _repo.load();
  }

  void toggleButton(bool v) {
    prefs.update((p) => p!.useButton = v);
    _repo.save(prefs.value);
  }

  void toggleVoice(bool v) {
    prefs.update((p) => p!.useVoice = v);
    _repo.save(prefs.value);
  }

  void toggleShake(bool v) {
    prefs.update((p) => p!.useShake = v);
    _repo.save(prefs.value);
  }

  void setCustomText(String t) {
    prefs.update((p) => p!.customText = t);
    _repo.save(prefs.value);
  }

  void togglePush(bool v) {
    prefs.update((p) => p!.pushNotifications = v);
    _repo.save(prefs.value);
  }
}
