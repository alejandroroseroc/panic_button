import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/contact_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/contact_controller.dart';
import '../../controllers/message_template_controller.dart';
import '../../models/panic_button_model.dart';
import '../../widgets/panic_button_card.dart';

import 'profile_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl     = Get.find<AuthController>();
    final panicCtrl    = Get.find<PanicButtonController>();
    final settingsCtrl = Get.find<SettingsController>();
    final contactCtrl  = Get.find<ContactController>();
    final tmplCtrl     = Get.find<MessageTemplateController>();

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(children: [
            UserAccountsDrawerHeader(
              accountName: Obx(() => Text(authCtrl.user.value?.name ?? '--')),
              accountEmail: Obx(() => Text(authCtrl.user.value?.email ?? '--')),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(
                  (authCtrl.user.value?.name.isNotEmpty ?? false)
                      ? authCtrl.user.value!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ProfileScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Contactos'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ContactsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const SettingsScreen());
              },
            ),
          ]),
        ),
      ),
      appBar: AppBar(
        title: const Text('Mis Botones de Pánico'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => authCtrl.logout()),
        ],
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          if (panicCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (panicCtrl.error.value.isNotEmpty) {
            return Center(
              child: Text('Error: ${panicCtrl.error.value}',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            );
          }
          if (panicCtrl.buttons.isEmpty) {
            return const Center(
              child: Text('No tienes botones aún',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: panicCtrl.buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1),
              itemBuilder: (context, i) {
                final btn = panicCtrl.buttons[i];
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (btn.useButton) panicCtrl.triggerAlert(btn);
                      },
                      onLongPress: () => _showAddEditDialog(
                        context, panicCtrl, contactCtrl, tmplCtrl, existing: btn),
                      child: PanicButtonCard(
                        button: btn,
                        onTap: () {},
                        onDelete: () => panicCtrl.deleteButton(btn.id),
                      ),
                    ),
                    // Icono de edición
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => _showAddEditDialog(
                          context, panicCtrl, contactCtrl, tmplCtrl, existing: btn),
                        child: const Icon(Icons.edit, color: Colors.white70, size: 24),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () => _showAddEditDialog(context, panicCtrl, contactCtrl, tmplCtrl),
        backgroundColor: Colors.amber,
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext ctx,
    PanicButtonController ctrl,
    ContactController contactCtrl,
    MessageTemplateController tmplCtrl, {
    PanicButtonModel? existing,
  }) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    int selectedColor = existing?.color ?? 0xFF2196F3;
    bool alertPolice    = existing?.alertToPolice ?? false;
    bool alertAmbulance = existing?.alertToAmbulance ?? false;
    bool useButton      = existing?.useButton ?? true;
    bool useVoice       = existing?.useVoice ?? false;
    bool useShake       = existing?.useShake ?? false;
    bool usePush        = existing?.usePush ?? false;
    String templateId   = existing?.messageTemplateId ?? tmplCtrl.templates.first.id;

    // Nueva lista local de selección de contactos
    List<String> selectedContacts = [...(existing?.contactIds ?? [])];

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(existing == null ? 'Nuevo Botón' : 'Editar Botón'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),

                // Color
                Align(alignment: Alignment.centerLeft,
                    child: const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Wrap(spacing: 12, children: [
                  _colorCircle(0xFF2196F3, selectedColor, () => setState(() => selectedColor = 0xFF2196F3)),
                  _colorCircle(0xFFF44336, selectedColor, () => setState(() => selectedColor = 0xFFF44336)),
                  _colorCircle(0xFF4CAF50, selectedColor, () => setState(() => selectedColor = 0xFF4CAF50)),
                  _colorCircle(0xFFFFC107, selectedColor, () => setState(() => selectedColor = 0xFFFFC107)),
                ]),
                const Divider(height: 24),

                // Contactos
                const Text('Contactos:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...contactCtrl.contacts.map((c) {
                  final selected = selectedContacts.contains(c.id);
                  return CheckboxListTile(
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                    value: selected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) selectedContacts.add(c.id);
                        else selectedContacts.remove(c.id);
                      });
                    },
                  );
                }),
                const Divider(height: 24),

                // Switches
                SwitchListTile(
                  title: const Text('Botón en pantalla'),
                  value: useButton,
                  onChanged: (v) => setState(() => useButton = v),
                ),
                SwitchListTile(
                  title: const Text('Voz'),
                  value: useVoice,
                  onChanged: (v) => setState(() => useVoice = v),
                ),
                SwitchListTile(
                  title: const Text('Sacudida'),
                  value: useShake,
                  onChanged: (v) => setState(() => useShake = v),
                ),
                SwitchListTile(
                  title: const Text('Push'),
                  value: usePush,
                  onChanged: (v) => setState(() => usePush = v),
                ),
                const Divider(height: 24),

                // Plantilla
                DropdownButtonFormField<String>(
                  value: templateId,
                  decoration: const InputDecoration(labelText: 'Plantilla de mensaje'),
                  items: tmplCtrl.templates
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                      .toList(),
                  onChanged: (v) => setState(() => templateId = v!),
                ),
                const SizedBox(height: 8),

                // Emergencias
                CheckboxListTile(
                  value: alertPolice,
                  onChanged: (v) => setState(() => alertPolice = v ?? false),
                  title: const Text('Policía'),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.red,
                ),
                CheckboxListTile(
                  value: alertAmbulance,
                  onChanged: (v) => setState(() => alertAmbulance = v ?? false),
                  title: const Text('Ambulancia'),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                ),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx2).pop(), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  final model = PanicButtonModel(
                    id: existing?.id ?? '',
                    title: titleCtrl.text.trim(),
                    color: selectedColor,
                    contactIds: selectedContacts,
                    alertToPolice: alertPolice,
                    alertToAmbulance: alertAmbulance,
                    useButton: useButton,
                    useVoice: useVoice,
                    useShake: useShake,
                    usePush: usePush,
                    messageTemplateId: templateId,
                    userId: '',
                  );
                  if (existing == null) ctrl.addButton(model);
                  else ctrl.updateButton(model);
                  Navigator.of(ctx2).pop();
                },
                child: Text(existing == null ? 'Crear' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _colorCircle(int hex, int current, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Color(hex),
        radius: 20,
        child: current == hex ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
