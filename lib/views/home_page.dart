import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

import 'package:watermark_generator/widgets/button.dart';
import 'package:watermark_generator/widgets/decorated_container.dart';
import 'package:watermark_generator/widgets/home/image_holder.dart';
import 'package:watermark_generator/widgets/home/position_select.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double sliderValue = 20;
  double opacity = 1;

  AlignmentGeometry selectedPosition = Alignment.center;
  String watermarkText = "";
  File? selectedFile;
  File? selectedWatermarkImage;

  bool isImageAsWatermark = false;
  bool isExporting = false;

  final GlobalKey thumbnailKey = GlobalKey();

  void importWatermark() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        selectedWatermarkImage = File(file.path);
      });
    }
  }

  handleExport() async {
    if (selectedFile == null) {
      Fluttertoast.showToast(
        msg: "Please import image",
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      return;
    }
    if (!isImageAsWatermark && watermarkText == "" ||
        isImageAsWatermark && selectedWatermarkImage == null) {
      Fluttertoast.showToast(
        msg: "Please include watermark",
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      return;
    }

    try {
      setState(() {
        isExporting = true;
      });
      RenderRepaintBoundary boundary = thumbnailKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 10.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Something went wrong");
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();
      await ImageGallerySaver.saveImage(pngBytes, name: 'image_$sliderValue');
      setState(() {
        isExporting = false;
      });
      Fluttertoast.showToast(msg: "Image exported");
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFB),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.convertshape,
              size: 18,
            ),
            SizedBox(width: 5),
            Text(
              "WATERMARK",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // * Image holder
              ImageHolder(
                  watermarkText: watermarkText,
                  watermarkImage: selectedWatermarkImage,
                  onSelected: (p0) {
                    setState(() {
                      selectedFile = p0;
                    });
                  },
                  opacity: opacity,
                  selectedFile: selectedFile,
                  thumbnailKey: thumbnailKey,
                  selectedPosition: selectedPosition,
                  sliderValue: sliderValue),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Import Image as watermark".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Transform.scale(
                    scale: .7,
                    child: CupertinoSwitch(
                        value: isImageAsWatermark,
                        onChanged: (value) {
                          if (value == false) {
                            setState(() {
                              selectedWatermarkImage = null;
                            });
                          }
                          setState(() {
                            isImageAsWatermark = value;
                          });
                        }),
                  )
                ],
              ),
              // * Watermark
              DecoratedContainer(
                child: isImageAsWatermark
                    ? GestureDetector(
                        onTap: () => importWatermark(),
                        child: Row(
                          children: [
                            Icon(
                              selectedWatermarkImage == null
                                  ? Iconsax.import
                                  : Icons.done,
                              color: selectedWatermarkImage == null
                                  ? Colors.black
                                  : Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              selectedWatermarkImage == null
                                  ? "Tap to import watermark".toUpperCase()
                                  : "Watermark selected".toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: selectedWatermarkImage == null
                                      ? Colors.black
                                      : Colors.green),
                            ),
                          ],
                        ),
                      )
                    : TextField(
                        onChanged: (value) {
                          setState(() {
                            watermarkText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Watermark text".toUpperCase(),
                          hintStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
              ),
              // * Size selector
              DecoratedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Size".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlider(
                        value: sliderValue,
                        min: 10,
                        max: 40,
                        onChanged: (value) {
                          setState(() {
                            sliderValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // * Size selector
              DecoratedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Opacity".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlider(
                        value: opacity,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            opacity = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // * Position
              PositionSelect(
                positions: const [
                  Alignment.bottomCenter,
                  Alignment.bottomLeft,
                  Alignment.bottomRight,
                  //
                  Alignment.topCenter,
                  Alignment.topLeft,
                  Alignment.topRight,
                  //
                  Alignment.center,
                  Alignment.centerLeft,
                  Alignment.centerRight,
                ],
                selectedPosition: selectedPosition,
                onSelect: (p0) {
                  setState(() {
                    selectedPosition = p0;
                  });
                },
              ),
              // * Button
              Button(
                isLoading: isExporting,
                text: "Embed watermark",
                onTap: () {
                  if (isExporting) {
                    return;
                  }
                  handleExport();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
