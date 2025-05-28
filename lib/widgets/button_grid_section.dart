// lib/widgets/button_grid_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panic_button/presentation/pages/button_form_page.dart';

import '../controllers/panic_button_controller.dart';

import 'panic_button_card.dart';

class ButtonGridSection extends StatelessWidget {
  const ButtonGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final panicCtrl = Get.find<PanicButtonController>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF80DEEA)], // Gradiente de fondo que ya usas
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
                style: const TextStyle(color: Colors.red, fontSize: 16)),
          );
        }
        if (panicCtrl.buttons.isEmpty) {
          return const Center(
            child: Text('No tienes botones aún. ¡Crea uno!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18)),
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
                    child: GestureDetector( // Usar GestureDetector para el icono de editar
                      onTap: () => Get.to(() => ButtonFormPage(existing: btn)),
                      child: Container(
                        padding: const EdgeInsets.all(4), // Pequeño padding para el área de toque
                        decoration: BoxDecoration(
                          color: Colors.black38, // Fondo semi-transparente para el icono
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white70, size: 24),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}