// lib/presentation/pages/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/contact_screen.dart';
import '../../controllers/auth_controller.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Obx(() {
        if (authCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = authCtrl.user.value;
        if (user == null) {
          return const Center(child: Text('No se pudo cargar el perfil'));
        }

        // Obtienes: user.name, user.email, user.$id
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                child: Text(
                  (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('ID: ${user.$id}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const ContactsScreen());
                },
                icon: const Icon(Icons.group),
                label: const Text('Mis Contactos'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
