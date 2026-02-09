import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magic_recipe_client/magic_recipe_client.dart';
import 'package:magic_recipe_flutter/main.dart';
import 'package:magic_recipe_flutter/widgets/serverpod_image.dart';

class ImageUploadButton extends StatefulWidget {
  final String? imagePath;
  final ValueChanged<String?>? onImagePathChanged;

  const ImageUploadButton({
    super.key,
    this.onImagePathChanged,
    this.imagePath,
  });

  @override
  State<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends State<ImageUploadButton> {
  bool uploading = false;
  late ValueNotifier<String?> imagePath;

  @override
  void initState() {
    super.initState();
    imagePath = ValueNotifier<String?>(widget.imagePath);
    imagePath.addListener(() {
      widget.onImagePathChanged?.call(imagePath.value);
    });
  }

  Future<String?> uploadImage(XFile imageFile) async {
    var imageStream = imageFile.openRead();
    var length = await imageFile.length();

    final (uploadDescription, path) = await client.recipes.getUploadDescription(
      imageFile.name,
    );

    if (uploadDescription != null) {
      var uploader = FileUploader(uploadDescription);
      await uploader.upload(imageStream, length);
      var success = await client.recipes.verifyUpload(path);
      return success ? path : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (uploading) const Center(child: CircularProgressIndicator()),
        if (imagePath.value != null)
          Stack(
            children: [
              ServerpodImage(
                imagePath: imagePath.value,
                key: ValueKey(imagePath.value),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => imagePath.value = null),
                ),
              ),
            ],
          ),
        if (imagePath.value == null)
          ElevatedButton(
            onPressed: () async {
              final imageFile = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );

              if (imageFile != null) {
                setState(() => uploading = true);
                imagePath.value = await uploadImage(imageFile);
                setState(() => uploading = false);
              }
            },
            child: const Text('Upload Image'),
          ),
      ],
    );
  }
}
