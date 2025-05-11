// lib/models/settings_model.dart

class SettingsModel {
  bool useButton;              // activar con tap
  bool useVoice;               // comando de voz
  bool useShake;               // agitar el teléfono
  String alertText;            // texto personalizado de alerta
  bool pushNotifications;      // activar notificaciones push

  SettingsModel({
    this.useButton = true,
    this.useVoice = false,
    this.useShake = false,
    this.alertText = '¡Auxilio!',
    this.pushNotifications = false,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> m) => SettingsModel(
        useButton: m['useButton'] as bool? ?? true,
        useVoice: m['useVoice'] as bool? ?? false,
        useShake: m['useShake'] as bool? ?? false,
        alertText: m['alertText'] as String? ?? '¡Auxilio!',
        pushNotifications: m['pushNotifications'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'useButton': useButton,
        'useVoice': useVoice,
        'useShake': useShake,
        'alertText': alertText,
        'pushNotifications': pushNotifications,
      };
}
