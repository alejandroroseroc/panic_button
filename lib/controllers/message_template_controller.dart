import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/message_template_repository.dart';
import '../models/message_template_model.dart';

class MessageTemplateController extends GetxController {
  final MessageTemplateRepository _repo;
  var templates = <MessageTemplateModel>[].obs;

  MessageTemplateController({required MessageTemplateRepository repo}) : _repo = repo;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    templates.value = await _repo.loadAll();
  }

  Future<void> createTemplate(MessageTemplateModel t) async {
    final saved = await _repo.create(t);
    templates.add(saved);
  }

  Future<void> updateTemplate(MessageTemplateModel t) async {
    final updated = await _repo.update(t);
    final idx = templates.indexWhere((e) => e.id == updated.id);
    if (idx != -1) templates[idx] = updated;
  }

  Future<void> deleteTemplate(String id) async {
    await _repo.delete(id);
    templates.removeWhere((e) => e.id == id);
  }

  /// Diálogo para crear nueva plantilla
  void showAddDialog(BuildContext ctx) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Nueva plantilla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              createTemplate(MessageTemplateModel(
                id: '',
                title: titleCtrl.text,
                content: contentCtrl.text,
                userId: '',           // se rellena en repositorio
                usedForPolice: false, // o valor por defecto
                usedForAmbulance: false,
                usedForContacts: true,
                createdAt: DateTime.now(),
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para editar plantilla existente
  void showEditDialog(MessageTemplateModel t) {
    final titleCtrl = TextEditingController(text: t.title);
    final contentCtrl = TextEditingController(text: t.content);
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: const Text('Editar plantilla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              updateTemplate(t.copyWith(
                title: titleCtrl.text,
                content: contentCtrl.text,
                // puedes permitir editar también flags y createdAt si quieres
              ));
              Navigator.pop(Get.context!);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Obtiene el contenido de la plantilla por ID
  String getContent(String id) {
    for (var tpl in templates) {
      if (tpl.id == id) return tpl.content;
    }
    return templates.isNotEmpty ? templates.first.content : '';
  }
}
