// lib/widgets/button_trigger_tile.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../models/panic_button_model.dart';

enum TriggerMethod { tap, voice, shake }

class ButtonTriggerTile extends StatelessWidget {
  final PanicButtonModel button;
  const ButtonTriggerTile({Key? key, required this.button}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final assigned = settingsCtrl.getTriggers(button.id);

    Widget buildChip(String label, String method, Color color) {
      final selected = assigned.contains(method);
      return FilterChip(
        label: Text(label),
        selected: selected,
        selectedColor: color.withOpacity(0.2),
        checkmarkColor: color,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(color: selected ? color : Colors.black),
        onSelected: (_) => settingsCtrl.toggleTrigger(button.id, method),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Color(button.color)),
        title: Text(button.title),
        subtitle: Wrap(
          spacing: 8,
          children: [
            buildChip('Tap', 'tap', Colors.blue),
            buildChip('Voice', 'voice', Colors.green),
            buildChip('Shake', 'shake', Colors.orange),
          ],
        ),
      ),
    );
  }
}
