import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'package:watermark_generator/widgets/decorated_container.dart';

class ImageHolder extends StatefulWidget {
  final GlobalKey thumbnailKey;
  final File? selectedFile;
  final String watermarkText;
  final Function(File) onSelected;
  final double sliderValue;
  final AlignmentGeometry selectedPosition;
  const ImageHolder({
    Key? key,
    required this.thumbnailKey,
    required this.selectedFile,
    required this.watermarkText,
    required this.onSelected,
    required this.sliderValue,
    required this.selectedPosition,
  }) : super(key: key);

  @override
  State<ImageHolder> createState() => _ImageHolderState();
}

class _ImageHolderState extends State<ImageHolder> {
  handleImportImage() async {
    try {
      ImagePicker imagePicker = ImagePicker();
      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        widget.onSelected(File(file.path));
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong",
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        handleImportImage();
      },
      child: DecoratedContainer(
        height: 250,
        child: widget.selectedFile != null
            ? RepaintBoundary(
                key: widget.thumbnailKey,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(widget.selectedFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: widget.selectedPosition,
                      child: Text(
                        widget.watermarkText,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: widget.sliderValue,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : selectImageInfo(),
      ),
    );
  }

  Column selectImageInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.image),
        SizedBox(height: 15),
        Text("Tap to import an image"),
      ],
    );
  }
}
