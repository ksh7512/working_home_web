// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_holiday.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YearHolidayAdapter extends TypeAdapter<YearHoliday> {
  @override
  final int typeId = 1;

  @override
  YearHoliday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final holidays = <Holiday>[];
    String str = fields[1].toString();
    while (str.contains('%')) {
      final idx = str.indexOf('%');
      holidays.add(Holiday.fromJson(json: jsonDecode(str.substring(0, idx))));
      str = str.substring(idx + 1, str.length);
    }
    return YearHoliday(
      year: fields[0] as int,
      holidays: holidays,
    );
  }

  @override
  void write(BinaryWriter writer, YearHoliday obj) {
    String str = '';
    for (final h in obj.holidays) {
      str += '$h%';
    }
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(str);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearHolidayAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
