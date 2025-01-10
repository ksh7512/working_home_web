import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:working_home/page/page_base_widget.dart';
import 'package:working_home/page/setting_info/widget/user_add_widget.dart';
import 'package:working_home/page/setting_info/widget/users_widget.dart';
import 'package:working_home/utils/conv_util.dart';

import '../../data/Repository.dart';

class UserSettingPage extends StatelessWidget {
  const UserSettingPage({super.key});

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
                  child: Text('유저 리스트 설정', style: Theme.of(context).textTheme.headlineMedium),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.arrowRotateRight, size: 80.r),
                    onPressed: () {
                      ConvUtil.showPlaneDialog(context, '알림', '유저 리스트를 초기화 하시겠습니까?', () {
                        Repository().resetUserInfo();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: contents(context)),
        ],
      ),
    );
  }

  Widget contents(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryFixed,
        borderRadius: BorderRadius.all(Radius.circular(50.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Expanded(child: UsersWidget()),
          Container(
            height: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            width: 6.r,
            color: Colors.grey.withOpacity(0.6),
          ),
          const Expanded(child: UserAddWidget()),
        ],
      ),
    );
  }
}
