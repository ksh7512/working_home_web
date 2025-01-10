import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_home/page/calculate/calculate_page.dart';

import '../../../data/model/option_date.dart';
import 'name_day_item_widget.dart';

class NameDaysWidget extends StatelessWidget {
  const NameDaysWidget({super.key, required this.nameDays, required this.selectedNameNoti});

  final Map<String, List<OptionDate>> nameDays;
  final ValueNotifier<String> selectedNameNoti;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ValueListenableBuilder(
          valueListenable: selectedNameNoti,
          builder: (_, selName, __) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.r),
              child: SingleChildScrollView(
                child: Column(
                  children: nameDays[selName]!
                      .map((optionDate) => NameDayItemWidget(
                          date: optionDate.dateTime,
                          label: selName == allName ? optionDate.str : ''))
                      .toList(),
                ),
              ),
            );
          }),
    );
  }
}
