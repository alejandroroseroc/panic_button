// lib/models/panic_button_model.dart

class PanicButtonModel {
  final String id;
  final String title;
  final int color; // ARGB completo
  final List<String> contactIds;
  final bool alertToPolice;
  final bool alertToAmbulance;
  final bool useButton;
  final bool useVoice;
  final bool useShake;
  final bool usePush;
  final String messageTemplateId;
  final String userId;

  PanicButtonModel({
    required this.id,
    required this.title,
    required this.color,
    required this.contactIds,
    required this.alertToPolice,
    required this.alertToAmbulance,
    required this.useButton,
    required this.useVoice,
    required this.useShake,
    required this.usePush,
    required this.messageTemplateId,
    required this.userId,
  });

  PanicButtonModel copyWith({
    String? id,
    String? title,
    int? color,
    List<String>? contactIds,
    bool? alertToPolice,
    bool? alertToAmbulance,
    bool? useButton,
    bool? useVoice,
    bool? useShake,
    bool? usePush,
    String? messageTemplateId,
    String? userId,
  }) {
    return PanicButtonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      contactIds: contactIds ?? this.contactIds,
      alertToPolice: alertToPolice ?? this.alertToPolice,
      alertToAmbulance: alertToAmbulance ?? this.alertToAmbulance,
      useButton: useButton ?? this.useButton,
      useVoice: useVoice ?? this.useVoice,
      useShake: useShake ?? this.useShake,
      usePush: usePush ?? this.usePush,
      messageTemplateId: messageTemplateId ?? this.messageTemplateId,
      userId: userId ?? this.userId,
    );
  }

  factory PanicButtonModel.fromJson(Map<String, dynamic> json) {
    final rgb = json['color'] as int;
    final argb = 0xFF000000 | (rgb & 0x00FFFFFF);
    return PanicButtonModel(
      id: json['\$id'] as String,
      title: json['title'] as String,
      color: argb,
      contactIds: List<String>.from(json['contactIds'] ?? <String>[]),
      alertToPolice: json['alertToPolice'] as bool? ?? false,
      alertToAmbulance: json['alertToAmbulance'] as bool? ?? false,
      useButton: json['useButton'] as bool? ?? true,
      useVoice: json['useVoice'] as bool? ?? false,
      useShake: json['useShake'] as bool? ?? false,
      usePush: json['usePush'] as bool? ?? false,
      messageTemplateId: json['messageTemplateId'] as String? ?? '',
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'color': color & 0x00FFFFFF,
        'contactIds': contactIds,
        'alertToPolice': alertToPolice,
        'alertToAmbulance': alertToAmbulance,
        'useButton': useButton,
        'useVoice': useVoice,
        'useShake': useShake,
        'usePush': usePush,
        'messageTemplateId': messageTemplateId,
        'userId': userId,
      };
}
