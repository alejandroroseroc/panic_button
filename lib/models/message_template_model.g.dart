// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTemplateModelAdapter extends TypeAdapter<MessageTemplateModel> {
  @override
  final int typeId = 4;

  @override
  MessageTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageTemplateModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      userId: fields[3] as String,
      usedForPolice: fields[4] as bool,
      usedForAmbulance: fields[5] as bool,
      usedForContacts: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageTemplateModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.usedForPolice)
      ..writeByte(5)
      ..write(obj.usedForAmbulance)
      ..writeByte(6)
      ..write(obj.usedForContacts)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
