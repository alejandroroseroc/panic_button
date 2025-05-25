// lib/presentation/pages/button_form_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/panic_button_controller.dart';
import '../../controllers/contact_controller.dart';
import '../../controllers/message_template_controller.dart';
import '../../models/panic_button_model.dart';

class ButtonFormPage extends StatefulWidget {
  final PanicButtonModel? existing;
  const ButtonFormPage({Key? key, this.existing}) : super(key: key);

  @override
  State<ButtonFormPage> createState() => _ButtonFormPageState();
}

class _ButtonFormPageState extends State<ButtonFormPage> {
  final _titleCtrl = TextEditingController();
  int _color = 0xFF2196F3;
  List<String> _selectedContacts = [];
  bool _alertPolice = false, _alertAmbulance = false;
  bool _useButton = true, _useVoice = false, _useShake = false, _usePush = false;
  String? _templateId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _color = e.color;
      _selectedContacts = [...e.contactIds];
      _alertPolice = e.alertToPolice;
      _alertAmbulance = e.alertToAmbulance;
      _useButton = e.useButton;
      _useVoice = e.useVoice;
      _useShake = e.useShake;
      _usePush = e.usePush;
      _templateId = e.messageTemplateId;
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

    // Asegura que templateId siempre exista en la lista
    if (tmplCtrl.templates.isNotEmpty) {
      final exists = tmplCtrl.templates.any((t) => t.id == _templateId);
      if (!exists) {
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
              child: Column(
                children: [
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
                    child: const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildColorCircle(0xFF2196F3),
                      _buildColorCircle(0xFFF44336),
                      _buildColorCircle(0xFF4CAF50),
                      _buildColorCircle(0xFFFFC107),
                    ],
                  ),
                  const Divider(height: 32),

                  // Contactos
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Contactos', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
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

                  // Switches
                  SwitchListTile(
                    title: const Text('Botón en pantalla'),
                    value: _useButton,
                    onChanged: (v) => setState(() => _useButton = v),
                  ),
                  SwitchListTile(
                    title: const Text('Voz'),
                    value: _useVoice,
                    onChanged: (v) => setState(() => _useVoice = v),
                  ),
                  SwitchListTile(
                    title: const Text('Sacudida'),
                    value: _useShake,
                    onChanged: (v) => setState(() => _useShake = v),
                  ),
                  SwitchListTile(
                    title: const Text('Push'),
                    value: _usePush,
                    onChanged: (v) => setState(() => _usePush = v),
                  ),
                  const Divider(height: 32),

                  // Plantilla
                  if (tmplCtrl.templates.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _templateId,
                      decoration: const InputDecoration(
                        labelText: 'Plantilla de mensaje',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: tmplCtrl.templates
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                          .toList(),
                      onChanged: (v) => setState(() => _templateId = v),
                    )
                  else
                    const Text(
                      'No hay plantillas.\nVe a Ajustes para crear una.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  const Divider(height: 32),

                  // Emergencias
                  CheckboxListTile(
                    title: const Text('Policía'),
                    value: _alertPolice,
                    onChanged: (v) => setState(() => _alertPolice = v!),
                  ),
                  CheckboxListTile(
                    title: const Text('Ambulancia'),
                    value: _alertAmbulance,
                    onChanged: (v) => setState(() => _alertAmbulance = v!),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      if (tmplCtrl.templates.isNotEmpty && _templateId == null) return;
                      final model = PanicButtonModel(
                        id: widget.existing?.id ?? '',
                        title: _titleCtrl.text.trim(),
                        color: _color,
                        contactIds: _selectedContacts,
                        alertToPolice: _alertPolice,
                        alertToAmbulance: _alertAmbulance,
                        useButton: _useButton,
                        useVoice: _useVoice,
                        useShake: _useShake,
                        usePush: _usePush,
                        messageTemplateId: _templateId ?? '',
                        // <-- Aquí preservamos el userId existente:
                        userId: widget.existing?.userId ?? '',
                      );
                      final panic = Get.find<PanicButtonController>();
                      if (widget.existing == null) panic.addButton(model);
                      else panic.updateButton(model);
                      Get.back();
                    },
                    child: Text(widget.existing == null ? 'Crear' : 'Guardar'),
                  ),
                ],
              ),
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
