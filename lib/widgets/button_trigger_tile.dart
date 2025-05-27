import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/panic_button_model.dart';
import '../controllers/settings_controller.dart';

enum TriggerMethod { tap, voice, shake }

class ButtonTriggerTile extends StatelessWidget {
  final PanicButtonModel button;
  const ButtonTriggerTile({super.key, required this.button});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final triggers = settingsCtrl.getTriggers(button.id);
    Widget _checkbox(String label, TriggerMethod method) {
      final name = method.name;
      final selected = triggers.contains(name);
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(
          value: selected,
          onChanged: (v) => settingsCtrl.toggleTrigger(button.id, name),
        ),
        Text(label),
      ]);
    }

    return ListTile(
      title: Text(button.title),
      subtitle: Wrap(spacing: 12, children: [
        _checkbox('Tap', TriggerMethod.tap),
        _checkbox('Voz', TriggerMethod.voice),
        _checkbox('Shake', TriggerMethod.shake),
      ]),
    );
  }
}
