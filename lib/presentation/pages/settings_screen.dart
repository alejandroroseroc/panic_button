import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final s = ctrl.prefs.value;
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Botón en pantalla'),
                value: s.useButton,
                onChanged: ctrl.toggleButton,
              ),
              SwitchListTile(
                title: const Text('Activar por voz'),
                subtitle: Text('Texto: "${s.customText}"'),
                value: s.useVoice,
                onChanged: ctrl.toggleVoice,
              ),
              if (s.useVoice)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Texto de alerta'),
                    controller: TextEditingController(text: s.customText),
                    onSubmitted: ctrl.setCustomText,
                  ),
                ),
              SwitchListTile(
                title: const Text('Activar por sacudida'),
                value: s.useShake,
                onChanged: ctrl.toggleShake,
              ),
              SwitchListTile(
                title: const Text('Notificaciones Push'),
                value: s.pushNotifications,
                onChanged: ctrl.togglePush,
              ),
            ],
          );
        }),
      ),
    );
  }
}
