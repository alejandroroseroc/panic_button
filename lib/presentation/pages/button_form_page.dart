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
  AlertMethod _method = AlertMethod.sms;
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
      _method = e.method;
      _selectedContacts = [...e.contactIds];
      _templateId = e.messageTemplateId;
      _callTarget = e.callTarget;
      _callContactId = e.callContactId;
    }
    final tmpl = Get.find<MessageTemplateController>().templates;
    if (_templateId == null && tmpl.isNotEmpty) _templateId = tmpl.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final panicCtrl   = Get.find<PanicButtonController>();
    final contactCtrl = Get.find<ContactController>();
    final tmplCtrl    = Get.find<MessageTemplateController>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Nuevo Botón' : 'Editar Botón')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // — Título
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 16),

              // — Color
              Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 12,
                children: [0xFF2196F3, 0xFFF44336, 0xFF4CAF50, 0xFFFFC107]
                    .map((hex) => GestureDetector(
                          onTap: () => setState(() => _color = hex),
                          child: CircleAvatar(
                            backgroundColor: Color(hex),
                            child: _color == hex ? Icon(Icons.check, color: Colors.white) : null,
                          ),
                        ))
                    .toList(),
              ),
              const Divider(height: 32),

              // — Método
              Text('Método', style: TextStyle(fontWeight: FontWeight.bold)),
              ...AlertMethod.values.map((m) {
                final labels = {
                  AlertMethod.sms: 'SMS',
                  AlertMethod.whatsapp: 'WhatsApp',
                  AlertMethod.call: 'Llamada',
                };
                return RadioListTile<AlertMethod>(
                  title: Text(labels[m]!),
                  value: m,
                  groupValue: _method,
                  onChanged: (v) => setState(() => _method = v!),
                );
              }).toList(),
              const Divider(height: 32),

              // — Opciones SMS / WhatsApp
              if (_method == AlertMethod.sms || _method == AlertMethod.whatsapp) ...[
                // Plantilla
                Text('Plantilla de mensaje', style: TextStyle(fontWeight: FontWeight.bold)),
                if (tmplCtrl.templates.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _templateId,
                    items: tmplCtrl.templates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                        .toList(),
                    onChanged: (v) => setState(() => _templateId = v),
                  )
                else
                  const Text('Crea plantillas en Ajustes', style: TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                // Contactos
                Text('Contactos', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ],

              // — Opciones Llamada
              if (_method == AlertMethod.call) ...[
                Text('Llamada a', style: TextStyle(fontWeight: FontWeight.bold)),
                ...CallTarget.values.map((ct) {
                  final labels = {
                    CallTarget.none: 'Ninguna',
                    CallTarget.police: 'Policía',
                    CallTarget.ambulance: 'Ambulancia',
                    CallTarget.contact: 'Un contacto',
                  };
                  return RadioListTile<CallTarget>(
                    title: Text(labels[ct]!),
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
                    decoration: const InputDecoration(labelText: 'Elegir contacto'),
                    value: _callContactId.isNotEmpty
                        ? _callContactId
                        : (_selectedContacts.isNotEmpty ? _selectedContacts.first : null),
                    items: _selectedContacts
                        .map((id) => contactCtrl.contacts.firstWhere((c) => c.id == id))
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _callContactId = v!),
                  ),
                const Divider(height: 32),
              ],

              // — Botón Guardar
              ElevatedButton(
                onPressed: () {
                  final model = PanicButtonModel(
                    id: widget.existing?.id ?? '',
                    title: _titleCtrl.text.trim(),
                    color: _color,
                    method: _method,
                    contactIds: _selectedContacts,
                    messageTemplateId: _templateId ?? '',
                    callTarget: _callTarget,
                    callContactId: _callContactId,
                    userId: widget.existing?.userId ?? '',
                  );
                  if (widget.existing == null) {
                    panicCtrl.addButton(model);
                  } else {
                    panicCtrl.updateButton(model);
                  }
                  Get.back();
                },
                child: Text(widget.existing == null ? 'Crear' : 'Guardar'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
