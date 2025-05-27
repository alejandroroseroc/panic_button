import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/panic_button_controller.dart';
import '../models/panic_button_model.dart';

class ShakeService {
  static const double _threshold = 15.0; // ajusta sensibilidad
  StreamSubscription<AccelerometerEvent>? _sub;

  void start() {
    final settings = Get.find<SettingsController>();
    final panic    = Get.find<PanicButtonController>();

    _sub = accelerometerEvents.listen((e) {
      final magnitude = e.x * e.x + e.y * e.y + e.z * e.z;
      if (magnitude > _threshold * _threshold) {
        // “Shake” detectado: dispara alertas de todos los botones que tengan shake
        final triggers = settings.prefs.value.buttonTriggers;
        for (var btn in panic.buttons) {
          if (triggers[btn.id]?.contains('shake') == true) {
            panic.triggerAlert(btn);
          }
        }
      }
    });
  }

  void stop() {
    _sub?.cancel();
  }
}
