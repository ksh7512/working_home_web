import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NameDayItemWidget extends StatelessWidget {
  const NameDayItemWidget({super.key, required this.date, required this.label});

  static final _format = DateFormat('yyyy년 MM월 dd일');

  final DateTime date;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l = label.isEmpty ? '' : ' : $label';
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Container(
        width: double.infinity,
        height: 140.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(36.r)),
          color: Theme.of(context).colorScheme.primaryFixedDim,
        ),
        alignment: Alignment.center,
        child: Text(_format.format(date) + l, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
