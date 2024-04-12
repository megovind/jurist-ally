import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:juristally/data/network/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'app_exception.dart';

class ApiServiceCall {
  static const int TIME_OUT_DURATION = 10;

  Future<dynamic> authRequest({required String url, Map<String, dynamic>? data}) async {
    try {
      final uri = "${ApiUrls.BASE_URL}$url";
      final response = await http.post(
        Uri.parse(uri),
        body: json.encode(data),
        headers: {"Content-type": "application/json"},
      ).timeout(Duration(seconds: TIME_OUT_DURATION));

      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time');
    } catch (error) {
      throw InvalidRequestException(error.toString());
    }
  }

  Future<dynamic> getReques({required String url}) async {
    try {
      final uri = "${ApiUrls.BASE_URL}$url";
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse(uri),
        headers: {"Content-type": "application/json", "Authorization": "JWT $token"},
      ).timeout(Duration(seconds: TIME_OUT_DURATION));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time');
    }
  }

  Future<dynamic> postRequest({required String url, dynamic data}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = "${ApiUrls.BASE_URL}$url";
      final token = prefs.getString('access_token');
      final response = await http.post(
        Uri.parse(uri),
        body: json.encode(data ?? {}),
        headers: {"Content-type": "application/json", "Authorization": "JWT $token"},
      ).timeout(Duration(seconds: TIME_OUT_DURATION));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet connection.");
    } on FormatException {
      throw BadRequestException("Please provide valid data");
    } catch (e) {
      throw InvalidRequestException(e.toString());
    }
  }

  Future<dynamic> patchRequest({required String url, dynamic data}) async {
    try {
      final uri = "${ApiUrls.BASE_URL}$url";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.patch(
        Uri.parse(uri),
        body: json.encode(data ?? {}),
        headers: {"Content-type": "application/json", "Authorization": "JWT $token"},
      ).timeout(Duration(seconds: TIME_OUT_DURATION));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet connection.");
    } on FormatException {
      throw BadRequestException("Please provide valid data");
    } catch (e) {
      throw InvalidRequestException(e.toString());
    }
  }

  dynamic _processResponse(http.Response response) {
    final data = json.decode(response.body);
    print("SERVICE:  $data");
    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw BadRequestException(data["error"]["message"] ?? response.reasonPhrase);
      case 404:
        return [];
      case 401:
      case 403:
        throw UnAuthorizedException(data["error"]["message"] ?? response.reasonPhrase);
      case 422:
        throw BadRequestException(data["error"]["message"] ?? response.reasonPhrase);
      case 500:
        throw InternalServerError(data["error"]["message"] ?? response.reasonPhrase);
      default:
        throw InvalidRequestException(data?.error?.message ?? response.reasonPhrase);
    }
  }
}
