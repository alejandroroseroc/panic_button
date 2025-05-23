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
    );
  }

  @override
  void write(BinaryWriter writer, MessageTemplateModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content);
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
