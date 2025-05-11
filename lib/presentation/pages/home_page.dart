// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/panic_button_model.dart';
import '../../widgets/panic_button_card.dart';
import 'contact_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl     = Get.find<AuthController>();
    final panicCtrl    = Get.find<PanicButtonController>();
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      // ───── Drawer ─────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Obx(() => Text(
                  Get.find<AuthController>().user.value?.name ?? '--'
                )),
                accountEmail: Obx(() => Text(
                  Get.find<AuthController>().user.value?.email ?? '--'
                )),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Text(
                    (Get.find<AuthController>().user.value?.name.isNotEmpty ?? false)
                      ? Get.find<AuthController>().user.value!.name[0].toUpperCase()
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
            ],
          ),
        ),
      ),

      // ───── AppBar ─────
      appBar: AppBar(
        title: const Text('Mis Botones de Pánico'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authCtrl.logout(),
          ),
        ],
        backgroundColor: Colors.deepPurple,
      ),

      // ───── Cuerpo ─────
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
              child: Text(
                'Error: ${panicCtrl.error.value}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }
          if (panicCtrl.buttons.isEmpty) {
            return const Center(
              child: Text(
                'No tienes botones aún',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: panicCtrl.buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, i) {
                final btn = panicCtrl.buttons[i];
                return GestureDetector(
                  // Si está activado “Botón en pantalla”, tap disparará la alerta
                  onTap: () {
                    if (settingsCtrl.prefs.value.useButton) {
                      panicCtrl.triggerAlert(btn);
                    }
                  },
                  // Long press abre diálogo de edición
                  onLongPress: () {
                    _showAddEditDialog(context, panicCtrl, existing: btn);
                  },
                  child: PanicButtonCard(
                    button: btn,
                    onTap: () {}, // ya lo manejamos en GestureDetector
                    onDelete: () => panicCtrl.deleteButton(btn.id),
                  ),
                );
              },
            ),
          );
        }),
      ),

      // ───── FAB ─────
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () => _showAddEditDialog(context, panicCtrl),
        backgroundColor: Colors.amber,
      ),
    );
  }

  /// Diálogo para crear o editar un botón
  void _showAddEditDialog(
    BuildContext context,
    PanicButtonController ctrl, {
    PanicButtonModel? existing,
  }) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    int selectedColor    = existing?.color ?? 0xFF2196F3;
    bool alertPolice     = existing?.alertToPolice ?? false;
    bool alertAmbulance  = existing?.alertToAmbulance ?? false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(existing == null ? 'Nuevo Botón' : 'Editar Botón'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selección de color
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      _colorCircle(0xFF2196F3, selectedColor, () => setState(() => selectedColor = 0xFF2196F3)),
                      _colorCircle(0xFFF44336, selectedColor, () => setState(() => selectedColor = 0xFFF44336)),
                      _colorCircle(0xFF4CAF50, selectedColor, () => setState(() => selectedColor = 0xFF4CAF50)),
                      _colorCircle(0xFFFFC107, selectedColor, () => setState(() => selectedColor = 0xFFFFC107)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkboxes Policía / Ambulancia
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
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  final model = PanicButtonModel(
                    id: existing?.id ?? '',
                    title: titleCtrl.text.trim(),
                    color: selectedColor,
                    contactIds: existing?.contactIds ?? [],
                    alertToPolice: alertPolice,
                    alertToAmbulance: alertAmbulance,
                    userId: '', // lo rellena el controller
                  );
                  if (existing == null) {
                    ctrl.addButton(model);
                  } else {
                    ctrl.updateButton(model);
                  }
                  Navigator.of(context).pop();
                },
                child: Text(existing == null ? 'Crear' : 'Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Selector de color circular
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
