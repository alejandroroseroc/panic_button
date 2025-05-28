// lib/widgets/home_drawer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/contact_screen.dart';
import 'package:panic_button/presentation/pages/graph_page.dart';
import 'package:panic_button/presentation/pages/map_page.dart';
import 'package:panic_button/presentation/pages/profile_screen.dart';
import 'package:panic_button/presentation/pages/settings_screen.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';



class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl    = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final user = authCtrl.user.value;
              final avatarFile = profileCtrl.avatarFile.value;
              return UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? 'Usuario', style: const TextStyle(color: Colors.white)),
                accountEmail: Text(user?.email ?? 'correo@ejemplo.com', style: const TextStyle(color: Colors.white70)),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Cierra el drawer
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
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], // Colores de tu AppBar o un gradiente atractivo
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            }),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Perfil',
              onTap: () => Get.to(() => const ProfileScreen()),
            ),
            _buildDrawerItem(
              icon: Icons.group,
              title: 'Contactos',
              onTap: () => Get.to(() => const ContactsScreen()),
            ),
            _buildDrawerItem(
              icon: Icons.map,
              title: 'Mapa de Alertas',
              onTap: () => Get.to(() => const MapPage()),
            ),
            _buildDrawerItem(
              icon: Icons.bar_chart,
              title: 'Estadísticas',
              onTap: () => Get.to(() => const GraphPage()),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Ajustes',
              onTap: () => Get.to(() => const SettingsScreen()),
            ),
            const Spacer(),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Cerrar Sesión',
              textColor: Colors.red,
              onTap: () => authCtrl.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor == Colors.red ? Colors.red : Colors.blueGrey[700]),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: () {
        Get.back(); // Cierra el drawer automáticamente al navegar
        onTap();
      },
    );
  }
}