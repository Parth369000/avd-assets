import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class ImagePickerController extends GetxController {
  var selectedImages = <File>[].obs;

  Future<void> pickImages() async {
    if (await _requestPermissions()) {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images.map((image) => File(image.path)).toList());
        _autoRenameImages();
        addImages();
      } else {
        print("No images selected or picker returned null");
      }
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  void _autoRenameImages() {
    for (int i = 0; i < selectedImages.length; i++) {
      final oldFile = selectedImages[i];
      final newName = 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final newFile = oldFile.renameSync('${oldFile.parent.path}/$newName');
      selectedImages[i] = newFile;
    }
  }

  Future<void>addImages() async {
    // 27.116.52.24:8054', '/addProductWithStorage
    final Uri url = Uri.http('');
    var request = http.MultipartRequest('POST', url);
    for (var image in selectedImages) {
      var file = await http.MultipartFile.fromPath('images', image.path);
      request.files.add(file);

      // Print file details
      print('Added file: ${file.filename}, Path: ${image.path}');
    }
    // Print full list of files
    print('All files added: ${request.files.map((file) => file.filename).toList()}');
    // var response = await request.send();
    // if (response.statusCode == 200){
    //   Get.to(const EntryPointUI(),transition: Transition.fadeIn);
    // }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }
}