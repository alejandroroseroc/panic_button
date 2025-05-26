import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../core/constants/appwrite_constants.dart';
import '../../models/contact_model.dart';

class ContactRepository {
  final Databases _databases;
  final Account _account;

  ContactRepository(this._databases, this._account);

  /// Crea un nuevo contacto y lo asocia al usuario actual
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

  /// Obtiene todos los contactos del usuario actual
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

  /// Actualiza un contacto existente conservando el campo userId
  Future<ContactModel> updateContact(ContactModel contact) async {
    // Aseguramos que en el mapa de datos venga siempre userId
    final data = contact.toJson()
      ..['userId'] = contact.userId;

    final doc = await _databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdContacts,
      documentId: contact.id,
      data: data,
    );
    return ContactModel.fromJson(doc.data);
  }

  /// Elimina un contacto por su ID
  Future<void> deleteContact(String contactId) async {
    await _databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionIdContacts,
      documentId: contactId,
    );
  }

  /// Devuelve la cuenta del usuario actual
  Future<User> getAccount() async {
    return await _account.get();
  }
}
