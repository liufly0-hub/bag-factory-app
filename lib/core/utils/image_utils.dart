import 'package:cross_file/cross_file.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// 拍照（跨平台）
  static Future<XFile?> takePhoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1920,
    );
  }

  /// 从相册选择（跨平台）
  static Future<XFile?> pickFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1920,
    );
  }

  /// 生产记录图片名 (后续接入Supabase后开启上传)
  static String productionPhotoFileName(String userId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'production/$userId/$ts.jpg';
  }
}
