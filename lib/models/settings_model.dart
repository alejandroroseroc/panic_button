class SettingsModel {
  bool useButton;               // tap global
  bool useVoice;                // voz global
  bool useShake;                // shake global
  String alertText;             // texto de alerta por voz
  bool pushNotifications;       // push global

  /// Nuevo: mapa de buttonId -> lista de métodos ('tap','voice','shake')
  Map<String, List<String>> buttonTriggers;

  SettingsModel({
    this.useButton = true,
    this.useVoice = false,
    this.useShake = false,
    this.alertText = '¡Auxilio!',
    this.pushNotifications = false,
    Map<String, List<String>>? buttonTriggers,
  }) : buttonTriggers = buttonTriggers ?? {};

  factory SettingsModel.defaults() => SettingsModel();

  factory SettingsModel.fromMap(Map<String, dynamic> m) => SettingsModel(
        useButton: m['useButton'] as bool? ?? true,
        useVoice: m['useVoice'] as bool? ?? false,
        useShake: m['useShake'] as bool? ?? false,
        alertText: m['alertText'] as String? ?? '¡Auxilio!',
        pushNotifications: m['pushNotifications'] as bool? ?? false,
        buttonTriggers: (m['buttonTriggers'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, List<String>.from(v as List)))
            ?? {},
      );

  Map<String, dynamic> toMap() => {
        'useButton': useButton,
        'useVoice': useVoice,
        'useShake': useShake,
        'alertText': alertText,
        'pushNotifications': pushNotifications,
        'buttonTriggers': buttonTriggers,
      };
}
