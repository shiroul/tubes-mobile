import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<File?> pickImageWithSource(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Pilih Sumber Gambar'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: Row(children: [Icon(Icons.camera_alt), SizedBox(width: 8), Text('Kamera')]),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: Row(children: [Icon(Icons.photo_library), SizedBox(width: 8), Text('Galeri')]),
          ),
        ],
      ),
    );
    if (source == null) return null;
    final picked = await picker.pickImage(source: source);
    if (picked != null) return File(picked.path);
    return null;
  }
}
