import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_home/data/Repository.dart';
import 'package:working_home/page/home/home_page.dart';
import 'package:working_home/utils/custom_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Repository().initialize();
  runApp(
    ScreenUtilInit(
      designSize: const Size(1280, 1920),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          scrollBehavior: CustomScrollBehavior(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    ),
  );
}
