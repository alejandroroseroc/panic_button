// lib/controllers/alert_log_controller.dart

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/alert_log_model.dart';
import '../data/repositories/alert_log_repository.dart';

class AlertLogController extends GetxController {
  final AlertLogRepository _repo;

  AlertLogController({required AlertLogRepository repo}) : _repo = repo;

  /// Guarda un log de alerta (offline con Hive y online con Appwrite).
  Future<void> logAlert(String buttonId) async {
    final now = DateTime.now();
    // 1) Crear modelo
    final log = AlertLogModel(
      id: '', // Appwrite lo asignará
      buttonId: buttonId,
      timestamp: now,
      latitude: 0.0,  // luego integrarás geolocalización
      longitude: 0.0,
      userId: '',      // repository lo rellenará con el usuario actual
    );
    // 2) Guardar localmente
    await _repo.saveLocal(log);
    // 3) Guardar remoto
    await _repo.saveRemote(log);
  }

  /// Devuelve todos los logs locales (Hive).
  Future<List<AlertLogModel>> fetchAllLocal() async {
    final box = Hive.box<AlertLogModel>('alertLogsBox');
    return box.values.toList();
  }

  /// Devuelve el último log local según el timestamp, o null si no hay ninguno.
  Future<AlertLogModel?> getLast() async {
    final box = Hive.box<AlertLogModel>('alertLogsBox');
    if (box.isEmpty) return null;
    final all = box.values.toList();
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all.last;
  }
}
