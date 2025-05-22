import 'package:hive_flutter/hive_flutter.dart';

class HiveConfig {
  /// Llama esto en main() antes de abrir cajas o usar Hive
  static Future<void> initHive() async {
    await Hive.initFlutter();
    // Abre aquí todas tus cajas de datos locales
    await Hive.openBox('panicButtonsBox');
    await Hive.openBox('contactsBox');
    await Hive.openBox('alertLogsBox');
    await Hive.openBox('settingsBox'); 
  }
}
