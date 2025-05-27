// lib/controllers/settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/controllers/panic_button_controller.dart';
import '../data/repositories/settings_repository.dart';
import '../models/settings_model.dart';
import 'package:collection/collection.dart';

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

  // Global switches
  void toggleButton(bool v)    => _update((p) => p.useButton = v);
  void toggleVoice(bool v)     => _update((p) => p.useVoice = v);
  void toggleShake(bool v)     => _update((p) => p.useShake = v);
  void setCustomText(String t) => _update((p) => p.alertText = t);
  void togglePush(bool v)      => _update((p) => p.pushNotifications = v);

  /// Obtiene la lista de métodos asignados a un botón
  List<String> getTriggers(String buttonId) {
    return prefs.value.buttonTriggers[buttonId] ?? <String>[];
  }

  /// Asigna/quita un método (tap/voice/shake) a un botón,
  /// pero permite solo un botón con 'voice' y uno con 'shake'.
  void toggleTrigger(String buttonId, String method) {
    final model = prefs.value;
    final triggers = Map<String, List<String>>.from(model.buttonTriggers);
    final current = triggers[buttonId] ?? <String>[];

    final isAdding = !current.contains(method);
    if (isAdding && (method == 'voice' || method == 'shake')) {
      // Si ya hay otro botón con ese método, bloqueamos
      final conflict = triggers.entries
          .firstWhereOrNull((e) => e.value.contains(method) && e.key != buttonId);
      if (conflict != null) {
        Get.snackbar(
          '¡Ups!',
          'Solo puedes asignar "$method" a un botón. Desasigna primero de "${_findTitle(conflict.key)}".',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
        );
        return;
      }
    }

    // Toggle en este botón
    if (isAdding) current.add(method);
    else current.remove(method);
    triggers[buttonId] = current;

    _update((p) => p.buttonTriggers = triggers);
  }

  /// Helper para obtener título de un botón por id
  String _findTitle(String buttonId) {
    final panicCtrl = Get.find<PanicButtonController>();
    final btn = panicCtrl.buttons.firstWhereOrNull((b) => b.id == buttonId);
    return btn?.title ?? 'otro botón';
  }

  void _update(void Function(SettingsModel) fn) {
    prefs.update((p) {
      fn(p!);
    });
    _repo.save(prefs.value);
  }
}
