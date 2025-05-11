// lib/data/repositories/contact_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../models/contact_model.dart';

class ContactRepository {
  final Databases _databases;
  final Account _account;

  ContactRepository(this._databases, this._account);

  Future<ContactModel> createContact(ContactModel contact) async {
  final doc = await _databases.createDocument(
    databaseId: AppwriteConstants.databaseId,
    collectionId: AppwriteConstants.collectionIdContacts,
    documentId: ID.unique(),
    data: contact.toJson(),
    permissions: [
      Permission.read(Role.user(contact.userId)),
      Permission.update(Role.user(contact.userId)),
      Permission.delete(Role.user(contact.userId)),
    ],
  );
  return ContactModel.fromJson(doc.data);
}

  Future<List<ContactModel>> fetchContacts() async {
    final me = await _account.get();
    final userId = me.$id;

    final res = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdContacts,
      queries: [Query.equal('userId', userId)],
    );
    return res.documents.map((d) => ContactModel.fromJson(d.data)).toList();
  }

  Future<ContactModel> updateContact(ContactModel contact) async {
    final me = await _account.get();
    final userId = me.$id;
    // Asegúrate de que el documento ya existe y pertenece al usuario

    final doc = await _databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdContacts,
      documentId: contact.id,
      data: contact.toJson(),
      // No necesitas permisos aquí, sólo bastará que el usuario tenga update
    );
    return ContactModel.fromJson(doc.data);
  }

  Future<void> deleteContact(String contactId) async {
    await _databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdContacts,
      documentId: contactId,
    );
  }
  Future<User> getAccount() async {
  return await _account.get();
}
}
