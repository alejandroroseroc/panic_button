
// lib/presentation/pages/button_form_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/panic_button_controller.dart';
import '../../controllers/contact_controller.dart';
import '../../controllers/message_template_controller.dart';
import '../../models/panic_button_model.dart';

class ButtonFormPage extends StatefulWidget {
  final PanicButtonModel? existing;
  const ButtonFormPage({super.key, this.existing});

  @override
  State<ButtonFormPage> createState() => _ButtonFormPageState();
}

class _ButtonFormPageState extends State<ButtonFormPage> {
  final _titleCtrl = TextEditingController();
  int _color = 0xFF2196F3;
  List<String> _selectedContacts = [];
  String? _templateId;
  CallTarget _callTarget = CallTarget.none;
  String _callContactId = '';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _color = e.color;
      _selectedContacts = [...e.contactIds];
      _templateId = e.messageTemplateId;
      _callTarget = e.callTarget;
      _callContactId = e.callContactId;
    }
    final tmpl = Get.find<MessageTemplateController>().templates;
    if (_templateId == null && tmpl.isNotEmpty) {
      _templateId = tmpl.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final panicCtrl   = Get.find<PanicButtonController>();
    final contactCtrl = Get.find<ContactController>();
    final tmplCtrl    = Get.find<MessageTemplateController>();

    // Asegura que _templateId esté en la lista
    if (_templateId != null && tmplCtrl.templates.isNotEmpty) {
      final found = tmplCtrl.templates.any((t) => t.id == _templateId);
      if (!found) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _templateId = tmplCtrl.templates.first.id;
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Nuevo Botón' : 'Editar Botón'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF80DEEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Título
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Color
                Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Color', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Wrap(spacing: 12, children: [
                  _buildColorCircle(0xFF2196F3),
                  _buildColorCircle(0xFFF44336),
                  _buildColorCircle(0xFF4CAF50),
                  _buildColorCircle(0xFFFFC107),
                ]),
                const Divider(height: 32),

                // SMS: plantilla
                Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Plantilla (SMS)', style: TextStyle(fontWeight: FontWeight.bold))),
                if (tmplCtrl.templates.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _templateId,
                    decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                    items: tmplCtrl.templates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                        .toList(),
                    onChanged: (v) => setState(() => _templateId = v),
                  )
                else
                  const Text('Crea antes una plantilla en Ajustes', style: TextStyle(color: Colors.red)),
                const Divider(height: 32),

                // SMS: contactos
                Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Contactos (SMS)', style: TextStyle(fontWeight: FontWeight.bold))),
                ...contactCtrl.contacts.map((c) {
                  final sel = _selectedContacts.contains(c.id);
                  return CheckboxListTile(
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                    value: sel,
                    onChanged: (v) => setState(() {
                      if (v == true) _selectedContacts.add(c.id);
                      else _selectedContacts.remove(c.id);
                    }),
                  );
                }),
                const Divider(height: 32),

                // Llamada única
                Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Llamada', style: TextStyle(fontWeight: FontWeight.bold))),
                ...CallTarget.values.map((ct) {
                  final label = {
                    CallTarget.none: 'Ninguna',
                    CallTarget.police: 'Policía',
                    CallTarget.ambulance: 'Ambulancia',
                    CallTarget.contact: 'Un contacto',
                  }[ct]!;
                  return RadioListTile<CallTarget>(
                    title: Text(label),
                    value: ct,
                    groupValue: _callTarget,
                    onChanged: (v) => setState(() {
                      _callTarget = v!;
                      if (v != CallTarget.contact) _callContactId = '';
                    }),
                  );
                }).toList(),
                if (_callTarget == CallTarget.contact)
                  DropdownButtonFormField<String>(
                    value: _callContactId.isNotEmpty
                        ? _callContactId
                        : (_selectedContacts.isNotEmpty ? _selectedContacts.first : null),
                    decoration: const InputDecoration(labelText: 'Elegir contacto'),
                    items: _selectedContacts
                        .map((id) => contactCtrl.contacts.firstWhere((c) => c.id == id))
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _callContactId = v!),
                  ),
                const SizedBox(height: 24),

                // Crear/Guardar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () {
                    final model = PanicButtonModel(
                      id: widget.existing?.id ?? '',
                      title: _titleCtrl.text.trim(),
                      color: _color,
                      contactIds: _selectedContacts,
                      messageTemplateId: _templateId ?? '',
                      callTarget: _callTarget,
                      callContactId: _callContactId,
                      userId: widget.existing?.userId ?? '',
                    );
                    if (widget.existing == null) panicCtrl.addButton(model);
                    else panicCtrl.updateButton(model);
                    Get.back();
                  },
                  child: Text(widget.existing == null ? 'Crear' : 'Guardar'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(int hex) {
    return GestureDetector(
      onTap: () => setState(() => _color = hex),
      child: CircleAvatar(
        backgroundColor: Color(hex),
        radius: 20,
        child: _color == hex ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

