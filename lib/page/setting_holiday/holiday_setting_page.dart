import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:working_home/page/page_base_widget.dart';
import 'package:working_home/utils/conv_util.dart';

import '../../../data/Repository.dart';
import 'widget/holidays_add_widget.dart';
import 'widget/holidays_widget.dart';

class HolidaySettingPage extends StatefulWidget {
  const HolidaySettingPage({super.key});

  @override
  State<HolidaySettingPage> createState() => _HolidaySettingPageState();
}

class _HolidaySettingPageState extends State<HolidaySettingPage> {
  final selectedNoti = ValueNotifier(DateTime.now().year);
  final yearFocusNode = FocusNode();
  final yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageBaseWidget(
      child: Column(
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
                  child: Text('공휴일 설정', style: Theme.of(context).textTheme.headlineMedium),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.arrowRotateRight, size: 80.r),
                    onPressed: () {
                      ConvUtil.showPlaneDialog(context, '알림', '공휴일 정보를 초기화 하시겠습니까?', () {
                        Repository().resetYearHoliday();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryFixed,
                borderRadius: BorderRadius.all(Radius.circular(50.r)),
              ),
              child: ValueListenableBuilder(
                  valueListenable: Repository().isInitializing,
                  builder: (context, isInitializing, __) {
                    if (isInitializing == true) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: [
                        years(),
                        SizedBox(height: 28.h),
                        Expanded(child: contents()),
                      ],
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget years() {
    return ValueListenableBuilder(
        valueListenable: Repository().holidaysMapNoti,
        builder: (_, holidaysMap, __) {
          return ValueListenableBuilder(
              valueListenable: selectedNoti,
              builder: (_, year, __) {
                return Row(
                  children: [
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.calendarPlus,
                        size: 80.r,
                        color: Colors.transparent,
                      ),
                      onPressed: null,
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: holidaysMap.keys
                                .map(
                                  (key) => Container(
                                    margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: year == key
                                            ? Theme.of(context).colorScheme.primaryFixedDim
                                            : null,
                                      ),
                                      onPressed: () {
                                        selectedNoti.value = key;
                                      },
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                        child: Text(
                                          '$key',
                                          style: TextStyle(
                                              fontSize: 20.sp, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.calendarPlus, size: 80.r),
                      onPressed: () async {
                        await calModifyDialog();
                      },
                    ),
                  ],
                );
              });
        });
  }

  Widget contents() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(flex: 2, child: HolidaysWidget(selectedNoti: selectedNoti)),
        Container(
          height: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          width: 6.r,
          color: Colors.grey.withOpacity(0.6),
        ),
        Expanded(flex: 3, child: HolidaysAddWidget(selectedNoti: selectedNoti)),
      ],
    );
  }

  Future calModifyDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext _) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.r)),
              child: Padding(
                padding: EdgeInsets.all(60.r),
                child: Material(
                  child: SizedBox(
                    height: 500.r,
                    width: 600.r,
                    child: Column(
                      children: [
                        Text(
                          '연도 추가 제거',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 40.r),
                        Expanded(
                          child: Center(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              controller: yearController,
                              focusNode: yearFocusNode,
                              style: TextStyle(fontSize: 16.sp, color: Colors.black),
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(fontSize: 14.sp, color: Colors.black54),
                                labelText: '연도',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.r),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  try {
                                    final year = int.parse(yearController.text);
                                    if (year < 2000 || year > 2100) {
                                      throw Exception();
                                    }
                                    final result = await Repository().addYear(year);
                                    if (result) {
                                      yearFocusNode.unfocus();
                                      yearController.text = '';
                                      ConvUtil.toast(context: context, message: '$year년이 추가되었습니다.');
                                    } else {
                                      ConvUtil.toast(context: context, message: '$year년이 이미 존재합니다.');
                                    }
                                  } catch (e) {
                                    ConvUtil.toast(
                                        context: context,
                                        message: '연도를 잘못 입력하셨습니다. 2000 ~ 2100 입력 가능');
                                  }
                                },
                                child: const Text(
                                  '추가',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20.r),
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  try {
                                    final year = int.parse(yearController.text);
                                    if(year == DateTime.now().year){
                                      ConvUtil.toast(context: context, message: '올해는 제거할 수 없습니다.');
                                      return;
                                    }

                                    final result = await Repository().removeYear(year);
                                    if (result) {
                                      yearFocusNode.unfocus();
                                      yearController.text = '';
                                      ConvUtil.toast(context: context, message: '$year년이 제거되었습니다.');
                                    } else {
                                      ConvUtil.toast(
                                          context: context, message: '$year년이 존재하지 않습니다.');
                                    }
                                  } catch (e) {
                                    ConvUtil.toast(
                                        context: context,
                                        message: '연도를 잘못 입력하셨습니다. 2000 ~ 2100 입력 가능');
                                  }
                                },
                                child: const Text(
                                  '제거',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
    yearFocusNode.unfocus();
    yearController.text = '';
  }
}
