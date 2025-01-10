import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:working_home/data/model/year_holiday.dart';
import 'package:working_home/utils/conv_util.dart';

import 'model/holiday.dart';

const _yearHolidaysBoxName = 'YearHolidaysBox';
const _userInfoBoxName = 'UserInfoBox';
const _baseUserInfos = {
  '이영찬': 'yclee@uangel.com',
  '이재송': 'playbit@uangel.com',
  '최필균': 'pk.choi24@uangel.com',
  '오아람': 'oaram2@uangel.com',
  '권순홍': 'ksh7512@uangel.com',
  '김민성': 'minsungk@uangel.com',
};

class Repository {
  static final Repository _instance = Repository._internal();

  factory Repository() => _instance;

  Repository._internal();

  Box<YearHoliday>? _yearHolidayBox;
  Box<String>? _userInfoBox;

  final userInfosNoti = ValueNotifier<Map<String, String>>({});
  final holidaysMapNoti = ValueNotifier<Map<int, List<Holiday>>>({});
  final isInitializing = ValueNotifier(false);
  final isRequesting = ValueNotifier(false);

  // 각각 데이터가 하이브에 저장된게 없을 경우에만 year폴더의 데이터 가져와줌
  Future initialize() async {
    if (isInitializing.value) return;
    isInitializing.value = true;

    try {
      await Hive.initFlutter();
      Hive.registerAdapter<YearHoliday>(YearHolidayAdapter());
    } catch (e) {}

    List<YearHoliday> bufYH = await _getHolidayData();
    if (bufYH.isEmpty) {
      bufYH = await _readYearsFolder();
      for (final yh in bufYH) {
        await _yearHolidayBox?.put(yh.year, yh);
      }
    }
    final nowYear = DateTime.now().year;
    bool contain = false;
    for (final byh in bufYH) {
      if (byh.year == nowYear) {
        contain = true;
        break;
      }
    }
    if (!contain) {
      final yh = YearHoliday(year: nowYear, holidays: []);
      await _yearHolidayBox?.put(nowYear, yh);
      bufYH.add(yh);
    }

    bufYH.sort((a, b) => a.year.compareTo(b.year));
    holidaysMapNoti.value.clear();
    for (final yh in bufYH) {
      holidaysMapNoti.value[yh.year] = yh.holidays;
    }
    holidaysMapNoti.notifyListeners();

    Map<String, String> userInfoMap = await _getUserInfoData();
    if (userInfoMap.isEmpty) {
      userInfoMap = _sortStringStringMap(Map<String, String>.from(_baseUserInfos));
      for (final info in userInfoMap.entries) {
        await _userInfoBox?.put(info.key, info.value);
      }
    }
    userInfosNoti.value = userInfoMap;

    isInitializing.value = false;
  }

  Future<List<YearHoliday>> _getHolidayData() async {
    _yearHolidayBox = await Hive.openBox<YearHoliday>(_yearHolidaysBoxName);
    if (_yearHolidayBox?.values.isNotEmpty == true) {
      return _yearHolidayBox?.values.toList() ?? [];
    }
    return [];
  }

  Future<Map<String, String>> _getUserInfoData() async {
    _userInfoBox = await Hive.openBox<String>(_userInfoBoxName);
    final buf = <String, String>{};
    if (_userInfoBox?.values.isNotEmpty == true) {
      for (final key in _userInfoBox!.keys) {
        buf[key] = _userInfoBox!.get(key)!;
      }
    }
    return buf;
  }

  Future<List<YearHoliday>> _readYearsFolder() async {
    final yearHolidays = <YearHoliday>[];
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final Map<int, String> yearPath = {};
    for (final key in manifestMap.keys) {
      if (key.contains('DS_Store')) continue;
      if (key.startsWith('years/')) {
        final year = int.parse(key.replaceAll('years/', '').replaceAll('.json', ''));
        yearPath[year] = key;
      }
    }

    for (final yp in yearPath.entries) {
      final data = await rootBundle.load(yp.value);
      final jsonStr = utf8.decode(data.buffer.asUint8List());
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      yearHolidays.add(YearHoliday(
        year: yp.key,
        holidays: json['response']['body']['items']['item']
            .map<Holiday>((item) => Holiday.fromJson(json: item))
            .toList(),
      ));
    }

    return yearHolidays;
  }

  Future updateApiHolidays({
    required BuildContext context,
    required String decodeKey,
    required int year,
  }) async {
    if (isRequesting.value) return;
    isRequesting.value = true;
    try {
      final response = await Dio().get(
        'http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo',
        queryParameters: {
          'serviceKey': decodeKey,
          'solYear': year,
          '_type': 'json',
          'numOfRows': 1000,
        },
      );

      final items = response.data['response']['body']['items'];
      if (items.toString().isEmpty) {
        ConvUtil.toast(context: context, message: '$year년 데이터가 존재하지 않습니다.');
        return;
      } else {
        final holidays = response.data['response']['body']['items']['item']
            .map<Holiday>((item) => Holiday.fromJson(json: item))
            .toList();
        await _yearHolidayBox?.put(year, YearHoliday(year: year, holidays: holidays));
        holidaysMapNoti.value[year] = holidays;
        holidaysMapNoti.notifyListeners();
      }
    } catch (e) {
      ConvUtil.toast(context: context, message: '데이터 로딩에 실패하였습니다.');
      print('$e');
    }
    isRequesting.value = false;
  }

  Future<bool> deleteHoliday(int year, Holiday holiday) async {
    if (!holidaysMapNoti.value.containsKey(year)) return true;

    holidaysMapNoti.value[year]!.remove(holiday);
    await _yearHolidayBox?.put(
        year, YearHoliday(year: year, holidays: holidaysMapNoti.value[year]!));
    holidaysMapNoti.notifyListeners();
    return true;
  }

  Future<bool> addHoliday(int year, Holiday holiday) async {
    await addYear(year);
    holidaysMapNoti.value[year]!.add(holiday);
    holidaysMapNoti.value[year]!.sort((a, b) => a.locdate.compareTo(b.locdate));
    await _yearHolidayBox?.put(
        year, YearHoliday(year: year, holidays: holidaysMapNoti.value[year]!));
    holidaysMapNoti.notifyListeners();
    return true;
  }

  Future<bool> addYear(int year) async {
    if (!holidaysMapNoti.value.containsKey(year)) {
      holidaysMapNoti.value[year] = [];

      final Map<int, List<Holiday>> sortedMap = {};
      final sorted = holidaysMapNoti.value.keys.toList()..sort();
      for (final key in sorted) {
        sortedMap[key] = holidaysMapNoti.value[key]!;
      }
      holidaysMapNoti.value = sortedMap;
      await _yearHolidayBox?.put(
          year, YearHoliday(year: year, holidays: holidaysMapNoti.value[year]!));
      return true;
    }
    return false;
  }

  Future<bool> removeYear(int year) async {
    if (holidaysMapNoti.value.containsKey(year) && year != DateTime.now().year) {
      holidaysMapNoti.value.remove(year);
      await _yearHolidayBox?.delete(year);
      holidaysMapNoti.notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> resetYearHoliday() async {
    try {
      await _yearHolidayBox?.clear();
      final bufYH = await _readYearsFolder();
      for (final yh in bufYH) {
        await _yearHolidayBox?.put(yh.year, yh);
      }
      final nowYear = DateTime.now().year;
      bool contain = false;
      for (final byh in bufYH) {
        if (byh.year == nowYear) {
          contain = true;
          break;
        }
      }
      if (!contain) {
        final yh = YearHoliday(year: nowYear, holidays: []);
        await _yearHolidayBox?.put(nowYear, yh);
        bufYH.add(yh);
      }

      bufYH.sort((a, b) => a.year.compareTo(b.year));
      holidaysMapNoti.value.clear();
      for (final yh in bufYH) {
        holidaysMapNoti.value[yh.year] = yh.holidays;
      }
      holidaysMapNoti.notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addUserInfo(String name, String email) async {
    if (!userInfosNoti.value.containsKey(name)) {
      userInfosNoti.value[name] = email;
      await _userInfoBox?.put(name, email);
      userInfosNoti.value = _sortStringStringMap(userInfosNoti.value);
      return true;
    }
    return false;
  }

  Future<bool> removeUserInfo(String name) async {
    if (userInfosNoti.value.containsKey(name) && userInfosNoti.value.length > 1) {
      userInfosNoti.value.remove(name);
      await _userInfoBox?.delete(name);
      userInfosNoti.notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> resetUserInfo() async {
    try {
      await _userInfoBox?.clear();
      Map<String, String> userInfoMap = await _getUserInfoData();
      if (userInfoMap.isEmpty) {
        userInfoMap = _sortStringStringMap(Map<String, String>.from(_baseUserInfos));
        for (final info in userInfoMap.entries) {
          await _userInfoBox?.put(info.key, info.value);
        }
      }
      userInfosNoti.value = userInfoMap;
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, String> _sortStringStringMap(Map<String, String> map){
    Map<String, String> sortedMap = {};
    final sortedKeys = map.keys.toList()..sort();
    for (final key in sortedKeys) {
      sortedMap[key] = map[key]!;
    }
    return sortedMap;
  }
}
