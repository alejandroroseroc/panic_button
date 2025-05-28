import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:panic_button/controllers/profile_controller.dart';
import 'package:panic_button/models/settings_model.dart';

import 'core/config/appwrite_config.dart';
import 'core/config/hive_config.dart';

// Modelos Hive
import 'models/message_template_model.dart';
import 'models/alert_log_model.dart';

// Repositorios
import 'data/repositories/auth_repository.dart';
import 'data/repositories/panic_button_repository.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/alert_log_repository.dart';
import 'data/repositories/message_template_repository.dart';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/panic_button_controller.dart';
import 'controllers/contact_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/alert_log_controller.dart';
import 'controllers/message_template_controller.dart';

// Servicios
import 'services/shake_service.dart';
import 'services/voice_service.dart';

// Pantallas
import 'presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0) Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MessageTemplateModelAdapter());
  Hive.registerAdapter(AlertLogModelAdapter());
  await HiveConfig.initHive();
  await Hive.openBox<MessageTemplateModel>('messageTemplatesBox');

  // 1) Appwrite
  final client = AppwriteConfig.initClient();
  final account = Account(client);
  final databases = Databases(client);

  // 2) Auth
  Get.put(AuthRepository(account));
  Get.put(AuthController(Get.find()));
  Get.put(ProfileController());

  // 3) PanicButton
  final panicRepo = PanicButtonRepository(databases);
  Get.put(panicRepo);
  Get.put(PanicButtonController(repo: panicRepo, account: account));

  // 4) Contacts
  final contactRepo = ContactRepository(databases, account);
  Get.put(contactRepo);
  Get.put(ContactController(repo: contactRepo));

  // 5) Settings
  final settingsRepo = SettingsRepository();
  Get.put(settingsRepo);
  final settingsCtrl = Get.put(SettingsController(repo: settingsRepo));

  // 6) AlertLog
  final alertLogRepo = AlertLogRepository(databases, account);
  Get.put(alertLogRepo);
  Get.put(AlertLogController(repo: alertLogRepo));

  // 7) Message Templates
  final tmplRepo = MessageTemplateRepository(databases, account);
  Get.put(tmplRepo);
  Get.put(MessageTemplateController(repo: tmplRepo));

  // 8) Shake & Voice services + logs
  final shakeSvc = ShakeService();
  final voiceSvc = VoiceService();
  ever<SettingsModel?>(settingsCtrl.prefs, (model) {
    if (model?.useShake == true) shakeSvc.start(); else shakeSvc.stop();
    if (model?.useVoice == true) voiceSvc.start(); else voiceSvc.stop();
  });

  // 9) Run app
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
