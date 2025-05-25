// lib/presentation/pages/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/message_template_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final tmplCtrl     = Get.find<MessageTemplateController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final s = settingsCtrl.prefs.value;
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Botón en pantalla'),
                value: s.useButton,
                onChanged: settingsCtrl.toggleButton,
              ),
              SwitchListTile(
                title: const Text('Activar por voz'),
                subtitle: Text('Texto: "${s.customText}"'),
                value: s.useVoice,
                onChanged: settingsCtrl.toggleVoice,
              ),
              if (s.useVoice)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Texto de alerta'),
                    controller: TextEditingController(text: s.customText),
                    onSubmitted: settingsCtrl.setCustomText,
                  ),
                ),
              SwitchListTile(
                title: const Text('Activar por sacudida'),
                value: s.useShake,
                onChanged: settingsCtrl.toggleShake,
              ),
              SwitchListTile(
                title: const Text('Notificaciones Push'),
                value: s.pushNotifications,
                onChanged: settingsCtrl.togglePush,
              ),

              const Divider(height: 32),
              const Text(
                'Plantillas de WhatsApp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Lista de plantillas CRUD
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
            ],
          );
        }),
      ),
    );
  }
}
