import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:image/image.dart';

imglib.Image convertToImage(CameraImage image) {
  try {
    print('image.format.group=>${image.format.group}');
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    throw Exception('Image format not supported');
  } catch (e) {
    print("ERROR:" + e.toString());
  }
  throw Exception('Image format not supported');
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
      height: image.height,
      width: image.width,
      bytes: (image.planes[0].bytes).buffer,
      format: imglib.Format.uint8,
      order: ChannelOrder.bgra);
}

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width: width, height: height);

  const int hexFF = 0xFF000000;

  Uint8List? imgData = img.getBytes(); // Ensure img.data is not null

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex =
          (x / 2).floor() + (y / 2).floor() * (width / 2).floor();
      final int index = y * width + x;

      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];

      int r = (yp + 1436 * (vp - 128) ~/ 1024).clamp(0, 255);
      int g = (yp -
              46549 * (up - 128) ~/ 131072 -
              93604 * (vp - 128) ~/ 131072 +
              44)
          .clamp(0, 255);
      int b = (yp + 1814 * (up - 128) ~/ 1024).clamp(0, 255);

      // Update the pixel color directly
      imgData[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }

  return img;
}
