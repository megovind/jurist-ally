import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:juristally/Providers/uploadfile.dart';
import 'package:juristally/data/network/api_urls.dart';
import 'package:juristally/data/network/apiservicecall.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/notification_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  UserModel? _loggedInuser, _userProfile;
  bool _isRegistered = false;

  String? _token;
  String? _emailPhone;

  bool? get isRegistered => _isRegistered;

  UserModel? get loggedInUser => _loggedInuser;
  UserModel? get userProfile => _userProfile;

  bool get isLoggedIn => _token != null;
  String? get accessToken => _token;

  String? get emailPhone => _emailPhone;

  Future<void> authenticate({Map<String, dynamic>? data}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (isNumericUsingRegularExpression(data!['email_phone'])) data['email_phone'] = int.parse(data['email_phone']);
      final url = ApiUrls.SIGNUP_SIGNIN;
      final response = await ApiServiceCall().authRequest(url: url, data: data);
      print(response);
      String regToken = response['response']['reg_token'];
      String userId = response['response']['user'];
      prefs.setString('regToken', regToken);
      prefs.setString("userId", userId);
      _emailPhone = data['email_phone'].toString();
      _isRegistered = response['is_registred'];
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  bool isNumericUsingRegularExpression(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(string);
  }

  Future<void> verifyOTP({Map<String, dynamic>? data}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final otpRegToken = prefs.getString('regToken');
      final url = ApiUrls.SIGNUP_SIGNINOTP;
      final _data = {"code": data?['code'], "reg_token": otpRegToken};
      final response = await ApiServiceCall().authRequest(url: url, data: _data);
      _loggedInuser = UserModel.fromJson(response['response']['user']);
      String accessToken = response['response']['token']['access_token'];
      String refreshToken = response['response']['token']['refresh_token'];
      prefs.setString('refresh_token', refreshToken);
      prefs.setString('access_token', accessToken);
      _token = accessToken;
      notifyListeners();
      return;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final url = ApiUrls.REFRESH_TOKEN;
      final refreshToken = prefs.getString('refresh_token');
      final _data = {"refresh_token": refreshToken};
      final response = await ApiServiceCall().authRequest(url: url, data: _data);
      final accessToken = response['token']['access_token'];
      prefs.setString('refresh_token', response['token']['refresh_token']);
      prefs.setString('access_token', accessToken);
      _token = accessToken;
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<bool>? tryAutoSigin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("access_token") || !prefs.containsKey("refresh_token")) return false;
    final _accessToken = prefs.getString('access_token');
    if (_accessToken != null) {
      _token = _accessToken;
      _loggedInuser = await fetchSelfProfile();
      notifyListeners();
      return true;
    } else {
      print("IN THE ELSE");
      // prefs.clear();
      // notifyListeners();
      return false;
    }
  }

  Future<bool> signout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (prefs.containsKey('access_token'))
      return false;
    else
      return true;
  }

  Future<bool> deactivateAccount() async {
    try {
      final url = ApiUrls.DEACTIVATE_ACCOUNT;
      final response = await ApiServiceCall().postRequest(url: url);
      bool isDeactivated = response['is_deactivated'];
      if (isDeactivated) await signout();
      return isDeactivated;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> fetchAgoraToken({Map<String, dynamic>? data}) async {
    try {
      final url = ApiUrls.GENRATE_TOKEN;
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      final token = response['token'];
      return token;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateUser({Map<String, dynamic>? data}) async {
    try {
      final url = ApiUrls.UPDATE_PROFILE;
      if (data!['profile'] != null) {
        final uploaded = await UploadFile().uploadFile(data['profile'], resize: data['resize']);
        data['avatar'] = uploaded['file_url'];
        data['profile'] = null;
      }
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      _loggedInuser = UserModel.fromJson(response['response']);
      _userProfile = _loggedInuser;
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchProfile({String? id}) async {
    try {
      final url = id != null ? '${ApiUrls.FETCH_PROFILE}?id=$id' : ApiUrls.FETCH_PROFILE;
      final response = await ApiServiceCall().getReques(url: url);
      _userProfile = UserModel.fromJson(response['response']);
      if (id == null) _loggedInuser = _userProfile;
      notifyListeners();
      return;
    } catch (e) {
      print(e);
      // throw e;
    }
  }

  Future<String> followUnFollow({String? id}) async {
    try {
      final url = "${ApiUrls.FOLLOW_UNFOLLOW}/$id";
      final response = await ApiServiceCall().postRequest(url: url);
      final message = response['message'].toString();
      final _connections = Connections.fromJson(response['resppnse']);
      _userProfile?.connections = _connections;
      notifyListeners();
      return message;
    } catch (e) {
      throw e;
    }
  }

  Future<EducationModel> updateAddEducation({String? id, Map<String, dynamic>? data}) async {
    try {
      final url = id != null ? '${ApiUrls.UPDATE_EDUCATION}/$id' : ApiUrls.ADD_EDUCATION;
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      EducationModel education = EducationModel.fromJson(response['response']);
      if (id != null) {
        int? index = _loggedInuser?.educations!.indexWhere((element) => element.id == id);
        _loggedInuser?.educations!.insert(index ?? 0, education);
        notifyListeners();
      } else {
        _loggedInuser?.educations?.insert(0, education);
        notifyListeners();
      }
      notifyListeners();
      return education;
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteEducation({String? id}) async {
    try {
      final url = '${ApiUrls.DELETE_EDUCATION}/$id';
      await ApiServiceCall().postRequest(url: url);
      // if (response) _loggedInuser!.educations!.removeWhere((element) => element.id == id);
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteExeperience({String? id}) async {
    try {
      final url = '${ApiUrls.DELETE_EXPERIENCE}/$id';
      final response = await ApiServiceCall().postRequest(url: url);

      // if (response) _loggedInuser!.expereinces!.removeWhere((element) => element.id == id);
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<ExperienceModel> updateAddEexperince({String? id, Map<String, dynamic>? data}) async {
    try {
      final url = id != null ? '${ApiUrls.UPDATE_EXPERIENCE}/$id' : ApiUrls.ADD_EXPERIENCE;
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      ExperienceModel experience = ExperienceModel.fromJson(response['response']);
      if (id != null) {
        int? index = _loggedInuser?.expereinces!.indexWhere((element) => element.id == id);
        _loggedInuser?.expereinces!.insert(index ?? 0, experience);
        notifyListeners();
      } else {
        _loggedInuser?.expereinces?.insert(0, experience);
        notifyListeners();
      }
      notifyListeners();
      return experience;
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteAchievement({String? id}) async {
    try {
      final url = '${ApiUrls.DELETE_ACHIEVEMENT}/$id';
      await ApiServiceCall().postRequest(url: url);
      // if (response) _loggedInuser!.achievements!.removeWhere((element) => element.id == id);
      notifyListeners();
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<AchievementModel> updateAddAchievement({String? id, Map<String, dynamic>? data}) async {
    try {
      final url = id != null ? '${ApiUrls.UPDATE_ACHIEVEMENT}/$id' : ApiUrls.ADD_ACHIEVEMENT;
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      AchievementModel achievement = AchievementModel.fromJson(response['response']);
      if (id != null) {
        int? index = _loggedInuser?.achievements!.indexWhere((element) => element.id == id);
        _loggedInuser?.achievements!.insert(index ?? 0, achievement);
        notifyListeners();
      } else {
        _loggedInuser?.achievements?.insert(0, achievement);
        notifyListeners();
      }
      notifyListeners();
      return achievement;
    } catch (e) {
      throw e;
    }
  }

  searchAddress({String? pattern}) async {
    try {
      final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/place/textsearch/json', {
        'query': pattern,
        "key": 'secret_key',
      });
      final response = await http.get(uri);
      final decodentResponse = json.decode(response.body);
      return decodentResponse['results'];
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<UserModel> fetchSelfProfile() async {
    final url = '${ApiUrls.FETCH_PROFILE}';
    final response = await ApiServiceCall().getReques(url: url);
    return UserModel.fromJson(response['response']);
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final url = '${ApiUrls.FETCH_USERS}';
      final response = await ApiServiceCall().postRequest(url: url);
      List<UserModel> _users = usersList(response['response']);
      notifyListeners();
      return _users;
    } catch (e) {
      throw e;
    }
  }

  Future<List<NotificationModel>> fetchNotifications({int page = 1}) async {
    try {
      final url = ApiUrls.FETCH_NOTIFICATIONS;
      final response = await ApiServiceCall().getReques(url: url);
      List<NotificationModel> notifications = [];
      if (response.length > 0) notifications = listNotifications(response['response']);
      return notifications;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateNotification({String? nId}) async {
    try {
      final url = ApiUrls.UPDATE_NOTIFICATION;
      final response = await ApiServiceCall().postRequest(url: url);
      NotificationModel notification = NotificationModel.fromJson(response['response']);
      return;
    } catch (e) {
      print(e);
      // throw e;
    }
  }

  Future<void> updateRegistrationToken({Map<String, dynamic>? data}) async {
    try {
      final url = ApiUrls.NOTIFICATION_TOKEN;
      await ApiServiceCall().postRequest(url: url, data: data);
    } catch (e) {
      print(e);
    }
  }
}
