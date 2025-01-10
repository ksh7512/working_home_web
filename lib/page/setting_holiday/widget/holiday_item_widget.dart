import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:working_home/utils/conv_util.dart';

import '../../../data/Repository.dart';
import '../../../data/model/holiday.dart';

class HolidayItemWidget extends StatelessWidget {
  const HolidayItemWidget({super.key, required this.year, required this.holiday});

  final int year;
  final Holiday holiday;

  static final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dateFormat.format(holiday.locdate), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              holiday.dateName,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 12.w),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleXmark),
            onPressed: () {
              ConvUtil.showPlaneDialog(
                context,
                '알림',
                '[${dateFormat.format(holiday.locdate)} ${holiday.dateName}]을 제거하시겠습니까?',
                () async {
                  await Repository().deleteHoliday(year, holiday);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
