// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/panic_button_controller.dart';
import '../../controllers/contact_controller.dart';
import '../../controllers/message_template_controller.dart';

import 'button_form_page.dart';
import '../../widgets/home_drawer.dart'; // Importa el nuevo widget
import '../../widgets/button_grid_section.dart'; // Importa el nuevo widget

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Los find de controladores ahora están bien ya que los usas en el initState
  // y también los puedes pasar a los widgets hijos si es necesario
  final authCtrl    = Get.find<AuthController>();
  final panicCtrl   = Get.find<PanicButtonController>();
  final contactCtrl = Get.find<ContactController>();
  final tmplCtrl    = Get.find<MessageTemplateController>();

  @override
  void initState() {
    super.initState();
    // Sólo aquí, después de que SplashPage confirmó la sesión:
    panicCtrl.loadButtons();
    contactCtrl.fetchContacts();
    tmplCtrl.loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(), // Usamos el nuevo widget del Drawer
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Azul oscuro
        elevation: 4,
        centerTitle: true,                // Centra el título
        title: const Text(
          'Mis Botones de Pánico',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,            // Íconos (drawer, acciones) en blanco
        ),
      ),
      body: const ButtonGridSection(), // Usamos el nuevo widget para el cuerpo
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () => Get.to(() => const ButtonFormPage()),
        backgroundColor: Colors.amber, // Color de tu botón flotante
        foregroundColor: Colors.white, // Color del icono y texto en el botón
      ),
    );
  }
}