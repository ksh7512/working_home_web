import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ConvUtil {
  static const defaultBackground = Color(0x30000000);

  static String getAssets(String path) => "packages/en_contents_player/assets/$path";

  static const bool _customToastActive = true;
  static FToast? _fToast;

  static void toast(
      {required BuildContext context, required String? message, bool toastShortOrLong = true}) {
    if (_customToastActive) {
      try {
        _fToast?.removeCustomToast();
        _fToast = FToast()
          ..init(context)
          ..showToast(
            child: _toastWidget(message ?? '', 80),
            gravity: ToastGravity.SNACKBAR,
            toastDuration:
                toastShortOrLong ? const Duration(seconds: 2) : const Duration(seconds: 5),
          );
        return;
      } catch (e) {
        _fToast = null;
      }
    }

    // 일반 토스트로 변경
    Fluttertoast.showToast(
        msg: message!,
        toastLength: toastShortOrLong ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 68, 68, 68),
        textColor: Colors.white,
        fontSize: 20);
    return;
  }

  static Widget _toastWidget(String msg, double btm) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: EdgeInsets.only(bottom: btm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color(0xE0404040),
        ),
        child: Text(
          msg,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );

  // 로그 기본 이메일 전송 함수.
  static Future sendEmail({
    required String title,
    required String body,
    required List<String> recipientList,
    List<String> ccList = const [],
    List<String> bccList = const [],
  }) async {
    try {
      String encodedSubject = Uri.encodeComponent(title);
      String encodedBody = Uri.encodeComponent(body);
      String cc = '';
      for (final lc in ccList) {
        cc += lc;
      }
      String bcc = '';
      for (final lbc in bccList) {
        bcc += lbc;
      }

      String recipients = '';
      for (final r in recipientList) {
        recipients += ',$r';
      }

      Uri params = Uri(
          scheme: 'mailto',
          path: recipients,
          query: 'subject=$encodedSubject&body=$encodedBody&cc=$cc&bcc=$bcc');

      if (await canLaunchUrl(params)) {
        await launchUrl(params);
      } else {
        throw 'Could not launch $params';
      }
      return true;
    } catch (e) {
      print('$e');
      return false;
    }
  }

  static Future showPlaneDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onOk,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        content: Text(content,
            style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () {
                  onOk.call();
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
