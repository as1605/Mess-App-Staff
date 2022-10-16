import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/launch.dart';
import 'package:mess_app_staff/screens/scan.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';

class HomeScreen extends StatelessWidget {
  final API api;
  const HomeScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () => api.logout().then((_) =>
                  as1605.navReplace(context, (_) => LaunchScreen(api: api))),
              child: const Text('Logout')),
          ElevatedButton(
              onPressed: () =>
                  as1605.navPush(context, (_) => ScanScreen(api: api)),
              child: const Text('Scan'))
        ],
      ),
    );
  }
}
