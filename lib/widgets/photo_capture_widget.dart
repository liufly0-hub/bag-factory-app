import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/image_utils.dart';

/// 跨平台拍照组件 (Web/Android/iOS)
class PhotoCaptureWidget extends StatefulWidget {
  final XFile? imageFile;
  final ValueChanged<XFile?> onImageChanged;
  final double size;

  const PhotoCaptureWidget({
    super.key,
    this.imageFile,
    required this.onImageChanged,
    this.size = 160,
  });

  @override
  State<PhotoCaptureWidget> createState() => _PhotoCaptureWidgetState();
}

class _PhotoCaptureWidgetState extends State<PhotoCaptureWidget> {
  Uint8List? _imageBytes;

  @override
  void didUpdateWidget(PhotoCaptureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageFile != oldWidget.imageFile) {
      _loadBytes();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) _loadBytes();
  }

  Future<void> _loadBytes() async {
    if (widget.imageFile == null) {
      setState(() => _imageBytes = null);
      return;
    }
    final bytes = await widget.imageFile!.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          image: _imageBytes != null
              ? DecorationImage(
                  image: MemoryImage(_imageBytes!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt,
                      size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('拍照上传',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600)),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => widget.onImageChanged(null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImageUtils.takePhoto();
                if (file != null) widget.onImageChanged(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImageUtils.pickFromGallery();
                if (file != null) widget.onImageChanged(file);
              },
            ),
          ],
        ),
      ),
    );
  }
}
