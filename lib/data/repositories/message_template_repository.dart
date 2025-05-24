// lib/data/repositories/message_template_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../models/message_template_model.dart';

class MessageTemplateRepository {
  final Databases _databases;
  final Account _account;

  MessageTemplateRepository(this._databases, this._account);

  /// Carga todas las plantillas del usuario actual
  Future<List<MessageTemplateModel>> loadAll() async {
    final me = await _account.get();
    final res = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdmessageTemplates, // el ID de tu colección
      queries: [Query.equal('userId', me.$id)],
    );
    return res.documents
        .map((d) => MessageTemplateModel.fromMap(d.data))
        .toList();
  }

  Future<MessageTemplateModel> create(MessageTemplateModel t) async {
    final me = await _account.get();
    final doc = await _databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdmessageTemplates,
      documentId: ID.unique(),
      data: {
        ...t.toMap(),
        'userId': me.$id,
        'createdAt': DateTime.now().toIso8601String(),
      },
      permissions: [
        Permission.read(Role.user(me.$id)),
        Permission.update(Role.user(me.$id)),
        Permission.delete(Role.user(me.$id)),
      ],
    );
    return MessageTemplateModel.fromMap(doc.data);
  }

  Future<MessageTemplateModel> update(MessageTemplateModel t) async {
    final doc = await _databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdmessageTemplates,
      documentId: t.id,
      data: t.toMap(),
    );
    return MessageTemplateModel.fromMap(doc.data);
  }

  Future<void> delete(String id) async {
    await _databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdmessageTemplates,
      documentId: id,
    );
  }
}
