import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/launch.dart';
import 'package:mess_app_staff/screens/scan.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  final API api;
  const HomeScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mess App v2.0"), actions: [
        ElevatedButton(
            onPressed: () => api.logout().then((_) =>
                as1605.navReplace(context, (_) => LaunchScreen(api: api))),
            child: const Text('Logout'))
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
                child: ElevatedButton(
                    onPressed: () =>
                        as1605.navPush(context, (_) => ScanScreen(api: api)),
                    child: const Padding(
                        padding: EdgeInsets.all(25),
                        child: Text('Scan', style: TextStyle(fontSize: 40))))),
          ),
          Center(
              child: TextButton(
                  onPressed: () => launchUrl(
                      Uri.parse('https://github.com/as1605'),
                      mode: LaunchMode.externalApplication),
                  child: RichText(
                      textScaler: const TextScaler.linear(1.2),
                      text: TextSpan(children: const [
                        TextSpan(text: "Developed by Aditya Singh "),
                        TextSpan(
                            text: "(as1605)",
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ], style: TextStyle(color: Colors.grey.shade500)))))
        ],
      ),
    );
  }
}
