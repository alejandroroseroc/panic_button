import 'package:hive/hive.dart';

part 'message_template_model.g.dart';

@HiveType(typeId: 4)
class MessageTemplateModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  MessageTemplateModel({
    required this.id,
    required this.title,
    required this.content,
  });

  MessageTemplateModel copyWith({
    String? id,
    String? title,
    String? content,
  }) {
    return MessageTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  factory MessageTemplateModel.fromMap(Map<dynamic, dynamic> map) {
    return MessageTemplateModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
}