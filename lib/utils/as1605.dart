import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class as1605 {
  static void navReplace(
          BuildContext context, Widget Function(BuildContext) builder) =>
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: builder), (_) => false);

  static void navPush(
          BuildContext context, Widget Function(BuildContext) builder) =>
      Navigator.push(context, MaterialPageRoute(builder: builder));

  static Future<void> popup(context,
          {String title = "", Widget? content, List<Widget>? actions}) async =>
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: actions,
              title: Text(title, textAlign: TextAlign.center),
              content: content));

  static String date(String date) {
    DateTime obj = DateTime.parse(date);
    return DateFormat.Md().add_jm().format(obj.toLocal());
  }
}
