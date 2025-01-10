import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/model/option_date.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.selectedNameNoti,
    required this.nameMapDays,
    required this.calendarMonths,
  });

  final EventController controller;
  final DateTime start;
  final DateTime end;
  final ValueNotifier<String> selectedNameNoti;
  final Map<String, Map<DateTime, OptionDate>> nameMapDays;
  final Map<int, Map<DateTime, OptionDate>> calendarMonths;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedNameNoti,
        builder: (_, selName, __) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryFixedDim,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              final ratio = constraints.maxWidth / (constraints.maxHeight - 100.h);
              return MonthView(
                  controller: controller,
                  cellAspectRatio: ratio,
                  headerBuilder: (date) {
                    return SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.r),
                          child: Text(
                            '${date.month}월',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                          ),
                        ));
                  },
                  minMonth: start,
                  maxMonth: end,
                  initialMonth: start,
                  startDay: WeekDays.sunday,
                  weekDayBuilder: (d) {
                    String str = '';
                    switch (d) {
                      case 0:
                        str = '월';
                        break;
                      case 1:
                        str = '화';
                        break;
                      case 2:
                        str = '수';
                        break;
                      case 3:
                        str = '목';
                        break;
                      case 4:
                        str = '금';
                        break;
                      case 5:
                        str = '토';
                        break;
                      case 6:
                        str = '일';
                        break;
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.r),
                      child: Text(
                        str,
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  cellBuilder: (date, events, isToday, isInMonth, b) {
                    String str = '${date.day}';
                    TextStyle style = TextStyle(fontSize: 16.sp, color: Colors.black);
                    if (nameMapDays[selName]!.containsKey(date) &&
                        nameMapDays[selName]![date]!.option == Option.selected) {
                      style =
                          style.copyWith(color: Colors.green.shade900, fontWeight: FontWeight.w700);
                      str += '\n${nameMapDays[selName]![date]!.str}';
                    } else if (calendarMonths[date.month]!.containsKey(date) &&
                        (calendarMonths[date.month]![date]!.option == Option.weekend ||
                            calendarMonths[date.month]![date]!.option == Option.holiday)) {
                      style = style.copyWith(color: Colors.redAccent);
                      str += '\n${calendarMonths[date.month]![date]!.str}';
                    }

                    return Text(
                      str,
                      style: isInMonth ? style : style.copyWith(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  });
            }),
          );
        });
  }
}
