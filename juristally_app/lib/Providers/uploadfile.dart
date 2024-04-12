import 'dart:convert';
import 'dart:io';
import 'package:juristally/data/network/api_urls.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UploadFile with ChangeNotifier {
  Future<Map<String, dynamic>> uploadFile(File file, {String? filePath, Map<String, dynamic>? resize}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final fileUploadRequest = http.MultipartRequest(
      "POST",
      Uri.parse(ApiUrls.BASE_URL + ApiUrls.FILE_UPLOAD),
    );
    var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
    //  var stream = new http.ByteStream(file.openRead()).cast();
    var length = await file.length();
    final multiPartFile = new http.MultipartFile(
      'file',
      stream,
      length,
      filename: basename(file.path),
    );
    fileUploadRequest.files.add(multiPartFile);
    if (filePath != null) {
      fileUploadRequest.fields['filePath'] = Uri.encodeComponent(filePath);
    }
    if (resize != null) {
      fileUploadRequest.fields['resize'] = json.encode(resize);
    }
    fileUploadRequest.headers['Authorization'] = 'JWT ${prefs.getString('access_token')}';
    try {
      final streamResponse = await fileUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw "File can not be uploaded";
      }
      final responseData = json.decode(response.body);
      return responseData['response'];
      // final formData =
      //     FormData.fromMap({'file': await MultipartFile.fromFile(filePath, filename: file.path.split('/').last)});
      // final response = await http.post(
      //   baseUrl + "/utilities/upload-files",
      //   data: formData,
      //   options: Options(
      //     headers: {
      //       'Authorization': 'JWT ${prefs.getString('token')}',
      //     },
      //   ),
      // );
      // final responseData = json.decode(response.data);
      // return responseData['response'];
    } catch (error) {
      print("FILE NOtUPDLOAD $error");
      throw error;
    }
  }
}
