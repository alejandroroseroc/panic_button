// lib/data/repositories/message_template_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../models/message_template_model.dart';

class MessageTemplateRepository {
  static const _box = 'messageTemplatesBox';

  Future<List<MessageTemplateModel>> loadAll() async {
    final bx = Hive.box<MessageTemplateModel>(_box);
    return bx.values.toList();
  }

  Future<MessageTemplateModel> create(MessageTemplateModel t) async {
    final bx = Hive.box<MessageTemplateModel>(_box);
    final id = await bx.add(t);
    final saved = t.copyWith(id: id.toString());
    await bx.put(saved.id, saved);
    return saved;
  }

  Future<MessageTemplateModel> update(MessageTemplateModel t) async {
    final bx = Hive.box<MessageTemplateModel>(_box);
    await bx.put(t.id, t);
    return t;
  }

  Future<void> delete(String id) async {
    final bx = Hive.box<MessageTemplateModel>(_box);
    await bx.delete(id);
  }
}
