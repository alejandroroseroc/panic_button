enum AlertMethod { sms, whatsapp, call }

enum CallTarget { none, police, ambulance, contact }

class PanicButtonModel {
  final String id;
  final String title;
  final int color;                // ARGB completo
  final AlertMethod method;       // Nuevo campo
  final List<String> contactIds;  // para SMS o WhatsApp
  final String messageTemplateId; // para SMS/WhatsApp
  final CallTarget callTarget;    // para llamadas
  final String callContactId;     // si CallTarget.contact
  final String userId;

  PanicButtonModel({
    required this.id,
    required this.title,
    required this.color,
    required this.method,
    this.contactIds = const [],
    this.messageTemplateId = '',
    this.callTarget = CallTarget.none,
    this.callContactId = '',
    required this.userId,
  });

  PanicButtonModel copyWith({
    String? id,
    String? title,
    int? color,
    AlertMethod? method,
    List<String>? contactIds,
    String? messageTemplateId,
    CallTarget? callTarget,
    String? callContactId,
    String? userId,
  }) {
    return PanicButtonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      method: method ?? this.method,
      contactIds: contactIds ?? this.contactIds,
      messageTemplateId: messageTemplateId ?? this.messageTemplateId,
      callTarget: callTarget ?? this.callTarget,
      callContactId: callContactId ?? this.callContactId,
      userId: userId ?? this.userId,
    );
  }

  factory PanicButtonModel.fromJson(Map<String, dynamic> json) {
    final rgb = json['color'] as int;
    final argb = 0xFF000000 | (rgb & 0x00FFFFFF);
    final method = AlertMethod.values.firstWhere(
      (m) => m.toString() == 'AlertMethod.${json['method']}',
      orElse: () => AlertMethod.sms,
    );
    final ct = CallTarget.values.firstWhere(
      (e) => e.toString() == 'CallTarget.${json['callTarget']}',
      orElse: () => CallTarget.none,
    );
    return PanicButtonModel(
      id: json['\$id'] as String,
      title: json['title'] as String,
      color: argb,
      method: method,
      contactIds: List<String>.from(json['contactIds'] ?? <String>[]),
      messageTemplateId: json['messageTemplateId'] as String? ?? '',
      callTarget: ct,
      callContactId: json['callContactId'] as String? ?? '',
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'color': color & 0x00FFFFFF,
        'method': method.toString().split('.').last,
        'contactIds': contactIds,
        'messageTemplateId': messageTemplateId,
        'callTarget': callTarget.toString().split('.').last,
        'callContactId': callContactId,
        'userId': userId,
      };
}
