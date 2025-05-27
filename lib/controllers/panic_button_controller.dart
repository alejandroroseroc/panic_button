// lib/controllers/panic_button_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart'; // para firstWhereOrNull
import 'package:location/location.dart';     // <<— para geolocalización

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
      if (kDebugMode) print('Loaded buttons: ${buttons.map((b) => b.id).toList()}');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'No se pudieron cargar los botones: $e');
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
      if (kDebugMode) print('Added button: ${newBtn.id}');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'No se pudo crear el botón: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateButton(PanicButtonModel btn) async {
    isLoading.value = true;
    try {
      final updated = await _repo.updateButton(btn);
      final idx = buttons.indexWhere((b) => b.id == updated.id);
      if (idx != -1) {
        buttons[idx] = updated;
        if (kDebugMode) print('Updated button: ${updated.id}');
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'No se pudo actualizar el botón: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteButton(String id) async {
    isLoading.value = true;
    try {
      await _repo.deleteButton(id);
      buttons.removeWhere((b) => b.id == id);
      if (kDebugMode) print('Deleted button: $id');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'No se pudo eliminar el botón: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 1) Guarda log  
  /// 2) Abre app de SMS / WhatsApp  
  /// 3) Abre app de Teléfono para una llamada única
  Future<void> triggerAlert(PanicButtonModel btn) async {
    if (kDebugMode) print('🔥 triggerAlert para botón ${btn.id}');
    
    // 1) Log
    await Get.find<AlertLogController>().logAlert(btn.id);

    final contactCtrl = Get.find<ContactController>();
    final tmplCtrl    = Get.find<MessageTemplateController>();

    switch (btn.method) {
      case AlertMethod.sms:
        final numbers = contactCtrl.contacts
            .where((c) => btn.contactIds.contains(c.id))
            .map((c) => c.phone)
            .toList();
        final message = tmplCtrl.getContent(btn.messageTemplateId);
        if (numbers.isEmpty) {
          Get.snackbar('Info', 'No hay contactos seleccionados');
          return;
        }
        final smsUri = Uri(
          scheme: 'sms',
          path: numbers.join(','),
          queryParameters: {'body': message},
        );
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('Error', 'No se pudo abrir la aplicación de SMS');
        }
        break;

      case AlertMethod.whatsapp:
        // 2a) Obtener ubicación actual
        LocationData? locData;
        try {
          final loc = Location();
          if (await loc.requestPermission() == PermissionStatus.granted) {
            locData = await loc.getLocation();
          }
        } catch (e) {
          if (kDebugMode) print('No se pudo obtener ubicación: $e');
        }

        final messageBase = tmplCtrl.getContent(btn.messageTemplateId);
        // 2b) Construir mensaje con link de ubicación
        final locPart = (locData != null)
            ? '\nUbicación: https://maps.google.com/?q=${locData.latitude},${locData.longitude}'
            : '';
        final fullMessage = '$messageBase$locPart';

        final selected = contactCtrl.contacts
            .where((c) => btn.contactIds.contains(c.id))
            .toList();
        if (selected.isEmpty) {
          Get.snackbar('Info', 'No hay contactos seleccionados');
          return;
        }
        for (final c in selected) {
          final phoneForWp = c.whatsapp ? '+57${c.phone}' : c.phone;
          final uri = Uri.parse(
            'https://api.whatsapp.com/send?phone=$phoneForWp&text=${Uri.encodeComponent(fullMessage)}'
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar('Error', 'No se pudo abrir WhatsApp para $phoneForWp');
          }
        }
        break;

      case AlertMethod.call:
        Uri? callUri;
        switch (btn.callTarget) {
          case CallTarget.police:
            callUri = Uri.parse('tel:911');
            break;
          case CallTarget.ambulance:
            callUri = Uri.parse('tel:912');
            break;
          case CallTarget.contact:
            final target = contactCtrl.contacts.firstWhereOrNull(
              (c) => c.id == btn.callContactId,
            );
            if (target != null) {
              callUri = Uri.parse('tel:${target.phone}');
            } else {
              Get.snackbar('Info', 'No hay contacto seleccionado para llamada');
            }
            break;
          default:
            break;
        }
        if (callUri != null && await canLaunchUrl(callUri)) {
          await launchUrl(callUri, mode: LaunchMode.externalApplication);
        }
        break;
    }
  }
}
