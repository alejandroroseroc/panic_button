// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';

import 'core/config/appwrite_config.dart';
import 'core/config/hive_config.dart';

// Repositorios
import 'data/repositories/auth_repository.dart';
import 'data/repositories/panic_button_repository.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/alert_log_repository.dart';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/panic_button_controller.dart';
import 'controllers/contact_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/alert_log_controller.dart';

// Pantalla inicial
import 'presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0) Inicializar Hive
  await HiveConfig.initHive();

  // 1) Inicializar Appwrite
  final client    = AppwriteConfig.initClient();
  final account   = Account(client);
  final databases = Databases(client);

  // 2) Inyección de Auth
  Get.put(AuthRepository(account));
  Get.put(AuthController(Get.find()));

  // 3) Inyección de PanicButton
  final panicRepo = PanicButtonRepository(databases);
  Get.put(panicRepo);
  Get.put(PanicButtonController(repo: panicRepo, account: account));

  // 4) Inyección de Contacts
  final contactRepo = ContactRepository(databases, account);
  Get.put(contactRepo);
  Get.put(ContactController(repo: contactRepo));

  // 5) Inyección de Settings
  final settingsRepo = SettingsRepository();
  Get.put(settingsRepo);
  Get.put(SettingsController(repo: settingsRepo));

  // 6) Inyección de AlertLog
  final alertLogRepo = AlertLogRepository(databases);
  Get.put(alertLogRepo);
  Get.put(AlertLogController(repo: alertLogRepo));

  // 7) Arrancar la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Panic Button App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const SplashPage(),
    );
  }
}
