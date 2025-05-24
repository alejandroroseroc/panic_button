// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/contact_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../controllers/contact_controller.dart';
import '../../models/panic_button_model.dart';
import '../../widgets/panic_button_card.dart';
import 'button_form_page.dart';      // <-- Nueva página

import 'profile_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl  = Get.find<AuthController>();
    final panicCtrl = Get.find<PanicButtonController>();

    return Scaffold(
      // ───── Drawer ─────
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
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
                onTap: () { Navigator.pop(context); Get.to(() => const ProfileScreen()); },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Contactos'),
                onTap: () { Navigator.pop(context); Get.to(() => const ContactsScreen()); },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ajustes'),
                onTap: () { Navigator.pop(context); Get.to(() => const SettingsScreen()); },
              ),
            ],
          ),
        ),
      ),

      // ───── AppBar ─────
      appBar: AppBar(
        title: const Text('Mis Botones de Pánico'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => authCtrl.logout())
        ],
      ),

      // ───── Cuerpo con fondo degradado ─────
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
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (panicCtrl.buttons.isEmpty) {
            return const Center(
              child: Text(
                'No tienes botones aún',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: panicCtrl.buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, i) {
                final btn = panicCtrl.buttons[i];
                return Stack(
                  children: [
                    // Tap rápido: dispara alerta
                    GestureDetector(
                      onTap: () {
                        if (btn.useButton) panicCtrl.triggerAlert(btn);
                      },
                      child: PanicButtonCard(
                        button: btn,
                        onTap: () {},
                        onDelete: () => panicCtrl.deleteButton(btn.id),
                      ),
                    ),
                    // Icono editar → lleva al formulario
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => Get.to(() => ButtonFormPage(existing: btn)),
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

      // ───── FAB Nuevo ─────
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () => Get.to(() => const ButtonFormPage()),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
