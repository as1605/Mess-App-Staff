import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:mess_app_staff/screens/user.dart';
import 'package:mess_app_staff/utils/api.dart';
import 'package:mess_app_staff/utils/as1605.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class PhotoScreen extends StatefulWidget {
  final API api;
  final String kerberos;
  final String token;
  const PhotoScreen(
      {super.key,
      required this.api,
      required this.kerberos,
      required this.token});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  Future<String> _path() async {
    final tempPath = await getTemporaryDirectory();
    final dir = Directory('${tempPath.path}/images/${DateTime.now()}.jpg');
    return dir.path;
  }

  Future<File> compressImage(File originalImage) async {
    final originalImageData = await originalImage.readAsBytes();
    final decodedImage = img.decodeImage(originalImageData);
    final resizedImage = img.copyResize(decodedImage!, width: 480, height: 480);

    // Compress the image to JPEG with 85% quality (adjust as necessary)
    final compressedImageData = img.encodeJpg(resizedImage, quality: 80);

    // Write the compressed image data to a new file (or overwrite the original)
    final compressedImageFile = File(originalImage.path)
      ..writeAsBytesSync(compressedImageData);

    return compressedImageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take Photo")),
      body: CameraAwesomeBuilder.awesome(
          previewPadding: const EdgeInsets.all(20),
          aspectRatio: CameraAspectRatios.ratio_1_1,
          previewFit: CameraPreviewFit.contain,
          saveConfig: SaveConfig.photo(pathBuilder: () => _path()),
          onMediaTap: (mediaCapture) async {
            as1605.popup(context,
                title: "Uploading Image",
                content: const SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(child: CircularProgressIndicator())));
            final compressedImage =
                await compressImage(File(mediaCapture.filePath));
            final response = await widget.api
                .uploadPhoto(widget.kerberos, compressedImage.path);
            File(compressedImage.path).delete();
            if (response == true) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              as1605.navPush(
                  context,
                  (_) => UserScreen(
                      api: widget.api,
                      kerberos: widget.kerberos,
                      token: widget.token));
            } else {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              // ignore: use_build_context_synchronously
              as1605.popup(context,
                  title: "Error in Uploading Photo",
                  content: Text("$response"));
            }
          }),
    );
  }
}
