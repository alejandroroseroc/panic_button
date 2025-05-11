// lib/data/repositories/alert_log_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:panic_button/models/alert_log_model.dart';

import '../../core/constants/appwrite_constants.dart';

class AlertLogRepository {
  final Databases _databases;

  AlertLogRepository(this._databases);

  // Hive box para logs
  static const _boxName = 'alertLogsBox';

  Future<void> saveLocal(AlertLogModel log) async {
    final box = Hive.box<AlertLogModel>(_boxName);
    await box.add(log);
  }

  Future<void> saveRemote(AlertLogModel log) async {
    final me = ''; // recuperarás el userId desde Account si lo deseas
    await _databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdAlertLogs,
      documentId: ID.unique(),
      data: log.toJson(),
      permissions: [
        Permission.read(Role.user(me)),
        Permission.delete(Role.user(me)),
      ],
    );
  }
}
