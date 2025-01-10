import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_home/data/Repository.dart';
import 'package:working_home/data/model/holiday.dart';
import 'package:working_home/utils/conv_util.dart';

class HolidaysAddWidget extends StatefulWidget {
  const HolidaysAddWidget({super.key, required this.selectedNoti});

  final ValueNotifier<int> selectedNoti;

  @override
  State<HolidaysAddWidget> createState() => _HolidaysAddWidgetState();
}

class _HolidaysAddWidgetState extends State<HolidaysAddWidget> {
  final decodeFocusNode = FocusNode();
  final customMonthFocusNode = FocusNode();
  final customDayFocusNode = FocusNode();
  final customTitleFocusNode = FocusNode();

  final decodeKeyController = TextEditingController();
  final customMonthController = TextEditingController();
  final customDayController = TextEditingController();
  final customTitleController = TextEditingController();

  final repo = Repository();

  @override
  void initState() {
    super.initState();
    decodeFocusNode.unfocus();
    customMonthFocusNode.unfocus();
    customDayFocusNode.unfocus();
    customTitleFocusNode.unfocus();
  }

  @override
  void dispose() {
    decodeFocusNode.unfocus();
    customMonthFocusNode.unfocus();
    customDayFocusNode.unfocus();
    customTitleFocusNode.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            apiUpdateWidget(),
            customUpdateWidget(),
          ],
        ),
      ),
    );
  }

  Widget input(
    TextEditingController controller,
    FocusNode node,
    String label, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: TextField(
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        controller: controller,
        focusNode: node,
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(fontSize: 14.sp, color: Colors.black54),
          labelText: label,
        ),
      ),
    );
  }

  Widget apiUpdateWidget() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Column(
        children: [
          Text('API 데이터 업데이트 (공공데이터 포털 - 특일정보)', style: Theme.of(context).textTheme.titleMedium),
          input(decodeKeyController, decodeFocusNode, 'Decoding Key'),
          SizedBox(
            width: 200.w,
            height: 120.h,
            child: ValueListenableBuilder(
                valueListenable: repo.isRequesting,
                builder: (_, isReqing, __) {
                  if (isReqing) return const Center(child: CircularProgressIndicator());
                  return ElevatedButton(
                    onPressed: () async {
                      if (decodeKeyController.text.isEmpty) {
                        ConvUtil.toast(context: context, message: '디코딩 키를 입력해주세요.');
                        return;
                      }

                      decodeFocusNode.unfocus();
                      await repo.updateApiHolidays(
                        context: context,
                        decodeKey: decodeKeyController.text,
                        year: widget.selectedNoti.value,
                      );
                    },
                    child: Text('API 요청',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget customUpdateWidget() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('휴일 정보 커스텀 입력', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: input(
                    customMonthController,
                    customMonthFocusNode,
                    '월 (ex: 6)',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                ),
                Expanded(
                  child: input(
                    customDayController,
                    customDayFocusNode,
                    '일 (ex: 6)',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                ),
              ],
            ),
            input(customTitleController, customTitleFocusNode, '휴일 이름'),
            SizedBox(
              width: 200.w,
              height: 120.h,
              child: ElevatedButton(
                onPressed: () async {
                  customMonthFocusNode.unfocus();
                  customDayFocusNode.unfocus();
                  customTitleFocusNode.unfocus();

                  final month = int.parse(customMonthController.text);
                  final day = int.parse(customDayController.text);

                  if (month < 1 || month > 12 || day < 1) {
                    ConvUtil.toast(context: context, message: '입력할 수 없는 날짜 입니다.');
                  } else {
                    final maxDay = DateTime(month + 1, 1).subtract(const Duration(days: 1)).day;
                    if (day > maxDay) {
                      ConvUtil.toast(context: context, message: '입력할 수 없는 날짜 입니다.');
                    } else {
                      await Repository().addHoliday(
                        widget.selectedNoti.value,
                        Holiday(
                          dateName: customTitleController.text,
                          isHoliday: true,
                          locdate: DateTime(widget.selectedNoti.value, month, day),
                        ),
                      );
                      customMonthController.text = '';
                      customDayController.text = '';
                      customTitleController.text = '';
                    }
                  }
                },
                child: Text('입력', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
