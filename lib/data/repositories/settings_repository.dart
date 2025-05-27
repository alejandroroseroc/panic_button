// lib/data/repositories/settings_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../models/settings_model.dart';

class SettingsRepository {
  static const _boxName = 'settingsBox';
  static const _key     = 'prefs';

  Future<SettingsModel> load() async {
    final box = Hive.box(_boxName);
    final data = box.get(_key);
    if (data == null) {
      final def = SettingsModel.defaults();
      await box.put(_key, def.toMap());
      return def;
    }
    // data es Map<dynamic,dynamic>, convertimos a Map<String,dynamic>
    final raw = data as Map;
    final Map<String, dynamic> map = {};
    raw.forEach((k, v) {
      map[k.toString()] = v;
    });
    return SettingsModel.fromMap(map);
  }

  Future<void> save(SettingsModel s) async {
    final box = Hive.box(_boxName);
    await box.put(_key, s.toMap());
  }
}
