// lib/controllers/contact_controller.dart

import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../data/repositories/contact_repository.dart';
import '../models/contact_model.dart';

class ContactController extends GetxController {
  final ContactRepository _repo;

  ContactController({required ContactRepository repo}) : _repo = repo;

  final contacts = <ContactModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onClose() {
    contacts.clear();
    super.onClose();
  }

  Future<void> fetchContacts() async {
    isLoading.value = true;
    error.value = '';
    try {
      contacts.value = await _repo.fetchContacts();
    } on AppwriteException catch (e) {
      error.value = e.message ?? e.toString();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addContact(ContactModel contact) async {
  isLoading.value = true;
  try {
    final me = await _repo.getAccount();
    final withUserId = contact.copyWith(userId: me.$id);

    final newContact = await _repo.createContact(withUserId);
    contacts.add(newContact);
  } catch (e) {
    error.value = e.toString();
  } finally {
    isLoading.value = false;
  }
}


  Future<void> updateContact(ContactModel contact) async {
    isLoading.value = true;
    try {
      final updated = await _repo.updateContact(contact);
      final idx = contacts.indexWhere((c) => c.id == updated.id);
      if (idx != -1) contacts[idx] = updated;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _repo.deleteContact(id);
      contacts.removeWhere((c) => c.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }
}
