// lib/presentation/pages/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/message_template_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../widgets/button_trigger_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              // 1) Switch global: botón en pantalla
              SwitchListTile(
                title: const Text('Botón en pantalla'),
                value: s.useButton,
                onChanged: settingsCtrl.toggleButton,
              ),

              // 2) Switch global: activar por voz
              SwitchListTile(
                title: const Text('Activar por voz'),
                subtitle: Text('Texto: "${s.alertText}"'),
                value: s.useVoice,
                onChanged: settingsCtrl.toggleVoice,
              ),
              if (s.useVoice)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: TextField(
                    controller: TextEditingController(text: s.alertText),
                    decoration: const InputDecoration(labelText: 'Texto de alerta'),
                    onSubmitted: settingsCtrl.setCustomText,
                  ),
                ),

              // 3) Switch global: activar por sacudida
              SwitchListTile(
                title: const Text('Activar por sacudida'),
                value: s.useShake,
                onChanged: settingsCtrl.toggleShake,
              ),

              const Divider(height: 32),

              // 4) SMS templates (si ya lo tenías)
              const Text(
                'Plantillas de SMS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...tmplCtrl.templates.map((t) => ListTile(
                    title: Text(t.title),
                    subtitle: Text(t.content),
                    trailing: Wrap(spacing: 8, children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => tmplCtrl.showEditDialog(t),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => tmplCtrl.deleteTemplate(t.id),
                      ),
                    ]),
                  )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nueva plantilla'),
                onPressed: () => tmplCtrl.showAddDialog(context),
              ),

              const Divider(height: 32),

              // 5) Métodos por botón
              const Text(
                'Métodos por botón',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...panicCtrl.buttons.map((b) => ButtonTriggerTile(button: b)),
            ],
          );
        }),
      ),
    );
  }
}
