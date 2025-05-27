import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/contact_screen.dart';

import '../../controllers/auth_controller.dart';
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
    final authCtrl  = Get.find<AuthController>();
    final panicCtrl = Get.find<PanicButtonController>();

    return Scaffold(
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
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Mis Botones de Pánico'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authCtrl.logout(),
          )
        ],
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
              child: Text('Error: ${panicCtrl.error.value}', style: const TextStyle(color: Colors.red)),
            );
          }
          if (panicCtrl.buttons.isEmpty) {
            return const Center(
              child: Text('No tienes botones aún', style: TextStyle(color: Colors.white70)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: panicCtrl.buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1
              ),
              itemBuilder: (_, i) {
                final btn = panicCtrl.buttons[i];
                return Stack(
                  children: [
                    // tarjeta tappable
                    PanicButtonCard(
                      button: btn,
                      onTap: () {
                        debugPrint('>>> Botón pulsado: ${btn.title}');
                        panicCtrl.triggerAlert(btn);
                      },
                      onDelete: () => panicCtrl.deleteButton(btn.id),
                    ),
                    // editar
                    Positioned(
                      bottom: 8, right: 8,
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () => Get.to(() => const ButtonFormPage()),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
