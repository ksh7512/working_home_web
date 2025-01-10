import 'package:intl/intl.dart';

class Holiday {
  // final int dateKind;
  final String dateName;
  final bool isHoliday;
  final DateTime locdate;
  // final String seq;

  Holiday({
    // required this.dateKind,
    required this.dateName,
    required this.isHoliday,
    required this.locdate,
    // required this.seq,
  });

  // json 형태에서부터 데이터를 받아온다.
  Holiday.fromJson({required Map<String, dynamic> json})
      :
        // dateKind = int.parse(json['dateKind'] ?? '-1'),
        dateName = json['dateName'] ?? 'error',
        isHoliday = (json['isHoliday'] ?? 'N') == 'Y' ? true : false,
        // locdate = '${json['locdate'] ?? '-1'}',
        locdate = parseLocDate('${json['locdate'] ?? '-1'}')
        // seq = '${json['seq'] ?? '-1'}'
  ;
  // json 형태로 반환
  @override
  String toString() {
    return '{'
        // '"dateKind": "$dateKind",'
        '"dateName": "$dateName",'
        '"isHoliday": "${isHoliday ? 'Y' : 'N'}",'
        '"locdate": ${format.format(locdate)}'
        // '"seq": $seq'
        '}';
  }

  static final format = DateFormat('yyyyMMdd');
  static DateTime parseLocDate(String strDate){
    final date = DateTime.parse('${strDate.substring(0, 4)}-${strDate.substring(4, 6)}-${strDate.substring(6, 8)}');
    return date;
  }
}
