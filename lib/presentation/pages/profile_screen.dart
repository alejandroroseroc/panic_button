import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../pages/contact_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl    = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil', style: GoogleFonts.lato()),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
            ),
          ),
        ),
      ),
      body: Obx(() {
        final user = authCtrl.user.value;
        if (authCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (user == null) {
          return const Center(child: Text('Error al cargar perfil'));
        }
        final avatarFile = profileCtrl.avatarFile.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: profileCtrl.pickAvatar,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      avatarFile != null ? FileImage(avatarFile) : null,
                  child: avatarFile == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 48, color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(user.name, style: GoogleFonts.lato(fontSize: 24))),
            Center(child: Text(user.email, style: GoogleFonts.lato(color: Colors.grey))),
            const SizedBox(height: 32),

            // — Botón Editar Nombre
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Cambiar Nombre'),
              onPressed: () => _showEditNameDialog(context, profileCtrl, user.name),
            ),
            const SizedBox(height: 8),

            // — Botón Editar Email
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Cambiar Email'),
              onPressed: () => _showEditEmailDialog(context, profileCtrl),
            ),
            const SizedBox(height: 8),

            // — Botón Cambiar Contraseña
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Cambiar Contraseña'),
              onPressed: () => _showChangePasswordDialog(context, profileCtrl),
            ),

            const SizedBox(height: 24),
            // — Mis Contactos (igual que antes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.group),
                label: const Text('Mis Contactos'),
                onPressed: () => Get.to(() => const ContactsScreen()),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showEditNameDialog(BuildContext ctx, ProfileController ctrl, String currentName) {
    final nameCtrl = TextEditingController(text: currentName);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo Nombre'),
        content: TextField(controller: nameCtrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ctrl.changeName(nameCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext ctx, ProfileController ctrl) {
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Nuevo Email')),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Contraseña actual'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ctrl.changeEmail(emailCtrl.text.trim(), passCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext ctx, ProfileController ctrl) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, decoration: const InputDecoration(labelText: 'Contraseña actual'), obscureText: true),
            TextField(controller: newCtrl, decoration: const InputDecoration(labelText: 'Nueva contraseña'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ctrl.changePassword(oldCtrl.text, newCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
