// lib/presentation/pages/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/message_template_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../widgets/button_trigger_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final tmplCtrl     = Get.find<MessageTemplateController>();
    final panicCtrl    = Get.find<PanicButtonController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final s = settingsCtrl.prefs.value;
          return ListView(
            children: [
              // Botón en pantalla (tap)
              SwitchListTile(
                title: const Text('Botón en pantalla'),
                subtitle: const Text('Dispara alertas al tocar'),
                value: s.useButton,
                onChanged: settingsCtrl.toggleButton,
              ),

              // Activar por voz
              SwitchListTile(
                title: const Text('Activar por voz'),
                subtitle: Text('Palabra: "${s.alertText}"'),
                value: s.useVoice,
                onChanged: settingsCtrl.toggleVoice,
              ),
              if (s.useVoice)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: TextField(
                    controller: TextEditingController(text: s.alertText),
                    decoration: const InputDecoration(
                      labelText: 'Texto de alerta',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: settingsCtrl.setCustomText,
                  ),
                ),

              // Activar por sacudida
              SwitchListTile(
                title: const Text('Activar por shake'),
                subtitle: const Text('Mueve el teléfono para disparar'),
                value: s.useShake,
                onChanged: settingsCtrl.toggleShake,
              ),

              const Divider(height: 32),

              // Plantillas de SMS (si las usas)
              const Text('Plantillas de SMS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...tmplCtrl.templates.map((t) => ListTile(
                    title: Text(t.title),
                    subtitle: Text(t.content),
                    trailing: Wrap(spacing: 8, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => tmplCtrl.showEditDialog(t)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => tmplCtrl.deleteTemplate(t.id)),
                    ]),
                  )),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nueva plantilla'),
                onPressed: () => tmplCtrl.showAddDialog(context),
              ),

              const Divider(height: 32),

              // Métodos por botón (tap/voice/shake)
              const Text('Métodos por botón', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...panicCtrl.buttons.map((b) => ButtonTriggerTile(button: b)),
            ],
          );
        }),
      ),
    );
  }
}
