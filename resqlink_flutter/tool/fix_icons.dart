import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final baseFile = File('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png');
  if (!baseFile.existsSync()) {
    print('Base icon file not found');
    return;
  }

  final bytes = baseFile.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    print('Failed to decode base image');
    return;
  }

  final targets = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };

  for (final entry in targets.entries) {
    final size = entry.value;
    final path = entry.key;
    final resized = img.copyResize(decoded, width: size, height: size);
    // Encode as clean 32-bit RGBA PNG without exotic metadata
    final encoded = img.encodePng(resized);
    File(path).writeAsBytesSync(encoded);
    print('Wrote clean $size x $size PNG to $path (${encoded.length} bytes)');
  }
}
