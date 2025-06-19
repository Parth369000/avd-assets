import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:avd_assets/controller/image_picker_controller.dart';

class ImagePickerScreen extends StatelessWidget {
  final ImagePickerController controller = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: controller.pickImages,
            child: Text('Pick Images'),
          ),
          Obx(() {
            return Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  final image = controller.selectedImages[index];
                  return Image.file(image, fit: BoxFit.cover);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}