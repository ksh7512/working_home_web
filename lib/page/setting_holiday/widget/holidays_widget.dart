import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_home/data/Repository.dart';

import 'holiday_item_widget.dart';

class HolidaysWidget extends StatelessWidget {
  const HolidaysWidget({super.key, required this.selectedNoti});

  final ValueNotifier<int> selectedNoti;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Repository().holidaysMapNoti,
        builder: (_, holidaysMap, __) {
          if (holidaysMap.isEmpty) {
            return Center(child: Text('저장된 공휴일 데이터가 없습니다.', style: TextStyle(fontSize: 30.sp)));
          }

          return ValueListenableBuilder(
            valueListenable: selectedNoti,
            builder: (_, year, __) {
              if (holidaysMap[year]?.isNotEmpty == true) {
                return SizedBox(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children: holidaysMap[year]!
                          .map((holiday) => HolidayItemWidget(year: year, holiday: holiday))
                          .toList(),
                    ),
                  ),
                );
              }

              return Center(
                  child: Text('공휴일 데이터가 없습니다.', style: Theme.of(context).textTheme.titleLarge));
            },
          );
        });
  }
}
