import 'package:get/get.dart';
import '../data/repositories/settings_repository.dart';
import '../models/settings_model.dart';

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

  // Mantiene los switches globales
  void toggleButton(bool v) => _update((p) => p.useButton = v);
  void toggleVoice(bool v) => _update((p) => p.useVoice = v);
  void toggleShake(bool v) => _update((p) => p.useShake = v);
  void setCustomText(String t) => _update((p) => p.alertText = t);
  void togglePush(bool v) => _update((p) => p.pushNotifications = v);

  // Métodos por botón
  List<String> getTriggers(String buttonId) {
    return prefs.value.buttonTriggers[buttonId] ?? <String>[];
  }

  void toggleTrigger(String buttonId, String methodName) {
    final map = prefs.value.buttonTriggers;
    final list = List<String>.from(map[buttonId] ?? <String>[]);
    if (list.contains(methodName)) list.remove(methodName);
    else list.add(methodName);
    map[buttonId] = list;
    _update((p) => p.buttonTriggers = map);
  }

  void _update(void Function(SettingsModel) fn) {
    prefs.update((p) {
      fn(p!);
    });
    _repo.save(prefs.value);
  }
}
