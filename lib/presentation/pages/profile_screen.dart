import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../pages/contact_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegúrate de haber registrado ProfileController en main.dart:
    // Get.put(ProfileController());
    final authCtrl    = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();

    return Scaffold(
      // Degradado en el AppBar
      appBar: AppBar(
        title: Text('Mi Perfil', style: GoogleFonts.lato()),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
        return SingleChildScrollView(
          child: Column(
            children: [
              // Fondo degradado tras la cabecera de perfil
              Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: profileCtrl.pickAvatar,
                    child: Obx(() {
                      final file = profileCtrl.avatarFile.value;
                      if (file != null) {
                        return CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(file),
                        );
                      }
                      // Si no hay imagen, ponemos la inicial
                      final letter = user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?';
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Text(letter,
                            style: const TextStyle(fontSize: 48, color: Color(0xFF6A1B9A))),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name,
                  style: GoogleFonts.lato(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(user.email,
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 24),

              // Botón Mis Contactos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const ContactsScreen()),
                  icon: const Icon(Icons.group),
                  label: const Text('Mis Contactos'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              // Botón Ubicación Actual
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: profileCtrl.fetchLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Mi Ubicación'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Muestra la ubicación si ya la obtuvo
              Obx(() {
                if (profileCtrl.isLoadingLocation.value) {
                  return const CircularProgressIndicator();
                }
                if (profileCtrl.locationError.value.isNotEmpty) {
                  return Text('Error: ${profileCtrl.locationError.value}',
                      style: const TextStyle(color: Colors.red));
                }
                final loc = profileCtrl.currentLocation.value;
                if (loc == null) return const SizedBox.shrink();
                return Text(
                  'Lat: ${loc.latitude?.toStringAsFixed(5)}, '
                  'Lng: ${loc.longitude?.toStringAsFixed(5)}',
                  style: GoogleFonts.lato(fontSize: 16),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}
