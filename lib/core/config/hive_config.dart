import 'package:hive_flutter/hive_flutter.dart';
import '../../models/alert_log_model.dart'; // 🛠 CAMBIO AQUÍ

class HiveConfig {
  /// Llama esto en main() antes de abrir cajas o usar Hive
  static Future<void> initHive() async {
    // await Hive.initFlutter(); // 🛠 CAMBIO AQUÍ: ya se hace en main.dart

    // Abrimos las cajas con tipo cuando corresponde
    await Hive.openBox('panicButtonsBox');
    await Hive.openBox('contactsBox');
    await Hive.openBox<AlertLogModel>('alertLogsBox'); // 🛠 CAMBIO AQUÍ: con tipo correcto
    await Hive.openBox('settingsBox'); 
  }
}
