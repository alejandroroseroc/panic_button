// lib/presentation/pages/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/contact_controller.dart';
import '../../models/contact_model.dart';
import '../../widgets/contact_tile.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    final ctrl = Get.find<ContactController>();

    return Scaffold(
      appBar: AppBar(title: Text('Mis Contactos')),
      body: Obx(() {
        if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator());
        if (ctrl.error.value.isNotEmpty) return Center(child: Text('Error: ${ctrl.error.value}'));
        if (ctrl.contacts.isEmpty) return Center(child: Text('Aún no tienes contactos'));

        return ListView(
          children: ctrl.contacts.map((c) => ContactTile(
            contact: c,
            onEdit: () => _showEditDialog(ctx, ctrl, existing: c),
            onDelete: () => ctrl.deleteContact(c.id),
          )).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showEditDialog(ctx, ctrl),
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, ContactController ctrl, {ContactModel? existing}) {
    final nameCtrl  = TextEditingController(text: existing?.name);
    final phoneCtrl = TextEditingController(text: existing?.phone);
    bool whatsapp   = existing?.whatsapp ?? false;

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (c, setState) {
          return AlertDialog(
            title: Text(existing==null?'Nuevo Contacto':'Editar Contacto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl,  decoration: InputDecoration(labelText:'Nombre')),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText:'Teléfono')),
                CheckboxListTile(
                  value: whatsapp,
                  onChanged: (v)=>setState(()=>whatsapp=v!),
                  title: Text('WhatsApp'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(c), child:Text('Cancelar')),
              ElevatedButton(
                onPressed: (){
                  final model = ContactModel(
                    id: existing?.id ?? '',
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    whatsapp: whatsapp,
                    userId: '', //controller lo rellena
                  );
                  if(existing==null) {
                    ctrl.addContact(model);
                  } else {
                    ctrl.updateContact(model);
                  }
                  Navigator.pop(c);
                },
                child: Text(existing==null?'Crear':'Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
