import 'dart:math';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:working_home/page/calculate/widget/calendar_widget.dart';
import 'package:working_home/page/calculate/widget/name_days_widget.dart';
import 'package:working_home/page/page_base_widget.dart';
import 'package:working_home/utils/conv_util.dart';
import 'package:working_home/utils/date_time_extension.dart';

import '../../data/Repository.dart';
import '../../data/model/holiday.dart';
import '../../data/model/option_date.dart';

const _maxNumOfWeek = 2;
const allName = 'ALL';

class CalculateWidget extends StatefulWidget {
  const CalculateWidget({super.key, required this.year});

  final int year;

  @override
  State<CalculateWidget> createState() => _CalculateWidgetState();
}

class _CalculateWidgetState extends State<CalculateWidget> {
  Map<int, List<List<OptionDate>>> months = {};
  Map<String, List<OptionDate>> nameDays = {};
  Map<int, Map<DateTime, OptionDate>> calendarMonths = {};
  Map<String, Map<DateTime, OptionDate>> nameMapDays = {};
  final controller = EventController();
  final selectedNameNoti = ValueNotifier(allName);
  String errMsg = '';
  final listCalNoti = ValueNotifier<bool>(false);

  static final format = DateFormat('yyyy년 MM월 dd일');

  @override
  void initState() {
    super.initState();
    try {
      calculate(widget.year);
    } catch (e) {
      errMsg = '$e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBaseWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 160.h,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.arrowLeft, size: 80.r),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('${widget.year}년 계산 결과',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.envelopeOpenText, size: 80.r),
                    onPressed: () {
                      String body =
                          '[Automatically Created Data]\n\n <<<< ${widget.year} 년 날짜 자동 배정>>>>\n\n'
                          ' ** 규칙\n'
                          ' * 1. 월단위로 전 인원이 하루씩 할당\n'
                          ' * 2. 주말 및 공휴일은 제외\n'
                          ' * 3. 각 주마다 최대 2명으로 지정 (_maxNumOfWeek 값 수정 사용 가능)\n'
                          ' * 4. 공휴일(한 주 평일)도 배치된 인원으로 체크 (ex 공휴일이 1일 있으면 0~1명 배치)(_maxNumOfWeek값과 연관사용)\n'
                          ' * 5. 월이 바뀌더라도 최대 인원 제한 사항 유지\n'
                          ' * 6. 할당된 인원이 적은 주 우선 배정\n'
                          ' * 7. 배정 규칙을 초과하는 인원수의 경우 exception 발생\n'
                          ' * 8. 이전 연도 및 다음 연도는 고려하지 않음 (해당 연도 기준으로만 계산)\n'
                          ' * 9. 가정의날, 징검다리 미적용\n\n';

                      for (final nd in nameDays.entries) {
                        if (nd.key == allName) continue;

                        body += '\n';
                        body += '<${nd.key}>\n';
                        for (final d in nd.value) {
                          body += '${format.format(d.dateTime)}\n';
                        }
                      }

                      body += '\n[End]\n';
                      ConvUtil.sendEmail(
                          title: '${widget.year}년 자동 날짜 배정',
                          body: body,
                          recipientList: Repository().userInfosNoti.value.values.toList());
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: errMsg.isEmpty ? content() : error()),
        ],
      ),
    );
  }

  Widget content() {
    final selButtonBorder = Radius.circular(28.r);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(40.r),
      ),
      margin: EdgeInsets.only(top: 20.h, bottom: 60.h),
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
      child: ValueListenableBuilder(
          valueListenable: selectedNameNoti,
          builder: (_, selName, __) {
            return Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 120.w),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: nameDays.keys
                                .map((name) => Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10.r, vertical: 8.r),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: selName == name
                                                ? Theme.of(context).colorScheme.primaryContainer
                                                : null,
                                            elevation: 8.r,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30.w, vertical: 36.h)),
                                        onPressed: () {
                                          selectedNameNoti.value = name;
                                        },
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                              fontSize: 16.sp, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        listCalNoti.value = !listCalNoti.value;
                      },
                      child: SizedBox(
                        height: 100.h,
                        width: 120.w,
                        child: ValueListenableBuilder(
                            valueListenable: listCalNoti,
                            builder: (_, listCal, __) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: listCal
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.primaryFixedDim,
                                        borderRadius: BorderRadius.only(
                                            topLeft: selButtonBorder, bottomLeft: selButtonBorder),
                                      ),
                                      alignment: Alignment.center,
                                      child: FaIcon(FontAwesomeIcons.calendarDays, size: 24.w),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: listCal
                                            ? Theme.of(context).colorScheme.primaryFixedDim
                                            : Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topRight: selButtonBorder,
                                            bottomRight: selButtonBorder),
                                      ),
                                      alignment: Alignment.center,
                                      child: FaIcon(FontAwesomeIcons.list, size: 24.w),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: listCalNoti,
                      builder: (_, listCal, __) => listCal
                          ? NameDaysWidget(nameDays: nameDays, selectedNameNoti: selectedNameNoti)
                          : CalendarWidget(
                              controller: controller,
                              start: DateTime(widget.year, 1, 1),
                              end: DateTime(widget.year, 12, 31),
                              selectedNameNoti: selectedNameNoti,
                              nameMapDays: nameMapDays,
                              calendarMonths: calendarMonths,
                            )),
                ),
              ],
            );
          }),
    );
  }

  Widget error() {
    return Center(
      child: Text(
        errMsg,
        style: TextStyle(fontSize: 36.sp, color: Colors.redAccent),
        textAlign: TextAlign.center,
      ),
    );
  }

  /**
   * 규칙
   * 1. 월단위로 전 인원이 하루씩 할당
   * 2. 주말 및 공휴일은 제외
   * 3. 각 주마다 최대 2명으로 지정 (_maxNumOfWeek 값 수정 사용 가능)
   * 4. 공휴일(한 주 평일)도 배치된 인원으로 체크 (ex 공휴일이 1일 있으면 0~1명 배치)(_maxNumOfWeek값과 연관사용)
   * 5. 월이 바뀌더라도 최대 인원 제한 사항 유지
   * 6. 할당된 인원이 적은 주 우선 배정
   * 7. 배정 규칙을 초과하는 인원수의 경우 exception 발생
   * 8. 이전 연도 및 다음 연도는 고려하지 않음  (해당 연도 기준으로만 계산)
   * 9. 가정의날, 징검다리 미적용
   */
  calculate(int year) {
    // 휴일 기입된 월별 달력 생성 (주별 리스트)
    final Map<int, List<List<OptionDate>>> months = {};
    final Map<int, Map<DateTime, OptionDate>> calendarMonths = {};
    for (int i = 1; i <= 12; i++) {
      final yearHolidays = Repository().holidaysMapNoti.value[year]!;
      final monthHolidays = <Holiday>[];
      for (final yh in yearHolidays) {
        if (yh.isHoliday == true && yh.locdate.month == i) {
          monthHolidays.add(yh);
        }
      }
      final List<List<OptionDate>> weeks = makeWeeks(year, i, monthHolidays);
      months[i] = weeks;

      calendarMonths[i] = {};
      for (final w in weeks) {
        for (final d in w) {
          calendarMonths[i]![d.dateTime] = d;
        }
      }
    }
    this.calendarMonths = calendarMonths;

    // 각 월마다 랜덤 날짜 할당
    final Map<String, List<OptionDate>> nameDays = {};
    nameDays[allName] = [];
    for (final name in Repository().userInfosNoti.value.keys) {
      nameDays[name] = [];
    }
    for (int m = 1; m <= 12; m++) {
      final weeks = months[m];
      for (final name in Repository().userInfosNoti.value.keys) {
        List<OptionDate> lastLateMonthDays = [];
        List<OptionDate> nextFirstMonthDays = [];
        if (m != 1) {
          lastLateMonthDays = months[m - 1]!.last;
        }
        if (m != 12) {
          nextFirstMonthDays = months[m + 1]!.first;
        }
        final randDay = chooseRandomDay(name, m, weeks!, lastLateMonthDays, nextFirstMonthDays);
        randDay.option = Option.selected;
        randDay.str = name;
        nameDays[allName]!.add(randDay);
        nameDays[name]!.add(randDay);
      }
    }
    this.months = months;
    this.nameDays = nameDays;

    final Map<String, Map<DateTime, OptionDate>> nameMapDays = {};
    for (final nd in nameDays.entries) {
      nameMapDays[nd.key] = {};
      for (final d in nd.value) {
        if (nameMapDays[nd.key]!.containsKey(d.dateTime)) {
          nameMapDays[nd.key]![d.dateTime]!.str += '\n${d.str}';
        } else {
          nameMapDays[nd.key]![d.dateTime] = d;
        }
      }
    }
    this.nameMapDays = nameMapDays;

    nameDays[allName]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  OptionDate chooseRandomDay(
    String name,
    int month,
    List<List<OptionDate>> weeks,
    List<OptionDate> lastLateMonthDays,
    List<OptionDate> nextFirstMonthDays,
  ) {
    // 각 주별 지정된 사람 수 계산 (우선순위 판단)
    final Map<int, Set<int>> selNumWeeks = {};
    for (int i = 0; i < weeks.length; i++) {
      int selectedCnt = 0;
      if (i == 0 && weeks[0].length < 7) {
        for (final llmd in lastLateMonthDays) {
          if (llmd.option == Option.selected || llmd.option == Option.holiday) {
            selectedCnt++;
          }
        }
      } else if (i == weeks.length - 1 && weeks[weeks.length - 1].length < 7) {
        for (final llmd in nextFirstMonthDays) {
          if (llmd.option == Option.holiday) {
            selectedCnt++;
          }
        }
      }
      for (final d in weeks[i]) {
        if (d.option == Option.selected || d.option == Option.holiday) {
          selectedCnt++;
        }
      }
      if (selNumWeeks[selectedCnt] == null) {
        selNumWeeks[selectedCnt] = {};
      }
      selNumWeeks[selectedCnt]!.add(i);
    }
    final sortedKeys = selNumWeeks.keys.toList()..sort();
    final Map<int, Set<int>> sortedSelNumWeeks = {};
    for (final key in sortedKeys) {
      sortedSelNumWeeks[key] = selNumWeeks[key]!.toSet();
    }

    final rand = Random();
    while (true) {
      // 지정된 갯수 적은 순으로 랜덤 주차 가져오기
      int randWeek = -1;
      int key = -1;
      for (final ssnw in sortedSelNumWeeks.entries) {
        // 값이 없으면 continue
        if (ssnw.value.isEmpty) continue;
        // 지정된 최대 할당 인원 이상이면 브레이크
        if (ssnw.key >= _maxNumOfWeek) break;
        // 랜덤 주차 가져오기
        key = ssnw.key;
        randWeek = ssnw.value.elementAt(rand.nextInt(ssnw.value.length));
        break;
      }
      // 사용할 수 있는 주가 없을시 에러
      if (randWeek == -1 || key == -1) {
        throw Exception('${widget.year}년 $month월에 모든 인원을 분배할 수 없습니다.\n'
            '규칙, 분배할 인원 수, 주 할당 최대 인원 수, 휴일 등을 확인해주세요.\n'
            '참고. 이전 달 마지막 주 배치된 인원 수에 따라 생성 가능하거나 불가할 수 있음');
      }
      final days = weeks[randWeek];
      int selectedCnt = 0;
      bool existName = false;

      // 현재 사용 가능 일자 추출
      final usableDays = <OptionDate>[];
      for (final d in days) {
        if (d.option == Option.usable) {
          usableDays.add(d);
        }
      }

      // 재 계산 or 반환 판단
      if (selectedCnt >= _maxNumOfWeek || usableDays.isEmpty || existName) {
        // 사용 불가 날짜 그룹 이동 (최대 주 할당 인원 수 그룹으로)
        sortedSelNumWeeks[key]!.remove(randWeek);
        if (sortedSelNumWeeks[_maxNumOfWeek] == null) {
          sortedSelNumWeeks[_maxNumOfWeek] = {};
        }
        sortedSelNumWeeks[_maxNumOfWeek]!.add(randWeek);
        continue;
      } else {
        return usableDays[rand.nextInt(usableDays.length)];
      }
    }
  }

  List<List<OptionDate>> makeWeeks(int year, int month, List<Holiday> monthHolidays) {
    DateTime standard = DateTime(year, month, 1).sundayOfWeek;
    final List<List<OptionDate>> weeks = [];
    // 주별로 나눠서 날짜 리스트 삽입
    while (true) {
      if (month == 1) {
        if (!(standard.month == 12 || standard.month == 1)) {
          break;
        }
      } else {
        if (!(standard.month == month - 1 || standard.month == month)) {
          break;
        }
      }
      final List<OptionDate> days = [];
      for (int i = 0; i < 7; i++) {
        days.add(OptionDate(standard.add(Duration(days: i))));
      }

      // 다른 월 제거
      days.removeWhere((d) => d.dateTime.month != month);

      // 공휴일, 주말 처리
      for (final d in days) {
        if (d.dateTime.isWeekend) {
          d.option = Option.weekend;
          d.str += '주말 ';
        }
        for (final mh in monthHolidays) {
          if (d.dateTime.isSameCalendar(mh.locdate)) {
            if (mh.isHoliday) {
              if (d.option != Option.weekend) {
                d.option = Option.holiday;
              }
              d.str += '${mh.dateName} ';
            }
          }
        }
      }

      weeks.add(days);
      standard = standard.add(const Duration(days: 7));
    }

    return weeks;
  }
}
