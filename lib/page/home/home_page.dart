import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:working_home/page/page_base_widget.dart';
import 'package:working_home/page/setting_holiday/holiday_setting_page.dart';
import 'package:working_home/page/setting_info/user_setting_page.dart';
import 'package:working_home/utils/conv_util.dart';

import '../../data/Repository.dart';
import '../calculate/calculate_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final format = DateFormat('yyyy년 MM월 dd일');

  @override
  Widget build(BuildContext context) {
    return PageBaseWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Specify the date',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48.r),
          body(context),
          SizedBox(height: 24.r),
          Text(
            '오늘 : ${format.format(DateTime.now())}',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return Container(
      width: 860.w,
      height: 1000.h,
      padding: EdgeInsets.all(60.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(80.r),
      ),
      child: ValueListenableBuilder(
          valueListenable: Repository().holidaysMapNoti,
          builder: (_, holidaysMap, __) {
            if (holidaysMap.isEmpty) {
              return Center(child: Text('저장된 공휴일 데이터가 없습니다.', style: TextStyle(fontSize: 28.sp)));
            }

            final initYear = holidaysMap.keys.contains(DateTime.now().year)
                ? DateTime.now().year
                : holidaysMap.keys.first;
            final selectedNoti = ValueNotifier(initYear);
            final years = holidaysMap.keys.toList();
            return ValueListenableBuilder(
                valueListenable: selectedNoti,
                builder: (_, year, __) {
                  final holidaysLen = (holidaysMap[year]!..removeWhere((a) => !a.isHoliday)).length;
                  int weekendDays = 0;
                  for (int month = 1; month <= 12; month++) {
                    for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
                      final date = DateTime(year, month, day);
                      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
                        weekendDays++;
                      }
                    }
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      selectYear(context, years, selectedNoti),
                      info(context, weekendDays, holidaysLen),
                      SizedBox(height: 30.r),
                      SizedBox(
                        height: 150.h,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: SizedBox(
                                width: 220.w,
                                height: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 60.r),
                                    elevation: 10.r,
                                  ),
                                  onPressed: () {
                                    if (holidaysMap[year]?.isNotEmpty == true) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CalculateWidget(year: year),
                                        ),
                                      );
                                    } else {
                                      ConvUtil.toast(
                                        context: context,
                                        message: '$year년에 저장된 공휴일 데이터가 없습니다.',
                                      );
                                    }
                                  },
                                  child: Text(
                                    'START',
                                    style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.listCheck),
                                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => const HolidaySettingPage()));
                                    },
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.users),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const UserSettingPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }

  Widget selectYear(BuildContext context, List<int> years, ValueNotifier selectedNoti) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: years
            .map((key) => Container(
                  margin: EdgeInsets.symmetric(vertical: 16.r, horizontal: 20.r),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedNoti.value == key
                          ? Theme.of(context).colorScheme.primaryFixedDim
                          : null,
                      elevation: 8.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 28.w),
                    ),
                    onPressed: () {
                      selectedNoti.value = key;
                    },
                    child: Text(
                      '$key',
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget info(BuildContext context, int weekendDays, int holidaysLen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(60.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('주말', style: Theme.of(context).textTheme.titleLarge),
            Text('$weekendDays 개', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        SizedBox(height: 40.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('공휴일', style: Theme.of(context).textTheme.titleLarge),
            Text('$holidaysLen 개', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        SizedBox(height: 40.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('분배 인원', style: Theme.of(context).textTheme.titleLarge),
            ValueListenableBuilder(
              valueListenable: Repository().userInfosNoti,
              builder: (_, userInfos, __) {
                return Text('${userInfos.length} 명', style: Theme.of(context).textTheme.titleLarge);
              }
            ),
          ],
        ),
      ]),
    );
  }
}
