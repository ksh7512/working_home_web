import 'package:flutter/material.dart';
import 'package:working_home/page/setting_info/widget/user_infos_item_widget.dart';

import '../../../data/Repository.dart';

class UsersWidget extends StatelessWidget {
  const UsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Repository().userInfosNoti,
      builder: (_, userInfos, __) {
        if (userInfos.isNotEmpty == true) {
          return SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: userInfos.entries
                    .map((info) => UserInfosItemWidget(name: info.key, email: info.value))
                    .toList(),
              ),
            ),
          );
        }

        return Center(child: Text('유저 데이터가 없습니다.', style: Theme.of(context).textTheme.titleLarge));
      },
    );
  }
}
