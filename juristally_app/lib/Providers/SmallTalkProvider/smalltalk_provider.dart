import 'package:flutter/cupertino.dart';
import 'package:juristally/Providers/uploadfile.dart';
import 'package:juristally/data/network/api_urls.dart';
import 'package:juristally/data/network/apiservicecall.dart';
import 'package:juristally/models/small_talk_model.dart';

class SmallTalkProvider with ChangeNotifier {
  List<SmallTalkModel> _talks = [];

  List<SmallTalkModel> get smallTalks => List.from(_talks);

  Future<SmallTalkModel> createSmallTalk({String? id, Map<String, dynamic>? data}) async {
    try {
      print(data);
      // return;
      if (data!['audio_file'] != null) {
        final file = await UploadFile().uploadFile(data['audio_file']);
        data['audio_clip'] = file['file_url'];
        data['audio_file'] = null;
      }
      final url = id != null ? "${ApiUrls.UPDATE_SMALL_TALK}/$id" : ApiUrls.CREATE_SMALL_TALK;
      final response = await ApiServiceCall().postRequest(url: url, data: data);
      final smalltalk = SmallTalkModel.fromJson(response['response']);
      _talks.insert(0, smalltalk);
      notifyListeners();
      return smalltalk;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<SmallTalkModel>> fetchSmallTalks({String? id, int? page, String? status}) async {
    try {
      final url = ApiUrls.FETCH_SMALL_TALK;
      final response = await ApiServiceCall().postRequest(url: url);
      print("Smalltalks $response");
      List<SmallTalkModel> _smalltalks = [];
      // if (response['response'].length > 0) {
      _smalltalks = response.length > 0 ? smalltalkList(response['response']) : [];
      // }
      _talks = _smalltalks;
      notifyListeners();
      return _smalltalks;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<SmallTalkModel?> likeDislikeSmallTalk({String? id}) async {
    try {
      final url = "${ApiUrls.LIKE_DISLIKE_SMALL_TALK}/$id";
      final response = await ApiServiceCall().postRequest(url: url);
      SmallTalkModel talk = SmallTalkModel.fromJson(response['response']);
      return talk;
    } catch (e) {
      print(e);
    }
  }

  Future<SmallTalkModel?> commentOnSmallTalk({Map<String, dynamic>? data, String? id}) async {
    try {
      final url = "${ApiUrls.COMMENT_SMALL_TALK}/$id";
      final response = await ApiServiceCall().postRequest(url: url);
      SmallTalkModel talk = SmallTalkModel.fromJson(response['response']);
      return talk;
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteSmallTalk({String? id}) async {
    try {
      final url = "${ApiUrls.DELETE_SMALL_TALK}/$id";
      final response = await ApiServiceCall().postRequest(url: url);
      print(response);
      return;
    } catch (e) {
      print(e);
    }
  }
}
