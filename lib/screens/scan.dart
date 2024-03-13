import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/user.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final API api;
  const ScanScreen({super.key, required this.api});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController =
      MobileScannerController(facing: CameraFacing.back);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("QR Scanner")),
        floatingActionButton: FloatingActionButton(
            onPressed: () => cameraController.switchCamera(),
            child:
                const Icon(Icons.cameraswitch, color: Colors.white, size: 30)),
        body: MobileScanner(
            allowDuplicates: false,
            controller: cameraController,
            onDetect: (barcode, args) {
              final String code = barcode.rawValue ?? "";
              final data = jsonDecode(code);
              if ((data == null) ||
                  !data.containsKey('kerberos') ||
                  !data.containsKey('token')) {
                as1605.popup(context, title: "Invalid QR", content: Text(code));
              } else {
                as1605.navPush(
                    context,
                    (p0) => UserScreen(
                        api: widget.api,
                        kerberos: data['kerberos'],
                        token: data['token']));
              }
            }));
  }
}
