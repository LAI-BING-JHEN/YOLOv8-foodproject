import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

Future<File> compressImage(File file) async {
  final targetPath = file.path.replaceAll(".jpg", "_compressed.jpg");

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 60,
    minWidth: 800,
    minHeight: 800,
  );

  if (result != null) {
    print(" 壓縮後大小: ${await result.length()} bytes");
    return File(result.path);
  } else {
    return file;
  }
}