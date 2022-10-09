import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/launch.dart';
import 'package:mess_app_staff/utils/api.dart';

Future<void> main() async {
  final api = API();
  runApp(MyApp(api: api));
}

class MyApp extends StatelessWidget {
  final API? api;
  const MyApp({super.key, this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mess Staff App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LaunchScreen(api: api),
    );
  }
}
