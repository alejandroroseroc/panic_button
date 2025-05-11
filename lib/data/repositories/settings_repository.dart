// lib/data/repositories/settings_repository.dart

import 'package:hive_flutter/hive_flutter.dart';

class SettingsModel {
  bool useButton;
  bool useVoice;
  bool useShake;
  String customText;
  bool pushNotifications;

  SettingsModel({
    required this.useButton,
    required this.useVoice,
    required this.useShake,
    required this.customText,
    required this.pushNotifications,
  });

  factory SettingsModel.defaults() => SettingsModel(
        useButton: true,
        useVoice: false,
        useShake: false,
        customText: '¡Auxilio!',
        pushNotifications: false,
      );

  factory SettingsModel.fromMap(Map data) => SettingsModel(
        useButton: data['useButton'] as bool,
        useVoice: data['useVoice'] as bool,
        useShake: data['useShake'] as bool,
        customText: data['customText'] as String,
        pushNotifications: data['pushNotifications'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'useButton': useButton,
        'useVoice': useVoice,
        'useShake': useShake,
        'customText': customText,
        'pushNotifications': pushNotifications,
      };
}

class SettingsRepository {
  static const _boxName = 'settingsBox';
  static const _key = 'prefs';

  Future<SettingsModel> load() async {
    final box = Hive.box(_boxName);
    final data = box.get(_key);
    if (data == null) {
      final def = SettingsModel.defaults();
      await box.put(_key, def.toMap());
      return def;
    }
    return SettingsModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> save(SettingsModel s) async {
    final box = Hive.box(_boxName);
    await box.put(_key, s.toMap());
  }
}
