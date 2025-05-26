// lib/data/repositories/alert_log_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:panic_button/models/alert_log_model.dart';

import '../../core/constants/appwrite_constants.dart';

class AlertLogRepository {
  final Databases _databases;
  final Account _account;

  AlertLogRepository(this._databases, this._account);

  // Nombre de la caja Hive
  static const _boxName = 'alertLogsBox';

  /// Guarda localmente en Hive
  Future<void> saveLocal(AlertLogModel log) async {
    final box = Hive.box<AlertLogModel>(_boxName);
    await box.add(log);
  }

  /// Guarda remotamente en Appwrite, asegurando que Role.user tenga un ID válido
  Future<void> saveRemote(AlertLogModel log) async {
    // 1) Obtenemos el usuario actual de Appwrite
    final me = await _account.get();
    final userId = me.$id;

    // 2) Creamos el documento con permisos correctos
    await _databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdAlertLogs,
      documentId: ID.unique(),
      data: log.toJson(),
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );
  }
}
