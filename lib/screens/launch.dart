import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/home.dart';
import 'package:mess_app_staff/screens/login.dart';
import 'package:mess_app_staff/utils/api.dart';

class LaunchScreen extends StatelessWidget {
  final API api;
  const LaunchScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: api.myProfile(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return HomeScreen(api: api);
            } else {
              return LoginScreen(api: api);
            }
          } else {
            return Scaffold(
                appBar: AppBar(title: const Text("Mess Staff App")),
                body:
                    const Center(child: CircularProgressIndicator.adaptive()));
          }
        });
  }
}
