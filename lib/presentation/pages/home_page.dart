// lib/presentation/pages/home_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/contact_screen.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../presentation/pages/button_form_page.dart';
import '../../presentation/pages/map_page.dart';
import '../../presentation/pages/graph_page.dart';
import '../../presentation/pages/profile_screen.dart';
import '../../presentation/pages/settings_screen.dart';
import '../../widgets/panic_button_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl    = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();
    final panicCtrl   = Get.find<PanicButtonController>();

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Obx(() {
                final user = authCtrl.user.value;
                final avatarFile = profileCtrl.avatarFile.value;
                return UserAccountsDrawerHeader(
                  accountName: Text(user?.name ?? '--'),
                  accountEmail: Text(user?.email ?? '--'),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ProfileScreen());
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      backgroundImage: avatarFile != null
                          ? FileImage(avatarFile) as ImageProvider
                          : null,
                      child: avatarFile == null
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style:
                                  const TextStyle(fontSize: 32, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              }),
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
                leading: const Icon(Icons.map),
                title: const Text('Mapa de Alertas'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const MapPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Estadísticas'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const GraphPage());
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
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  authCtrl.logout();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Mis Botones de Pánico'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        // <-- eliminado el IconButton de logout aquí
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
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (panicCtrl.error.value.isNotEmpty) {
            return Center(
              child: Text('Error: ${panicCtrl.error.value}',
                  style: const TextStyle(color: Colors.red)),
            );
          }
          if (panicCtrl.buttons.isEmpty) {
            return const Center(
              child: Text('No tienes botones aún',
                  style: TextStyle(color: Colors.white70)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: panicCtrl.buttons.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1),
              itemBuilder: (_, i) {
                final btn = panicCtrl.buttons[i];
                return Stack(
                  children: [
                    PanicButtonCard(
                      button: btn,
                      onTap: () => panicCtrl.triggerAlert(btn),
                      onDelete: () => panicCtrl.deleteButton(btn.id),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () =>
                            Get.to(() => ButtonFormPage(existing: btn)),
                        child: const Icon(Icons.edit,
                            color: Colors.white70, size: 24),
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
        onPressed: () => Get.to(() => const ButtonFormPage()),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
