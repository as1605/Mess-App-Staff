import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/launch.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory cookieDir = await getTemporaryDirectory();
  final api = API(cookieDir);
  runApp(MyApp(api: api));
}

class MyApp extends StatelessWidget {
  final API api;
  const MyApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mess Staff App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LaunchScreen(api: api),
    );
  }
}
