import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:juristally/Localization/localization.dart';
import 'package:juristally/helper/file_upload.dart';

Future<File?> cropImage({required BuildContext context}) async {
  File? cropped;
  try {
    File file = await selectSingleFile(types: ['jpg', 'jpeg', 'png']);
    if (file != null) {
      cropped = await ImageCropper.cropImage(
        sourcePath: file.path,
        // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 400,
        maxWidth: 700,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        compressFormat: ImageCompressFormat.png,
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ),
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Theme.of(context).primaryColor,
            toolbarTitle: translatedString(context, "adjust_image"),
            toolbarWidgetColor: Colors.black,
            statusBarColor: Colors.deepOrange[100],
            backgroundColor: Colors.white),
      );
    }
    return cropped;
  } catch (e) {
    print(e);
    // throw e;
  }
}
