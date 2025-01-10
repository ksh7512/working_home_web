import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:working_home/data/model/holiday.dart';

part 'year_holiday.g.dart';

@HiveType(typeId : 0)
class YearHoliday {
  @HiveField(0)
  final int year;
  @HiveField(1)
  final List<Holiday> holidays;

  YearHoliday({
    required this.year,
    required this.holidays,
  });
}