import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_home/data/Repository.dart';
import 'package:working_home/utils/conv_util.dart';

class UserAddWidget extends StatefulWidget {
  const UserAddWidget({super.key});

  @override
  State<UserAddWidget> createState() => _UserAddWidgetState();
}

class _UserAddWidgetState extends State<UserAddWidget> {
  final listNameFocusNode = FocusNode();
  final listEmailFocusNode = FocusNode();
  final listNameController = TextEditingController();
  final listEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listNameFocusNode.unfocus();
    listEmailFocusNode.unfocus();
  }

  @override
  void dispose() {
    super.dispose();
    listNameFocusNode.unfocus();
    listEmailFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('유저 정보 업데이트', style: Theme.of(context).textTheme.titleLarge),
          input(
            listNameController,
            listNameFocusNode,
            '이름',
          ),
          input(
            listEmailController,
            listEmailFocusNode,
            '이메일 (abc@uangel.com)',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(
            width: 600.r,
            height: 140.r,
            child: ElevatedButton(
              onPressed: () async {
                listNameFocusNode.unfocus();
                listEmailFocusNode.unfocus();
                if (listNameController.text.isEmpty || listEmailController.text.isEmpty) {
                  ConvUtil.toast(context: context, message: '이름과 이메일을 모두 입력해주세요.');
                  return;
                }
                final result = await Repository()
                    .addUserInfo(listNameController.text, listEmailController.text);

                if (result) {
                  listNameController.text = '';
                  listEmailController.text = '';
                } else {
                  ConvUtil.toast(context: context, message: '이미 존재하는 이름입니다.');
                }
              },
              child: Text('업데이트', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
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
            labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
            labelText: label,
          )),
    );
  }
}
