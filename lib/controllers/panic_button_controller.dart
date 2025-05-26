// lib/controllers/panic_button_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/repositories/panic_button_repository.dart';
import '../models/panic_button_model.dart';
import 'alert_log_controller.dart';
import 'contact_controller.dart';
import 'message_template_controller.dart';

class PanicButtonController extends GetxController {
  final PanicButtonRepository _repo;
  final Account _account;

  PanicButtonController({
    required PanicButtonRepository repo,
    required Account account,
  })  : _repo = repo,
        _account = account;

  var buttons = <PanicButtonModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadButtons();
  }

  Future<void> loadButtons() async {
    isLoading.value = true;
    try {
      final me = await _account.get();
      buttons.value = await _repo.fetchButtons(me.$id);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addButton(PanicButtonModel btn) async {
    isLoading.value = true;
    try {
      final me = await _account.get();
      final toSave = btn.copyWith(userId: me.$id);
      final newBtn = await _repo.createButton(toSave);
      buttons.add(newBtn);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateButton(PanicButtonModel btn) async {
    isLoading.value = true;
    try {
      final updated = await _repo.updateButton(btn);
      final idx = buttons.indexWhere((b) => b.id == updated.id);
      if (idx != -1) buttons[idx] = updated;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteButton(String id) async {
    try {
      await _repo.deleteButton(id);
      buttons.removeWhere((b) => b.id == id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// 1) log  2) abre app de SMS con varios destinatarios  3) llamada única
  Future<void> triggerAlert(PanicButtonModel btn) async {
    if (kDebugMode) print('🔥 triggerAlert para botón ${btn.id}');

    // 1) guardamos el log
    await Get.find<AlertLogController>().logAlert(btn.id);

    // 2) SMS grupal (abre la app de SMS)
    final contactCtrl = Get.find<ContactController>();
    final tmplCtrl    = Get.find<MessageTemplateController>();

    final numbers = contactCtrl.contacts
        .where((c) => btn.contactIds.contains(c.id))
        .map((c) => c.phone)
        .toList();

    final message = tmplCtrl.getContent(btn.messageTemplateId);
    if (numbers.isNotEmpty) {
      final uri = Uri(
        scheme: 'sms',
        path: numbers.join(','),
        queryParameters: {'body': message},
      );
      if (await canLaunchUrl(uri)) {
        if (kDebugMode) print('  -> Abriendo SMS Uri: $uri');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'No se pudo abrir la aplicación de SMS');
      }
    }

    // 3) llamada única
    Uri? callUri;
    switch (btn.callTarget) {
      case CallTarget.police:
        callUri = Uri.parse('tel:911');
        break;
      case CallTarget.ambulance:
        callUri = Uri.parse('tel:912');
        break;
      case CallTarget.contact:
        final target = contactCtrl.contacts
            .firstWhereOrNull((c) => c.id == btn.callContactId);
        if (target != null) callUri = Uri.parse('tel:${target.phone}');
        break;
      case CallTarget.none:
        break;
    }
    if (callUri != null && await canLaunchUrl(callUri)) {
      await launchUrl(callUri, mode: LaunchMode.externalApplication);
    }
  }
}
