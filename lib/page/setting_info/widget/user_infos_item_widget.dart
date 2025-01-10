import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:working_home/utils/conv_util.dart';

import '../../../data/Repository.dart';

class UserInfosItemWidget extends StatelessWidget {
  const UserInfosItemWidget({super.key, required this.name, required this.email});

  final String name;
  final String email;

  static final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixedDim,
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              email,
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
                '[$name $email]을 제거하시겠습니까?',
                () async {
                  final result = await Repository().removeUserInfo(name);
                  if (!result) {
                    if (Repository().userInfosNoti.value.length <= 1) {
                      ConvUtil.toast(context: context, message: '최소 1명의 유저가 필요합니다.');
                    } else {
                      ConvUtil.toast(context: context, message: '유저정보 삭제가 실패하였습니다.');
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
