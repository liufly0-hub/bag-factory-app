import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// 拍照
  static Future<File?> takePhoto() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1920,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// 从相册选择
  static Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1920,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// 生产记录图片名 (后续接入Supabase后开启上传)
  static String productionPhotoFileName(String userId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'production/$userId/$ts.jpg';
  }
}
