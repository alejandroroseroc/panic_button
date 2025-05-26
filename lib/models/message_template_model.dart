// lib/models/message_template_model.dart

import 'package:hive/hive.dart';

part 'message_template_model.g.dart';

@HiveType(typeId: 4)
class MessageTemplateModel extends HiveObject {
  @HiveField(0)
  final String id;             // Appwrite ID ($id)

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String userId;         // $createdBy o campo userId

  @HiveField(4)
  final bool usedForPolice;

  @HiveField(5)
  final bool usedForAmbulance;

  @HiveField(6)
  final bool usedForContacts;

  @HiveField(7)
  final DateTime createdAt;

  MessageTemplateModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.usedForPolice,
    required this.usedForAmbulance,
    required this.usedForContacts,
    required this.createdAt,
  });

  MessageTemplateModel copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    bool? usedForPolice,
    bool? usedForAmbulance,
    bool? usedForContacts,
    DateTime? createdAt,
  }) {
    return MessageTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      usedForPolice: usedForPolice ?? this.usedForPolice,
      usedForAmbulance: usedForAmbulance ?? this.usedForAmbulance,
      usedForContacts: usedForContacts ?? this.usedForContacts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MessageTemplateModel.fromMap(Map<String, dynamic> json) {
    return MessageTemplateModel(
      id: json['\$id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      userId: json['userId'] as String,
      usedForPolice: json['usedForPolice'] as bool? ?? false,
      usedForAmbulance: json['usedForAmbulance'] as bool? ?? false,
      usedForContacts: json['usedForContacts'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'userId': userId,
        'usedForPolice': usedForPolice,
        'usedForAmbulance': usedForAmbulance,
        'usedForContacts': usedForContacts,
        'createdAt': createdAt.toIso8601String(),
      };
}
