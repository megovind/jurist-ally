import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File> selectSingleFile({List<String>? types}) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: types);
  File _file = File(result!.files.first.path ?? "");
  return _file;
}

Future<List<File>> selectMultipleFiles({List<String>? types}) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: types);
  List<File> _files = result!.paths.map((path) => File(path ?? "")).toList();
  return _files;
}
