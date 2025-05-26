enum CallTarget { none, police, ambulance, contact }

class PanicButtonModel {
  final String id;
  final String title;
  final int color;                // ARGB completo
  final List<String> contactIds;  // para SMS
  final String messageTemplateId; // cuerpo del SMS
  final String callContactId;     // si CallTarget.contact
  final CallTarget callTarget;
  final String userId;

  PanicButtonModel({
    required this.id,
    required this.title,
    required this.color,
    required this.contactIds,
    this.messageTemplateId = '',
    this.callContactId = '',
    this.callTarget = CallTarget.none,
    required this.userId,
  });

  PanicButtonModel copyWith({
    String? id,
    String? title,
    int? color,
    List<String>? contactIds,
    String? messageTemplateId,
    String? callContactId,
    CallTarget? callTarget,
    String? userId,
  }) {
    return PanicButtonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      contactIds: contactIds ?? this.contactIds,
      messageTemplateId: messageTemplateId ?? this.messageTemplateId,
      callContactId: callContactId ?? this.callContactId,
      callTarget: callTarget ?? this.callTarget,
      userId: userId ?? this.userId,
    );
  }

  factory PanicButtonModel.fromJson(Map<String, dynamic> json) {
    final rgb = json['color'] as int;
    final argb = 0xFF000000 | (rgb & 0x00FFFFFF);
    final ct = CallTarget.values.firstWhere(
      (e) => e.toString() == 'CallTarget.${json['callTarget']}',
      orElse: () => CallTarget.none,
    );
    return PanicButtonModel(
      id: json['\$id'] as String,
      title: json['title'] as String,
      color: argb,
      contactIds: List<String>.from(json['contactIds'] ?? <String>[]),
      messageTemplateId: json['messageTemplateId'] as String? ?? '',
      callContactId: json['callContactId'] as String? ?? '',
      callTarget: ct,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'color': color & 0x00FFFFFF,
        'contactIds': contactIds,
        'messageTemplateId': messageTemplateId,
        'callContactId': callContactId,
        'callTarget': callTarget.toString().split('.').last,
        'userId': userId,
      };
}
