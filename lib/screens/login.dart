import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/launch.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';

class LoginScreen extends StatefulWidget {
  final API api;
  const LoginScreen({super.key, required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String kerberos = "";
  String password = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                    decoration:
                        const InputDecoration(hintText: 'Enter staff username'),
                    onSaved: (String? value) => kerberos = value ?? ""),
                TextFormField(
                    obscureText: true,
                    decoration:
                        const InputDecoration(hintText: 'Enter staff password'),
                    onSaved: (String? value) => password = value ?? ""),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      const SnackBar(content: Text('Logging in'));
                      widget.api.login(kerberos, password).then((value) => value !=
                              false
                          ? as1605.navReplace(
                              context, (_) => LaunchScreen(api: widget.api))
                          : as1605.popup(context,
                              title: 'Login Failed',
                              content: const Text(
                                  "Please try again, check your network connection or contact the developers")));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Submit', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
